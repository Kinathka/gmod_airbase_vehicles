if not AVehicles then 
	Msg("\nShip:AVehicle Base not installed! Please install it for this addon to work!\n")
end 



AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include("sv/engine.lua")
include("sv/events.lua")


/* A note the the person that wants to modify this code or use it.
 this code is based on the avehicle_base entity, is inherits from that entity.
So if you create a function like ENT:Initialize(), please add self.BaseClass.Initialize(self) in that function.
Please remeber the ENT:OnRemove() function and call self.BaseClass.OnRemove(self) in it!
The only exception is with the ENT:Think() function, there you can use ENT:DoThink() instead.
You may override function in the baseclass freely. If I update the base class you must update your stuff too though.
The baseclass entity should be avehicle_base
*/



function ENT:Initialize()
	self.BaseClass.Initialize(self) --This is very important!
	self.Entity:SetModel(self.Models.Base) 
	self.Entity:SetName(self.PrintName)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	--Please put this in the initialize function of the child entities if you want PhysicsSimulate to be called
	if (!self.EngineUseCustom) then
		self:StartMotionController()
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(14000)
	end
	self.DEBUG = true
	self.Entity:SetUseType(SIMPLE_USE)
	self.WCannon = nil
	self.PilotWeaponControl = true  -- Flyboi's request @ Warkanum
	self.geardown = false
	self.DoorOpen = false
	self.IsAnimating = false
	self.IsBadlyDamaged = false
	--Initialize the rotor engine variables
	self:SetupRotorEngine()

	--rotor entities
	self.Rotors = {}
	self.Rotors.Front = nil
	self.Rotors.Back = nil
	self.Rotors.FrontSpeed = 380
	self.Rotors.BackSpeed = 280
	
	self:CreateRotors()
	--self:SpawnWeaponCannon()
	
	--self:WeaponPostAdd(0,"Missile",function() self:WepFireMissile() end,nil)
end


function ENT:SpawnFunction( ply, tr ) 
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle() + Angle(90,90,90)
	ang.p = 0
	ang.r = 0
	local ent = ents.Create(self.EntityName)
	local z = tr.HitPos.z
	tr.HitPos.z = 0
	local pos = ply:GetPos()
	pos.z = 0
	local dir = tr.HitPos - pos
	if(dir:Length() < 250) then
		dir = dir:GetNormalized()*250
	end
	ent:SetPos(pos + dir + Vector(0,0,z + 90))
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	--ent:SetOwner(ply)
	ent:SetPhysicsAttacker(ply)
	ent.AVehicle_Creator = ply
	ent:PostSpawn() --This call is very important
	return ent
end

function ENT:PhysicsSimulate(phys, deltatime)
	if (!self.EngineUseCustom) then
		if IsValid(self.Entity) then
			if (self.Engine) then --Check if the engine table exists.
				return self:EnginePhysicsSimulate(phys, deltatime)	
			end
		end
	end
end

function ENT:DoThink() --Called by the parent think, do not make your own think, else add the exact time and call self.BaseClass.Think(self) 
	if self.Engine.Active then
		self:PropMotion()
	end
	if self.EngineStarted and not self.Engine.Active then
		self:StartupMotion()
	end

end

--Avehicles override to include rotors in ent ignore list @ warkanum
function ENT:CalcAimVectors(ply) --Returns hitpos vector
	if self:PlayerCheck(ply) and (self:GetClientThirdPersonView(ply) != 2) then
		local ang = ply:GetAimVector():GetNormal()
		local pos = ply:GetShootPos()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*990000)
		local attachables = {}
		if self.HardPointsInstalled then
			for _,v in pairs(self.HardPointsInstalled) do
				if v and v.ent then
					table.insert(attachables, v.ent)
				end
			end
		end
		local filterents = {self.Entity, ply, self.Rotors.Front,self.Rotors.Back}
		table.Add( filterents, self.PodsEnts)
		table.Add( filterents, self.Passengers)
		table.Add( filterents, self.Gagets.Bullseyes)
		table.Add( filterents, self.Gagets.Lights)
		table.Add( filterents, attachables)
		--self:EngineGetConstraintEnts()
		tracedata.filter = filterents
		local trace = util.TraceLine(tracedata)
		return trace.HitPos
	else --If view is locked on vehicles, we want to trace in the vehicles forward direction.
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetForward()*800000
		local filterents = {self.Entity, ply}
		table.Add( filterents, self.PodsEnts)
		table.Add( filterents, self.Passengers)
		table.Add( filterents, self.Gagets.Bullseyes)
		table.Add( filterents, self.Gagets.Lights)

		tracedata.filter = filterents
		local trace = util.TraceLine(tracedata)
		return trace.HitPos
	end
	return Vector(0,0,0)
end


function ENT:TriggerInput(k,v)

end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self) --I can't even tell you how important this is! Because it is! 
	self:RemoveRotors(true, true)
	if IsValid(self.WCannon) then
		self.WCannon:Remove()
	end
end


/*
#####----###---#####---###---#####---####-
#----#--#---#----#----#---#--#----#-#----#
#----#-#-----#---#---#-----#-#----#-#-----
#####--#-----#---#---#-----#-#####---##---
#--#---#-----#---#---#-----#-#--#------##-
#---#--#-----#---#---#-----#-#---#-------#
#---#---#---#----#----#---#--#---#--#----#
#----#---###-----#-----###---#----#--####-

*/

function ENT:CreateRotors()
	self.Rotors.Front = ents.Create( "avehicle_uh1yvenom_rotor" )
	--self.Rotors.Front:SetModel(self.Models.RotorBase)
	self.Rotors.Front:SetName("Heli Venom Rotor")
	self.Rotors.Front:SetOwner(self.Owner)
	self.Rotors.Front.Heli = self
	self.Rotors.Front:SetAngles(self.Entity:GetAngles())
	self.Rotors.Front:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * 140) + (self.Entity:GetForward() * -6)) 
	self.Rotors.Front:Spawn()

	self.Rotors.Back = ents.Create("prop_physics")
	self.Rotors.Back:SetModel(self.Models.RotorTail)
	self.Rotors.Back:SetName("Heli Venom Back Rotor")
	self.Rotors.Back:SetAngles(self.Entity:GetAngles())
	self.Rotors.Back:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * 134)  + (self.Entity:GetForward() * -358) + (self.Entity:GetRight() * -5)) --330.2450 6.6013 135.5856
	self.Rotors.Back:SetOwner(self.Owner)
	self.Rotors.Back:Spawn()
	self.Rotors.Back.IsAVehicleObject = true
	local rotorphys = self.Rotors.Back:GetPhysicsObject()
	if rotorphys and rotorphys:IsValid() then
		rotorphys:SetMass(100)
		rotorphys:EnableDrag(true)
	end
	
	--Front rotor center of mass. But still it vibrates, wtf?
	local frphys = self.Rotors.Front:GetPhysicsObject()
	local frotorOffset = Vector(0,0,0)
	if frphys and frphys:IsValid() then
		frotorOffset = frphys:GetMassCenter()
		--frotorOffset = self.Rotors.Front:WorldToLocal(frotorOffset)
	end
	
	--Constraint prop
	constraint.Axis( self.Entity, self.Rotors.Front, 0, 0, Vector(-6,0,140), frotorOffset , 0, 0, 1, 1)	
	constraint.Axis( self.Entity, self.Rotors.Back, 0, 0, Vector(-358,-16,134) , Vector(0,0,0), 0, 0, 1, 1)
	constraint.NoCollide(self.Rotors.Front, self.Rotors.Back, 0, 0 )
	
	--Inform the client of these entities so we can make the camera ignore them in any traces. @ Warkanum
	self:SetNWInt("avengine_rotor_fronti", self.Rotors.Front:EntIndex())
	self:SetNWInt("avengine_rotor_backi", self.Rotors.Back:EntIndex())
end

function ENT:RemoveRotors(front, back)
	if front then
		if IsValid(self.Rotors.Front) then
			self.Rotors.Front:Remove()
			self.Rotors.Front = nil
		end
	end
	if back then
		if IsValid(self.Rotors.Back) then
			self.Rotors.Back:Remove()
			self.Rotors.Back = nil
		end
	end
end



function ENT:PropMotion()
	if IsValid(self.Rotors.Front) then
		local phys = self.Rotors.Front:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity( Vector(0,0, (self.Rotors.FrontSpeed*-1) ) )
		end
	end
	
	if IsValid(self.Rotors.Back) then
		local phys = self.Rotors.Back:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity(Vector(0, self.Rotors.BackSpeed, 0) )
		end
	end
end

function ENT:StartupMotion()
	if IsValid(self.Rotors.Front) then
		local phys = self.Rotors.Front:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity( Vector(0,0, (self.Rotors.FrontSpeed * -0.1) ) )
		end
	end
	if IsValid(self.Rotors.Back) then
		local phys = self.Rotors.Back:GetPhysicsObject()
		if phys:IsValid() then
			phys:AddAngleVelocity(Vector(0, (self.Rotors.BackSpeed * 0.05), 0) )
		end
	end
end

/*
--###------#----####-----###---#####-#####--####-
-#---#----#-#---#---#---#---#--#-------#---#----#
#-----#---#-#---#----#-#-----#-#-------#---#-----
#---------#-#---#----#-#-------#####---#----##---
#---###--#---#--#----#-#---###-#-------#------##-
#-----#--#####--#----#-#-----#-#-------#--------#
-#---#--#-----#-#---#---#---#--#-------#---#----#
--###---#-----#-####-----###---#####---#----####-

*/

function ENT:SetGear(down)
	self.geardown = down
end

function ENT:PostSpawn()
	self.BaseClass.PostSpawn(self)
	
	if self.AVehicle_Creator and IsValid(self.AVehicle_Creator) then
		if self.Rotors.Front and self.Rotors.Back and IsValid(self.Rotors.Front) and IsValid(self.Rotors.Back) then
			self.Rotors.Front:SetPhysicsAttacker(self.AVehicle_Creator)
			self.Rotors.Back:SetPhysicsAttacker(self.AVehicle_Creator)
		end
	end
	
end

--New function for child entities to use. @ Warkanum
function ENT:PlayerEntered(ply)
	if not self.IsBadlyDamaged then
		timer.Simple(3.0, function()
			if IsValid(ply) and IsValid(self) then
				if self.RotorEngine.hovermode then
					ply:PrintMessage( HUD_PRINTCENTER, "Hovermode is on, to fly faster turn it off!")
				end
			end
		end)
	end
end

--New function for child entities to use. @ Warkanum
function ENT:PlayerExited(ply)

end

--Request from flyboy to override explode behaviour. @ Warkanum
function ENT:DoExplode()
		--Effect
	if not self.Damage.HasExpleded then
		self.Damage.HasExpleded = true
		self.RotorToEngineSpeed = 0 --So we can make out of control effect.
		self:SetNWBool("Crashed", true)
		--self:EjectAll()
		
		local effect = EffectData( )
		effect:SetScale( 3 )
		effect:SetMagnitude( 2 )
		effect:SetOrigin( self:GetPos( ) )
		util.Effect("effect_avehicle_helidamage", effect)
		
		self:SetColor(Color(100,100,100,255))
		
		if IsValid(self.Rotors.Back) then
			constraint.RemoveAll(self.Rotors.Back)
			--self.Rotors.Back:Remove()
		end
		
		timer.Simple(6.0, function() 
			if IsValid(self) then
				self.IsBadlyDamaged = true
				self:StopEngine()
				if IsValid(self.Rotors.Front) then
					constraint.RemoveAll(self.Rotors.Front)
				end
			end
		end)
		--util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), self.Damage.ExplodeRadius, self.Damage.ExplodeDamage)  --I get a tack overflow error, why?
		
		--self:CreateGibs()
		--self.Entity:Remove()
	end
end

/*
----#----######----#----####----###---#----#--####-
---#-#---##-------#-#---#---#--#---#--##---#-#----#
#--#-#--#-#-------#-#---#---#-#-----#-#-#--#-#-----
#--#-#--#-#####---#-#---#---#-#-----#-#-#--#--##---
#-#---#-#-#------#---#--####--#-----#-#--#-#----##-
#-#---#-#-#------#####--#-----#-----#-#--#-#------#
-#-----#--#-----#-----#-#------#---#--#---##-#----#
-#-----#--#####-#-----#-#-------###---#----#--####-
*/

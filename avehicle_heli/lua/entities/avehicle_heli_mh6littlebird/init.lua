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
		phys:SetMass(6000)
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
	self.Rotors.FrontSpeed = 480
	self.Rotors.BackSpeed = 280
	
	self:CreateRotors()
	--self:SpawnWeaponCannon()
	
	--self:WeaponPostAdd(0,"Missile",function() self:WepFireMissile() end,nil)
end

/*
missilefireflag = true
function ENT:WepFireMissile()
	if missilefireflag then
		missilefireflag = false
		self:ShootMissile()
		timer.Simple(1, function() 
			missilefireflag = true
		end)
	end
end
*/

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
	/*
	if self.WCannon then
		if self.PilotWeaponControl then
			if IsValid(self.Passengers[0]) then
				local fangle = self:GetForward():Angle()
				if (self:GetClientThirdPersonView(self.Passengers[0]) == 2) then
					self.WCannon:SetAngles(fangle)
				else
					local view = self.Passengers[0]:GetAimVector():Angle()
					local vview = view + Angle(0, 0,0)-- + (self:GetAngles() + )
					vview.p = math.Clamp(vview.p, fangle.p - 90, fangle.p + 90)
					vview.y = math.Clamp(vview.y, fangle.y - 90, fangle.y + 90)
					--vview.r = math.Clamp(vview.r, fangle.r - 60, fangle.r + 60)
					self.WCannon:SetAngles(vview)
				end
			end
		else
			if IsValid(self.Passengers[1]) then
				local fangle = self:GetForward():Angle()
				if (self:GetClientThirdPersonView(self.Passengers[1]) == 2) then
					self.WCannon:SetAngles(fangle)
				else
					local view = self.Passengers[1]:GetAimVector():Angle()
					local vview = view + Angle(0, 0,0)-- + (self:GetAngles() + ) 
					vview.p = math.Clamp(vview.p, fangle.p - 90, fangle.p + 90)
					vview.y = math.Clamp(vview.y, fangle.y - 90, fangle.y + 90)
					self.WCannon:SetAngles(vview)
				end
			end
		end
	end
	*/
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

function ENT:CreateGibs()
	local gibs = {}
	local i = 0
	local TimeToLive = 8
	local velocity = self:GetVelocity()
	for _,v in pairs(self.GibsModels) do
		i = i + 1
		local model = v
		local e = ents.Create("prop_physics")
		e:SetPos(self.Entity:GetPos())
		e:SetAngles(self.Entity:GetAngles())
		e:SetModel(model)
		e:PhysicsInit(SOLID_VPHYSICS)
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetSolid(SOLID_VPHYSICS)
		e:SetCollisionGroup(COLLISION_GROUP_WORLD)
		e:Activate()
		e:Spawn()
		e:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000)
		e:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000)
		e:Ignite(10,70)
		table.insert(gibs,e)
	end
		
	timer.Simple(TimeToLive, function()
		if gibs then
			for k,v in pairs(gibs) do
				if IsValid(v) then
					v:Extinguish()
					v:Remove()
				end
			end
		end
	end)
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
	self.Rotors.Front = ents.Create( "avehicle_mh6littlebird_rotor" )
	--self.Rotors.Front:SetModel(self.Models.RotorBase)
	self.Rotors.Front:SetName("Heli Rotor")
	self.Rotors.Front:SetOwner(self.Owner)
	self.Rotors.Front.Heli = self
	self.Rotors.Front:SetAngles(self.Entity:GetAngles())
	self.Rotors.Front:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * 100) + (self.Entity:GetForward() * -5))
	self.Rotors.Front:Spawn()

	self.Rotors.Back = ents.Create("prop_physics")
	self.Rotors.Back:SetModel(self.Models.RotorTail)
	self.Rotors.Back:SetName("Heli Back Rotor")
	self.Rotors.Back:SetAngles(self.Entity:GetAngles())
	self.Rotors.Back:SetPos(self.Entity:GetPos() + (self.Entity:GetUp() * 74)  + (self.Entity:GetForward() * -216) + (self.Entity:GetRight() * -10)) --330.2450 6.6013 135.5856
	self.Rotors.Back:SetOwner(self.Owner)
	self.Rotors.Back:Spawn()
	self.Rotors.Back.IsAVehicleObject = true
	local rotorphys = self.Rotors.Back:GetPhysicsObject()
	if rotorphys and rotorphys:IsValid() then
		rotorphys:SetDamping(0,1.0)
	end

	--Constraint prop
	constraint.Axis( self.Entity, self.Rotors.Front, 0, 0, Vector(-5,0,95), Vector(0,0,0) , 0, 0, 1, 1)	
	constraint.Axis( self.Entity, self.Rotors.Back, 0, 0, Vector(-216,-16,74) , Vector(0,0,0), 0, 0, 1, 1)
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
			phys:AddAngleVelocity(Vector(0,(self.Rotors.BackSpeed), 0) )
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
			phys:AddAngleVelocity(Vector(0,(self.Rotors.BackSpeed * 0.1), 0) )
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
function ENT:ToggelDoor()
	if self.DoorOpen then
		self:DoorAnimations(false)
	else
		self:DoorAnimations(true)
	end
end

function ENT:DoorAnimations(open)
	if self.IsAnimating then return false end
	local ANIMATION_TIME = 1.5
	self:EmitSound(self.Sounds.DoorSnd, 100, 100)
	self.Entity:SetPlaybackRate(1)
	if (open) then
		if not self.DoorOpen then
			local sequence_d = self.Entity:LookupSequence("door_o")
			self.Entity:SetCycle(0)
			self.Entity:SetSequence(sequence_d)
			self.IsAnimating = true
			timer.Simple(self.Entity:SequenceDuration()-0.3, function() 
				if IsValid(self) then
					self.DoorOpen = true
					local seq_o = self.Entity:LookupSequence("idle_o")
					self.Entity:SetCycle(0)
					self.Entity:SetSequence(seq_o)
					self.Entity:ResetSequence(seq_o)
					self.IsAnimating = false
				end
			end)
		end
	else
		if self.DoorOpen then
			local sequence_d = self.Entity:LookupSequence("door_c")
			self.Entity:SetCycle(0)
			self.Entity:SetSequence(sequence_d)
			self.IsAnimating = true
			timer.Simple(self.Entity:SequenceDuration()-0.3, function()
				if IsValid(self) then
					self.DoorOpen = false
					local cseq = self.Entity:LookupSequence("idle")
					self.Entity:SetCycle(0)
					self.Entity:SetSequence(cseq)
					self.Entity:ResetSequence(cseq)
					self.IsAnimating = false
				end
			end)
		end
	end
	return true
end

function ENT:SetGear(down)
	self.geardown = down
end

function ENT:PostSpawn()
	self.BaseClass.PostSpawn(self)
	self:DoorAnimations(true) --Open the doors!
	
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
		effect:SetScale( 2 )
		effect:SetMagnitude( 1.5 )
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

function ENT:SpawnWeaponCannon()
	local e = ents.Create( "avehicle_cannon_a2" )
	e:SetModel("models/props_c17/canister02a.mdl ") 
	e:SetSolid( SOLID_VPHYSICS )
	e:SetMoveType( SOLID_VPHYSICS )
	e:PhysicsInit( SOLID_VPHYSICS )
	e:SetPos( self:GetPos() + (self:GetForward() * 100) + (self:GetUp() * 20) )
	e:SetAngles(self:GetAngles() + Angle(0,0,0))
	e:SetOwner(self.Entity)
	e:Spawn()
	e:Activate()
	e:SetCollisionGroup(COLLISION_GROUP_WORLD)
	e.phys = e:GetPhysicsObject()
	if (e.phys:IsValid()) then
		e.phys:Wake()
		e.phys:SetMass(2)
	end
	e:SetParent(self.Entity)
	e.IsAVehicleObject = true
	self.WCannon = e
end

/*
function ENT:ShootMissile()
	local Msl = ents.Create( "avehicle_huey_missile" )
	Msl:SetPos( self.Entity:GetPos() + (self.Entity:GetUp() * -1) + (self.Entity:GetForward() * 30)) 
	local NewAng = self.Entity:GetAngles() + Angle(90,0,0)
	NewAng.Roll = 0
	Msl:SetAngles(NewAng)				
	Msl:Spawn()
	Msl:Activate() 
	Msl:GetPhysicsObject():SetVelocity( (self.Entity:GetVelocity():Length() * self.Entity:GetForward()) )
	Msl:GetPhysicsObject():Wake()
end*/
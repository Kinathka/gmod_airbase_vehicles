AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:Initialize()
	self.BaseClass.Initialize(self)

	--self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.Fired = false
	self.LastFireTime = 0
	self.ExplodeD =  CurTime() + self.ExpDel
	self.MForceDel = CurTime() --CurTime() + self.FrcDel
	self.FSnd = CreateSound(self.Entity,"Avehicle_Rocket.Fire")
	
	self.MaxOfMyself = self.CopiesBeforeSelfEject or 10
	self.CanFire = true
	self.MountedHealth = self.MaxMountedHealth
	self.LastTarget = self:GetForward() * 1000
	self.LastUseFire = 0
	self.LifeTime = self.LifeTime or 0
	self.LinkedMissile = nil
	self.LinkedMissileAttempt = nil
end


--The setupmod must be called before calling ENT:Spawn() @Warkanum
--This sets the model to use when firering a rocket.
function ENT:SelfSetup(mode)
	--if (mode == 1) then
	--	self.Entity:SetModel("models/props_phx/box_amraam.mdl")
	--else
		self.Entity:SetModel("models/props_phx/amraam.mdl")
	--end
	self.Entity:SetName("Missile")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetColor(Color(255,255,255,255))
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		if (mode == 1) then
			phys:SetMass(50)
		else
			phys:SetMass(300)
		end
	end
end

function ENT:FireMyself()
	--constraint.RemoveAll(self) --Free us so we can move.
	--if IsValid(self:GetParent()) then self:SetParent(nil) end
	local veh = self:GetAVehicle()
	if veh and not self.FireCopy then
		veh:HardpointRelease(self.AVehicle_hpid)
	end
	
	local finalpos = self.Entity:GetForward() * 90000
	if veh then
		finalpos = veh:GetForward() * 90000
	end
	--Get all near entities of self and ignore them
	local forwardEnt = ents.FindInCone(self:GetPos(), self:GetForward(), 65535, 30)
	local selfClassEnts = {}
	cnt = 0;
	for k,v in pairs(forwardEnt) do
		cnt = cnt + 1;
		selfClassEnts[cnt] = v
	end
	traceRes = util.QuickTrace(self:GetPos()+self:GetForward()*500, finalpos, table.Add({self.Entity, self:GetAVehicle()}, selfClassEnts))
	self.LastTarget = traceRes.HitPos
	
	--self.LastTarget = self:GetVehicleAim(self:GetVehicleInstalledPod())
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:EnableCollisions(true)
	end
	
	local veh = self:GetAVehicle()
	if veh then
		self:SetOwner(veh)
		self:SetVelocity(veh:GetVelocity())
	end
	
	self.Fired = true
	self.Exploded = false
	
	self.LifeTime = CurTime() + self.MaxLifeTime
	
	ftr = ents.Create("env_fire_trail")
	ftr:SetAngles( self.Entity:GetAngles()  )
	ftr:SetPos( self.Entity:GetPos() + self.Entity:GetForward() * (-115))
	ftr:SetParent(self.Entity)
	ftr:Spawn()
	ftr:Activate()
	self:DeleteOnRemove(ftr)
			
	local startWidth = 10
	local endWidth = 2
	util.SpriteTrail(self.Entity, 0, Color(200,200,200,255), false, startWidth, endWidth, 
					0.3, 1/(startWidth+endWidth)*0.5, "trails/smoke.vmt")
	
	self.ExplodeD =  CurTime() + self.ExpDel
	self.MForceDel = CurTime() --CurTime() + self.FrcDel
	
	self.FSnd:Play()
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD) --So we don't collide with our vehicle
end

function ENT:MakeFireCopy()
	if self.MaxOfMyself >= 1 then
		local ent = ents.Create( "avehicle_hp_rocketa1" )
		ent:SelfSetup(0)
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:Spawn()
		ent:Activate()
		ent:SetOwner(self)
		ent:SetVelocity(self:GetVelocity())
		ent.HardPointInstalled = true --Just so we don't bring up the gui if we collide with a vehicle.
		ent.FireCopy = true
		ent:FireMyself()
		ent.AVehicle_Creator = self.AVehicle_Creator
		ent.LifeTime = CurTime() + ent.MaxLifeTime
		self.MaxOfMyself = self.MaxOfMyself - 1
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD) --So we don't collide with our vehicle
	else
		--self:FireMyself()
		self:EmitSound("ambient/levels/citadel/pod_close1.wav", 100, 100)
		timer.Simple(self.FireTime , function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
end

function ENT:DoFire()
	if IsValid(self.LinkedMissile) then
		self.LinkedMissile:DoFire()
	end
	if self.CanFire then
		self.CanFire = false
		self:MakeFireCopy()
		self.Entity:SetColor(Color(255,255,255,200))
		timer.Simple(self.FireTime , function()
			if IsValid(self) then
				self.CanFire = true
				self:EmitSound("ambient/levels/citadel/pod_open1.wav", 100, 100)
				self.Entity:SetColor(Color(255,255,255,255))
			end
		end)
	end
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_rocketa1" )
	ent:SelfSetup(1)
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	
	return ent
	
end

function ENT:DoExplode(dodamage)
	if not self.Exploded then
		self.Exploded = true
		local e = ents.Create("env_explosion")
		e:SetKeyValue("spawnflags",1)
		e:SetKeyValue("flags",1)
		e:SetKeyValue("magnitude", 2)
		e:SetKeyValue("scale", 2)
		e:SetPos(self.Entity:GetPos())
		e:Spawn()
		e:Fire("explode","",0)
		e:Fire("kill", "", 10)
		
		local pe = ents.Create("env_physexplosion")
		pe:SetPos(self.Entity:GetPos())
		pe:SetParent(self.Entity)
		pe:SetKeyValue("magnitude", 300)
		pe:SetKeyValue("radius", 200)
		pe:SetKeyValue("spawnflags", "19")
		pe:SetKeyValue("flags", "19")
		pe:Spawn()
		pe:Fire("Explode", "", 0)
		pe:Fire("kill", "", 5)
		if dodamage then
			util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 500, self.Damageamount)
		else
			util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 10, self.Damageamount)
		end
		return true
	end
	return false
end


function ENT:PhysicsCollide( data, phys )
	if self.Fired then
		if self.ExplodeD < CurTime() then
			self.Entity:SetCollisionGroup(3)
						
			if self:DoExplode(true) then
				self.Entity:Remove()
			end
		end
	end
end

function ENT:StartTouch(hitEnt)
	 if self.Fired then
		if self.ExplodeD < CurTime() then
			--Special for shields. We explode, not deflect!
			if ( IsValid(hitEnt) and ((hitEnt:GetClass() == "shield") 
				or (hitEnt:GetClass() == "avehicle_sg_shield") or (hitEnt:GetClass() == "shield*") )) then
				
				if self:DoExplode(false) then
					self.Entity:Remove()
				end
			end
		end
	end
	
end

function ENT:Think()
	if self.Fired then
		local phys = self.Entity:GetPhysicsObject()
		phys:Wake()
		if self.ExplodeD < CurTime() then
			self.Entity:SetCollisionGroup(3)
			
			if self.LifeTime < CurTime() then
				if self:DoExplode(true) then
					self.Entity:Remove()
				end
			end
		end
	end
	self.BaseClass.Think(self)
end


function ENT:PhysicsUpdate(phys)
	if self.Fired then
		if self.MForceDel < CurTime() then
			local ang = (self.LastTarget - self:GetPos()):Angle()
			phys:SetVelocity(self.Entity:GetForward() * 3500)
			--phys:ApplyForceCenter(self.Entity:GetUp() * phys:GetMass() * 100)
			--phys:AddAngleVelocity(ang)
			phys:SetAngles(self.HardPointAngleAdd +  ang)
			--phys:SetAngles(self:GetUp():Angle() +  ang)
		end
	end
end

function ENT:OnTakeDamage(dmg)
	self.MountedHealth = self.MountedHealth - dmg:GetDamage()
	if self.MountedHealth <= 0 and not self.Fired then
		if self:DoExplode(true) then
			self.Entity:Remove()
		end
	elseif self.Fired and (dmg:GetDamage() > 100) then
		if IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "avehicle_hp_rocketa1" then return end --Don't kill ourselfs.
		if self:DoExplode(true) then
			self.Entity:Remove()
		end
	end
end

function ENT:Use(ply)
	if self.HardPointInstalled then return end
	if self.LastUseFire < CurTime() then
		self.LastUseFire = CurTime() + 1.0
		self:DoFire()
	end
end

function ENT:OnRemove()
	self.FSnd:Stop()
end

function ENT:Touch( ent )
	if IsValid(ent) and (ent:GetClass() == "avehicle_hp_rocketa1") and not self.HardPointInstalled and not ent.HardPointInstalled then
		self.LinkedMissileAttempt = ent
		if (self.LinkedMissileAttempt == ent) then
			ent.LinkedMissile = nil
			ent.LinkedMissileAttempt = nil
			self.LinkedMissile = ent
			
			local effectdata = EffectData()
			effectdata:SetStart(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetScale(1)
			util.Effect( "propspawn", effectdata )	
			
		end
	else
		self.LinkedMissileAttempt = nil
		return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
	end
end



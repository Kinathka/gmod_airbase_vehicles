
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound is run on Sound() function
util.PrecacheModel("models/airboatgun.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/airboatgun.mdl" ) --This damn model has no physics. :-( So we create some.
	self.Entity:SetName("Cannon AR1")
	--self.Entity:PhysicsInit( SOLID_VPHYSICS )
	local lowerBound = Vector(-20, -10, -5)
	local upperBound = Vector(20, 10, 5)
	self.Entity:PhysicsInitBox(lowerBound, upperBound)
	self.Entity:SetCollisionBounds(lowerBound, upperBound)
	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_BBOX )
	self.Entity:DrawShadow(false)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
	end
	--self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.HeatAmount = 0
	self.LastFireTime = 0
	self.FireSound = self.FireSound or Sound("Avehicle_cannon_a1.Shoot")
	self.Attacker = self
	self.lastviewupdate = 0
	self.LastAngle = Angle(0,0,0)
	self.Active = false

end

/*
self.PrimaryActive
self.SecondaryActive
*/
function ENT:SetAttackEnt(ent)
	if IsValid(ent) then
		self.Attacker = ent
	end
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_cannon_ar1" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	if self.AVehicle_HardPointKind == AVehicles.Types.HARDPOINT_AIMABLE then
		local podindex = self:GetVehicleInstalledPod()
		if podindex >= 0 then
			local veh = self:GetAVehicle()
			if veh  then
				local aim = self:GetVehicleAim(podindex)
				local dif = (aim - self:GetPos())
				local ang = dif:Angle()
				if self.AVehicle_InstallOptions and self.AVehicle_InstallOptions.ballsoc then
					self.LastAngle = ang
				elseif self.AVehicle_InstallOptions and self.AVehicle_InstallOptions.parent then
					self:SetAngles(ang)
				end
				--veh:TargetLazer(podindex, true, aim) I don't like this lazer. Blah
			end
		end
	end
	if self.Active then
		self:DoFire()
	end
	
	return self.BaseClass.Think(self)
end

function ENT:DoFire()
	if self.LastFireTime < CurTime()  then --and self.HeatAmount < 100
		self.LastFireTime = CurTime() + self.FireTime 
		local vStart = self.Entity:GetPos()
		local vForward = self.Entity:GetForward()
		--self.HeatAmount = self.HeatAmount + self.HeatUpSpeed
		local Bullet = {}
		Bullet.Num = 1
		Bullet.Src = self.Entity:GetPos() + (self.Entity:GetForward() * 80)
		Bullet.Dir = self.Entity:GetForward() --Position * -1
		Bullet.Spread = self.SpreadVec or Vector( 0.02, 0.02, 0.03 )
		Bullet.Tracer = self.Tracers  or 1
		Bullet.Force = self.Forceamount or 30
		Bullet.TracerName = self.TracerName or "Tracer"
		Bullet.AmmoType = "Ar2" 
		Bullet.Attacker = self.Attacker
		Bullet.Damage = self.Damageamount or 60
		
		--Bullet.Callback = function (attacker, tr, dmginfo)
		--end
		
		util.ScreenShake(self:GetPos(), 2.0, 40.0, self.FireTime , 100)
		
		self.Entity:FireBullets(Bullet)
		self.Entity:EmitSound(self.FireSound, 100,100)
		
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "RifleShellEject", effectdata ) --ShellEject
		
		local muzzle = self.Entity:GetAttachment(self.Entity:LookupAttachment("muzzle"))
		local mpos = muzzle.Pos or (self:GetPos()+self:GetForward() * 62)
		local e = EffectData()
		e:SetStart(mpos)
		e:SetOrigin(mpos)
		e:SetEntity( self )
		e:SetScale(0.3)
		e:SetMagnitude(0.3)
		e:SetAttachment(1)
		util.Effect( "AirboatMuzzleFlash", e )
		
		local smoke = EffectData()
		smoke:SetStart(mpos + self:GetForward() * -30)
		smoke:SetOrigin(mpos + self:GetForward() * -30)
		smoke:SetEntity(self)
		smoke:SetScale(0.4)
		smoke:SetMagnitude(0.35)
		smoke:SetAttachment(1)
		util.Effect( "effect_av_lightsmokes", smoke )
	end
end


function ENT:Use( activator, caller )
	--For Test
	if self.HardPointInstalled then return end
	if not self.Active then
		self.Active = true
		timer.Simple(5.0, function() 
			if IsValid(self) then
				self.Active = false
			end
		end)
	end
end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
end
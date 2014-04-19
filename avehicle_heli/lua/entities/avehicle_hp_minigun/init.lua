
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--util.PrecacheSound is run on Sound() function
util.PrecacheModel("models/Flyboi/UH1YVenom/venomminigun_fb.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/Flyboi/UH1YVenom/venomminigun_fb.mdl" ) 
	self.Entity:SetName("Minigun")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:DrawShadow(false)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
	end
	--self.Entity:SetKeyValue("rendercolor", "255 255 255")
	self.HeatAmount = 0
	self.LastFireTime = 0
	self.Attacker = self
	self.lastviewupdate = 0
	self.LastAngle = Angle(0,0,0)
	self.Active = false
	self.ReadyTime = 0
	self.ToggelTimer = true
	self.ReadyToFire = false
	self.IsAnimating = false
	self.OverHeated = false
	self.HeatBuild = 0
	if not (self.AlternativeSound) then
		self.ContFire = CreateSound(self.Entity, self.SoundList.Shoot)
		self.ContFire:SetSoundLevel(0.27) --SNDLVL_GUNFIRE=0.27
	end
	--self.Sounds = {}
	--self.Sounds.Fire = CreateSound()
	
	self.WepFiring = false
end


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_minigun" )
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
		self.Active = false
		if not self.ReadyToFire then
			if self.ToggelTimer then
				self.ToggelTimer = false
				self:StartAnimations(true)
				self:EmitSound(self.SoundList.Start, 100, 100)
				timer.Simple(self.StartUpTime, function()
					if IsValid(self) then
						self.ToggelTimer = true
						self.ReadyToFire = true
						if not (self.AlternativeSound) then
							self.ContFire:Play()
						end
					end
				end)
			end
		end

		self.ReadyTime = CurTime() + (self.StartUpTime / 2)--Startuptime is also used for cooldown time.
	end

	
	if self.ReadyToFire then
		if self.ReadyTime < CurTime() then
			self.ReadyToFire = false
			if not (self.AlternativeSound) then
				self.ContFire:Stop()
			end
			self:EmitSound(self.SoundList.Stop, 100, 100)
			self:StartAnimations(false)
		end
		
		self:StartWepFiring()
	else
		if self.HeatBuild > 1 then
			self.HeatBuild = self.HeatBuild - 1
			local col = 255-(self.HeatBuild / 1000 * 254)
			self:SetColor(Color(255,col,col,255))
			if self.HeatBuild < 900 then
				self.OverHeated = false	
				--self:SetColor(255,255,255,255)
			end
		end
	end
	
	return self.BaseClass.Think(self)
end

function ENT:DoFire()
	self.Active = true
end


function ENT:StartWepFiring()
	if self.LastFireTime <= CurTime()  then --and self.HeatAmount < 100
		self.LastFireTime = CurTime() + self.FireTime 
		
		if (self.HeatBuild >= 1000) then
			self.OverHeated = true
		elseif not (self.OverHeated) then
			self.HeatBuild = self.HeatBuild + 6 --Build heat on every shot.
			local col = 255-(self.HeatBuild / 1000 * 254)
			self:SetColor(Color(255,col,col,255))
		end
		
		if self.OverHeated then return end --Do not fire!!
	
		local vStart = self.Entity:GetPos()
		local vForward = self.Entity:GetForward()
		--self.HeatAmount = self.HeatAmount + self.HeatUpSpeed
		
		util.ScreenShake(self:GetPos(), 2.0, 40.0, self.FireTime , 100)
		
		local Bullet = {}
		Bullet.Num = 4
		Bullet.Src = self.Entity:GetPos() + (self.Entity:GetForward() * 80)
		Bullet.Dir = self.Entity:GetForward() --Position * -1
		Bullet.Spread = self.SpreadVec
		
		Bullet.Tracer = self.Tracers  or 1
		Bullet.Force = self.Forceamount or 30
		Bullet.TracerName = self.TracerName or "Tracer"
		Bullet.AmmoType = "Ar2" 
		Bullet.Attacker = self.Attacker
		Bullet.Damage = self.Damageamount or 60
		
		--Bullet.Callback = function (attacker, tr, dmginfo)
		--end
		
		self.Entity:FireBullets(Bullet)
		if self.AlternativeSound then
			self.Entity:EmitSound(self.SoundList.Fire, 100, 100)
		end
		
		local shellpos = self:GetPos() + (self:GetForward() * 10) + (self:GetUp() * 7)
		for j=1, 2 do --minigun has way more shells
			local effectdata = EffectData()
			effectdata:SetStart(shellpos)
			effectdata:SetOrigin(shellpos)
			util.Effect( "RifleShellEject", effectdata ) --ShellEject
		end
		
		
		local smoke = EffectData()
		local effpos = self:GetPos() + (self:GetForward() * -1) + (self:GetUp() * 10)
		smoke:SetStart(effpos)
		smoke:SetOrigin(effpos)
		smoke:SetEntity(self)
		smoke:SetScale(0.4)
		smoke:SetMagnitude(0.35)
		util.Effect( "effect_av_lightsmokes", smoke )

	end
end


function ENT:StartAnimations(on)
	--if self.IsAnimating then return false end
	/*
	--Disabled for now--
	if (on) then
		if self.IsAnimating then return false end
		local spin = self.Entity:LookupSequence("spin")
		self.Entity:SetCycle(0)
		self.Entity:SetSequence(spin)
		self.Entity:ResetSequence(spin)
		self.IsAnimating = true
		--self.Entity:SetPlaybackRate(1)
	else
		local idle = self.Entity:LookupSequence("idle")
		--self.Entity:SetCycle(0)
		self.Entity:SetSequence(idle)
		self.Entity:ResetSequence(idle)
		self.Entity:SetPlaybackRate(1)
		self.IsAnimating = false
	end
	*/
	return true
end


function ENT:Use( activator, caller )
	if activator and IsValid(activator) and activator:IsPlayer() then
		if not self.PrimaryActive then
			self:StartFiring()
		else
			self:StopFiring()
		end
	end
end

function ENT:OnRemove()
	if self.ContFire then
		if not (self.AlternativeSound) then
			self.ContFire:Stop()
		end
	end
end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
end
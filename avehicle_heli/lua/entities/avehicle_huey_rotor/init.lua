AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/Flyboi/Huey/hueyrotorm_fb.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if IsValid(self.Heli) then
		self:SetOwner(self.Heli)
	end
	self.ActiveAngleSpeed = 400
	self.ImpactSound = CreateSound(self, "npc/manhack/grind5.wav")
	self.PhysObj = self:GetPhysicsObject()
	
	if ( self.PhysObj:IsValid() ) then
		self.PhysObj:EnableGravity(true)
		self.PhysObj:EnableDrag(true)
		--self.PhysObj:SetDamping(0,10.0)
		self.PhysObj:Wake()
	
	end
	self.IsAVehicleObject = true

end

function ENT:PhysicsCollide( data, physobj )
	
	if ( data.Speed > 350 && data.DeltaTime > 0.2 ) then 
		
		if IsValid(self.Heli) then
			if( data.Speed > 12500 ) then
				self.Heli:DamageHurt(8000, "rotor")
			end

			for i =1, 6 do
				local e = EffectData()
				e:SetOrigin( data.HitPos )
				e:SetNormal( data.HitNormal + Vector( math.random(-12,12), math.random(-12,12), 4 ) )
				e:SetScale( 20 )
				util.Effect("ManhackSparks", e)
				self.ImpactSound:PlayEx( 1.0, math.random( 100, 120 ) )
			end
			
			if IsValid(data.HitEntity) and (data.HitEntity:IsWorld() or data.HitEntity:GetClass() == "worldspawn") then
				self.Heli:DamageHurt(4000, "rotor")
			end
			
			if IsValid(data.HitEntity) and not (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) then
				if IsValid(physobj) and !physobj:IsMoveable() then
					self.Heli:DamageHurt(math.random(50,physobj:GetMass()/10), "rotor")
				elseif IsValid(physobj) then
					self.Heli:DamageHurt(math.random(1,physobj:GetMass()/50), "rotor")
				end
			end
		
		end

		
	else		
		self.ImpactSound:FadeOut( 0.25 )

	end

end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		if phys:GetAngleVelocity():Length() > self.ActiveAngleSpeed then
			self:SetNWBool("rotor_online", true)
		else
			self:SetNWBool("rotor_online", false)
		end
	end
	
	self.Entity:NextThink( CurTime() + 0.5 )
	return true
end
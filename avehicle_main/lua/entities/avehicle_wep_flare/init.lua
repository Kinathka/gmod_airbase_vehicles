AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:Initialize()
	self.Entity:SetModel(self.ObjModel)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )	
	self.Entity:SetSolid( SOLID_VPHYSICS )
	--self.Entity:SetGravity( 0.01 )
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.TimeToLive = 25.0
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	if (self.PhysObj:IsValid()) then
		self.PhysObj:SetDamping( 2.0, 0)
		self.PhysObj:Wake()
		self.PhysObj:EnableDrag(true)
		self.PhysObj:EnableGravity(true)
		self.PhysObj:SetMass(15)
		
	end
	
	
	
	util.SpriteTrail(self, 0, Color(0,0,0,255), false, 22, math.random(45,58), 2, 1 / 32 * 0.5, "trails/smoke.vmt");  
	self.AmbientSound = CreateSound(self.Entity, "weapons/flaregun/burn.wav")
	self.AmbientSound:PlayEx(0.5, 100)

	
	timer.Simple(self.TimeToLive, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
	
end


function ENT:OnRemove()
	if self.AmbientSound then
		self.AmbientSound:Stop()
	end
end

function ENT:Think()

	local effect = EffectData()
	effect:SetOrigin( self:GetPos() )
	effect:SetScale(0.5)
	util.Effect("effect_avehicle_flaresparks", effect)
end

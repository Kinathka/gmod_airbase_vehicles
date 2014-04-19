
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/props_borealis/bluebarrel001.mdl" ) 
	self.Entity:SetName(self.PrintName)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Buoyancy = 1200
	self.VehicleBuoyancy = 1.0
	--self.Entity:SetSkin(1)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(400)
		phys:SetBuoyancyRatio(self.Buoyancy)
		phys:EnableDrag(false)
		phys:EnableGravity(true)
		--phys:EnableGravity( false )
	end

end

function ENT:FinishedInstall(veh)
	local newmas = 500
	if IsValid(veh) then
		local phys = veh:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetBuoyancyRatio(self.VehicleBuoyancy)
			newmas = phys:GetMass() / 8
		end
	end
	local lphys = self.Entity:GetPhysicsObject()
	if (lphys:IsValid()) then
		lphys:SetMass(newmas)
		lphys:SetBuoyancyRatio(self.Buoyancy)
	end
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create(self.AVEntClassname)
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()

end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent)
end
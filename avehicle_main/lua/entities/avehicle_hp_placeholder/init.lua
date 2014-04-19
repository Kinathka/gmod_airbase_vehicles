AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheModel("models/airboatgun.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/Items/car_battery01.mdl" )
	self.Entity:SetMaterial("models/props_combine/metal_combinebridge001")
	self.Entity:SetName("Placehold Wired")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	--local lowerBound = Vector(-20, -10, -5)
	--local upperBound = Vector(20, 10, 5)
	--self.Entity:PhysicsInitBox(lowerBound, upperBound)
	--self.Entity:SetCollisionBounds(lowerBound, upperBound)
	--self.Entity:SetSolid( SOLID_BBOX )
	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
	end

	self.lastviewupdate = 0
	self.LastAngle = Angle(0,0,0)
	
	self:WireCreateSpecialOutputs(
		{ "AimVector", "Fire", "AltFire", "IsIn"}, 
		{ "VECTOR", "NORMAL", "NORMAL", "NORMAL"},
		{ "Vector where player aims.", "Trigger when firing.", "Trigger when alt firing.", "Is there someone controlling this?"}
	)
	
	--self:WireCreateSpecialInputs({"Engine"}, {"NORMAL"}, {"Toggel the engine!"})
	
end



function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_placeholder" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:Think()
	local podindex = self:GetVehicleInstalledPod()
	if podindex >= 0 then
		local veh = self:GetAVehicle()
		if veh  then
			self:WireTriggerOutput("AimVector", self:GetVehicleAim(podindex))
		end
		
		if veh.Passengers[podindex] and IsValid(veh.Passengers[podindex]) then
			self:WireTriggerOutput("IsIn", 1)
		else
			self:WireTriggerOutput("IsIn", 0)
		end
	end
end

local lastfireflag = true
function ENT:DoFire()
	if lastfireflag then
		lastfireflag = false
		self:WireTriggerOutput("Fire", 1)
		timer.Simple(0.01, function()
			lastfireflag = true
			self:WireTriggerOutput("Fire", 0)
		end)
	end
end

local lastafireflag = true
function ENT:DoAltFire()
	if lastafireflag then
		lastafireflag = false
		self:WireTriggerOutput("AltFire", 1)
		timer.Simple(0.01, function()
			lastafireflag = true
			self:WireTriggerOutput("AltFire", 0)
		end)
	end
end

function ENT:Use( activator, caller )
	
end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
end
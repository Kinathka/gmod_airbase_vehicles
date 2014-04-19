AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheModel("models/airboatgun.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/props_wasteland/panel_leverHandle001a.mdl" )
	--self.Entity:SetMaterial("models/props_combine/metal_combinebridge001")
	self.Entity:SetName("Pickup")
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
		phys:SetMass(phys:GetMass() + 100)
		phys:EnableDrag(false)
	end

	self.lastviewupdate = 0
	self.LastAngle = Angle(0,0,0)
	self.SearchSettings = {}
	self.SearchSettings.distance = 1400
	self.SearchSettings.startdist = 200
	self.SearchSettings.searcharea = 150
	self.SearchSettings.direction = self:GetUp() * -1
	self.AdditionalRope = 50
	self:WireCreateSpecialOutputs(
		{ "AimVector", "Locked", "AltFire", "IsIn"}, 
		{ "VECTOR", "NORMAL", "NORMAL", "NORMAL"},
		{ "Vector where player aims.", "Trigger when firing.", "Trigger when alt firing.", "Is there someone controlling this?"}
	)
	
	--self:WireCreateSpecialInputs({"Engine"}, {"NORMAL"}, {"Toggel the engine!"})
	self.LockedEntities = {}
	self.LockedContraints = {}
	self.hasLocked = false
	self.LastFireTime = 0
	self.LastFireTime2 = 0
end



function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_pickup" )
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
			self:WireTriggerOutput("AimVector", (self:GetForward() * 1000))
		
		
			if veh.Passengers[podindex] and IsValid(veh.Passengers[podindex]) then
				self:WireTriggerOutput("IsIn", 1)
			else
				self:WireTriggerOutput("IsIn", 0)
			end
		
		end
	end
end

local function FilterAvehiclesStuff(aents)
	local newents = {}
	for k,v in pairs(aents) do
		if v and not v.IsAVehicleObject and  (v.IsAVehicle or (v.IsAVehicleAttachable and not v.HardPointInstalled) or ((v:IsVehicle() 
			and not v.IsAvehiclePod and not v.isAVehicleSeat) or (v:GetClass() =="prop_physics"))) then
			table.insert(newents, v)
		end
	end
	return newents 
end

function ENT:FindEntities()
	local fents = {}
	local startpos = self:GetPos() + self.SearchSettings.direction * self.SearchSettings.startdist
	--fents = ents.FindInCone(startpos,self.SearchSettings.direction, self.SearchSettings.distance, self.SearchSettings.fov);
	local tracedata = {}
	tracedata.start = startpos
	tracedata.endpos = startpos + self.SearchSettings.direction*self.SearchSettings.distance
	tracedata.filter = {self.Owner, self.Entity, self:GetAVehicle()}
	local trace = util.TraceLine(tracedata)
	
	fents = FilterAvehiclesStuff(ents.FindInSphere(trace.HitPos,self.SearchSettings.searcharea))
	
	return fents
end

function ENT:AttachEntities(entities)
	for k,v in pairs(entities) do
		if IsValid(v) and not v:IsWorld() then
			local phys = v:GetPhysicsObject()
			if phys and phys:IsValid() and phys:IsMoveable() then
				local dist = (self:GetPos() - v:GetPos()):Length()
				self.LockedEntities[k] = v
				local cstr, erope = constraint.Rope(self.Entity, v, 0, 0, Vector(0,0,0), Vector(0,0,0), dist+10, self.AdditionalRope, 0, 2, "cable/rope", false)
				self.LockedContraints[k] = cstr
			end
		end
	end
	return true
end

function ENT:DetachAllEntities()
	for k,v in pairs(self.LockedContraints) do
		if IsValid(v) then
			v:Remove()
		end
		self.LockedEntities[k] = nil
	end
end


function ENT:DoFire()
	if self.LastFireTime < CurTime() then
		self.LastFireTime = CurTime() + 1.0
		
		local veh = self:GetAVehicle()
		local podindex = self:GetVehicleInstalledPod()
		if veh and  veh.Passengers[podindex] and IsValid(veh.Passengers[podindex]) then
			if self.hasLocked then
				self:DetachAllEntities()
				self.hasLocked = false
				self:WireTriggerOutput("Locked", 0)
				self:EmitSound("vehicles/crane/crane_magnet_release.wav", 100, 100)
				veh.Passengers[podindex]:PrintMessage( HUD_PRINTCENTER, "Objects released!")
			else
				local et = self:FindEntities()
				--MsgN("entities")
				--PrintTable(et)
				if table.Count(et) > 0 then
					self:AttachEntities(et)
					self.hasLocked = true
					self:WireTriggerOutput("Locked", 1)
					self:EmitSound("vehicles/crane/crane_magnet_switchon.wav", 100, 100)
					veh.Passengers[podindex]:PrintMessage( HUD_PRINTCENTER, tostring(table.Count(et)).." objects attached!")
				end
			end
		end

	end

end


function ENT:DoAltFire()
	if self.LastFireTime2 < CurTime() then
		self.LastFireTime2 = CurTime() + 0.2
		self:WireTriggerOutput("AltFire", 1)
		timer.Simple(0.01, function()
			self:WireTriggerOutput("AltFire", 0)
		end)
	end
	
end

function ENT:Use( activator, caller )
	
end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
end
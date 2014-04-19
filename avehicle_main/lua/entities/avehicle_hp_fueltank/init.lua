AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.PrecacheModel("models/airboatgun.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" )
	--self.Entity:SetMaterial("models/props_combine/metal_combinebridge001")
	self.Entity:SetName("Fuel")
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
	
	self.fuelleft = self.MaxFuel
	self.FirstCheck = false
	self.dhealth = 200
	self.FlagGonnaExplode = false
end



function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_fueltank" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	
	return ent
	
end

function ENT:PhysicsUpdate()

end

function ENT:InstallFuel(add)
	local veh = self:GetAVehicle()
	if veh  and veh.FuelSystem then
		if add then
			veh.FuelSystem.fuel = veh.FuelSystem.fuel + (self.fuelleft * 0.66)
			veh.FuelSystem.resrv = veh.FuelSystem.resrv + (self.fuelleft * 0.33)
			self.fuelleft = 0
		else
			if veh.FuelSystem.fuel <= self.MaxFuel then
				veh.FuelSystem.resrv = veh.FuelSystem.resrv - (self.MaxFuel * 0.33)
			else
				veh.FuelSystem.fuel = veh.FuelSystem.fuel - (self.MaxFuel  * 0.66)
			end
		end
	end
end

function ENT:Think()
	local podindex = self:GetVehicleInstalledPod()
	if podindex >= 0 then
		local veh = self:GetAVehicle()
		if veh then
			--if veh:FuelisEmpty() then
			--	veh:FuelSetAmount(fuel, 100)
			--end
			if veh.FuelSystem then
				--Install fuel for vehicle.
				if not self.FirstCheck then
					self.FirstCheck = true
					self:InstallFuel(true)
				end
				
				--Check how much fuel does the vehicle have left and remove fuel tank if it's percent is used up.
				if (veh.FuelSystem.fuel < veh.FuelSystem.maxfuel-1) and (veh.FuelSystem.resrv < veh.FuelSystem.reservemax-1) then
					self:Remove()
				end
			end
		end
		
		--if veh.Passengers[podindex] and IsValid(veh.Passengers[podindex]) then
		--end
	end
end

function ENT:DoFire()


end


function ENT:DoAltFire()

	
end

function ENT:OnTakeDamage(dmginfo)
	self.dhealth = self.dhealth- dmginfo:GetDamage()
	if (self.dhealth < 0) and not self.FlagGonnaExplode then
		self:Ignite(5, 0)
		self.FlagGonnaExplode = true
		timer.Simple(5.0, function()
			if IsValid(self) then
				self:Extinguish()
				local e = EffectData()
				e:SetOrigin(self:GetPos())
				e:SetScale( 1.0 )
				e:SetNormal(self:GetPos():GetNormal())
				util.Effect("HelicopterMegaBomb", e)
				local position = Vector(0,0,0)
				util.BlastDamage(self, self, self:GetPos(), 40, 50)
				self:EmitSound("ambient/explosions/explode_7.wav", 100, 100)
				self:InstallFuel(false) --remove fuel that we add.
				self:Remove()
			end
		end)
	end
end

function ENT:Use( activator, caller )
	
end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent) --very important to init hardpoint...
end
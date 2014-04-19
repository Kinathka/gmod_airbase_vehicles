
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
util.PrecacheModel("models/props_wasteland/light_spotlight01_lamp.mdl")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/props_wasteland/light_spotlight01_lamp.mdl" ) 
	self.Entity:SetName("Searchlight")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow(false)
	self.Entity:SetSkin(1)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableDrag(false)
		--phys:EnableGravity( false )
	end
	
	self.lasttoggel = 0
	self.lastviewupdate = 0
	
	self.LastAngle = Angle(0,0,0)
end

function ENT:KeyValue( key, value )
	if key == "active" then
		if value > 0 then
			self:SetActive(true)
		else
			self:SetActive(false)
		end
	end
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_hp_searchlight" )
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
					local dif = (self:GetVehicleAim(podindex) - self:GetPos())
					local ang = dif:Angle()
					if self.AVehicle_InstallOptions and self.AVehicle_InstallOptions.ballsoc then
						self.LastAngle = ang
					elseif self.AVehicle_InstallOptions and self.AVehicle_InstallOptions.parent then
						self:SetAngles(ang)
					end
				end
			end
		end
end

/* This is not working. Use parent for now
function ENT:PhysicsUpdate( phys )
	if self.AVehicle_InstallOptions and self.AVehicle_InstallOptions.ballsoc then
		local pdif = self:GetAngles().p - self.LastAngle.p
		local ydif = self:GetAngles().y - self.LastAngle.y
		local rdif = self:GetAngles().r - self.LastAngle.r
		phys:AddAngleVelocity( -1 * phys:GetAngleVelocity() + Angle(pdif,rdif,ydif))
		--phys:SetAngles(self.LastAngle)
		--if self.HardPointInstalled then
		--self:SetAngles()
		--self:SetPos(phys:GetPos())
	end
end
*/


function ENT:DoFire()
	if self.lasttoggel < CurTime() then
		self.lasttoggel = CurTime() + 1.0
		if self.Active then
			self:SetActive(false)
		else
			self:SetActive(true)
		end
	end
end

function ENT:SetActive(on)
	self.Active = on
	if self.Active then
		self.Entity:SetNWBool("light_on", self.Active)
		if self.flashlight and IsValid(self.flashlight) then
			return
		end
		self.Entity:SetSkin(0)
		--local angForward = self.Entity:GetAngles() + Angle(90,0,0);
		self.flashlight = ents.Create("env_projectedtexture")
		self.flashlight:SetParent(self.Entity)
		self.flashlight:SetPos(self.Entity:GetPos() + self.Entity:GetForward()*10)
		self.flashlight:SetAngles(self.Entity:GetAngles())
		self.flashlight:SetKeyValue("enableshadows",1)
		self.flashlight:SetKeyValue("farz",4096)
		self.flashlight:SetKeyValue("nearz",8)
		self.flashlight:SetKeyValue("lightfov",40)
		self.flashlight:SetKeyValue("lightcolor","255 255 255")
		self.flashlight:Spawn()
		
	else
		SafeRemoveEntity(self.flashlight)
		self.Entity:SetSkin(1)
		self.flashlight = nil
		self.Entity:SetNWBool("light_on", self.Active)
		return
	end
end

local lastuse = 0
function ENT:Use( activator, caller )
	if self.HardPointInstalled then return end
	if lastuse < CurTime() then
		lastuse =  CurTime() + 0.5
		if (self.Active == true) then
			self:SetActive(false)
		else
			self:SetActive(true)
		end
	end

end

function ENT:Touch( ent )
	return self.BaseClass.Touch(self, ent)
end
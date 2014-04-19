AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/parachute/chute.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetColor(Color(0,0,200,255))
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(250)
		phys:Wake()
		phys:EnableGravity(false)
	end
	self.Entity:StartMotionController()
	self.Force = 1
end

function ENT:PhysicsSimulate(phys,deltatime)
	return Vector(0,0,0),Vector(0,0,self.Force)*deltatime,SIM_GLOBAL_FORCE
end

function ENT:SetCounterForce(force)
	self.Force = force
end

function ENT:PhysicsUpdate( physobj )
	local vel = physobj:GetVelocity()	
	physobj:SetVelocity(vel*0.5)
end
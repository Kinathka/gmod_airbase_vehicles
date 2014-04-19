
include('shared.lua')

function ENT:Initialize()
	self.WindSound = CreateSound(self, "ambient/levels/canals/windmill_wind_loop1.wav")
	self.LastTick = 0
end

function ENT:Draw()
	self:DrawModel()

end

function ENT:Think()
	if self.LastTick < CurTime() then
		self.LastTick = CurTime() + 0.5
		
		local on = self:GetNWBool("rotor_online") or false
		if on and not self.WindSound:IsPlaying() and not AVehicles.Vehicle.IsIn then
			self.WindSound:PlayEx(1.0, 100)
		elseif (!on or AVehicles.Vehicle.IsIn) and self.WindSound:IsPlaying() then
			self.WindSound:Stop()
		end
	end
end

function ENT:OnRemove()
	self.WindSound:Stop()
end

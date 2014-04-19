include('shared.lua')

function ENT:Initialize()
end

local material = Material( "effects/av_flare" )

function ENT:Draw()
	
	local pos1 = self:GetPos()
	render.SetMaterial( material )
	render.DrawSprite( pos1, 32, 32, Color(255,255,255,255) )
	self.Entity:DrawModel()

end

function ENT:OnRemove()

end

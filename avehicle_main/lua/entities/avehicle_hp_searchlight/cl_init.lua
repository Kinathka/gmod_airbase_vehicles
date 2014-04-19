include("shared.lua")

local matLight = Material("sprites/light_ignorez")
local matBeam = Material("effects/lamp_beam")

function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
	self.WColor = Color(255,255,255,255)
end


function ENT:Draw()
	self.Entity:DrawModel()
	local WHITE = self.WColor
	if(not self:GetNWBool("light_on",false)) then return end
	local dir = -1*self.Entity:GetForward()
	local pos = self.Entity:GetPos()
	local ViewNormal = (pos - EyePos())
	local Distance = ViewNormal:Length()
	local ViewDot = ViewNormal:Dot(dir)/Distance
	local LightPos = pos - 6*dir
	
	render.SetMaterial(matBeam)
	local BeamDot = 0.25
	render.StartBeam(3)
	WHITE.a = 255 * BeamDot
	render.AddBeam(LightPos + dir, 128,0.0,WHITE)
	WHITE.a = 64 * BeamDot
	render.AddBeam(LightPos - 100*dir,128,0.5,WHITE)
	WHITE.a = 0
	render.AddBeam(LightPos - 200*dir,128,1,WHITE)
	render.EndBeam()
	
	if(ViewDot >= 0) then
		render.SetMaterial(matLight)
		local Visibile = util.PixelVisible(LightPos,16,self.PixVis)
		if(not Visibile) then return end
		local Size = math.Clamp(Distance*Visibile*ViewDot/2,32,128)
		Distance = math.Clamp(Distance,32,800)
		local Alpha = math.Clamp((1000 - Distance)*Visibile*ViewDot,0,100)
		WHITE.a = Alpha;
		render.DrawSprite(LightPos,Size,Size,WHITE,Visibile*ViewDot)
		render.DrawSprite(LightPos,Size*0.4,Size*0.4,WHITE,Visibile*ViewDot)
	end
end


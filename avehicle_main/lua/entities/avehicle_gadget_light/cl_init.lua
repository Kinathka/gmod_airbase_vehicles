/**********************************************************************************************
//////##////////##//////////##//##########//##////////##////////##////////##########//##########
////##//##//////##//////////##//##//////////####//////##//////##//##//////////##//////##////////
////##//##//////##//////////##//##//////////##//##////##//////##//##//////////##//////##////////
////##//##//////##//////////##//##########//##//##////##//////##//##//////////##//////##########
//##//////##////##//////////##//##//////////##////##//##////##//////##////////##//////##////////
//##########////##//////////##//##//////////##////##//##////##########////////##//////##////////
##//////////##//##//////////##//##//////////##//////####//##//////////##//////##//////##////////
##//////////##//##########//##//##########//##////////##//##//////////##//////##//////##########

	Alienate Vehicles addon for GarrysMod
	Copyright (C) 2010  "Hein"
							a.k.a "Warkanum"
							a.k.a "Lifecell"
	Email: we.alienate@gmail.com
	Web: http://sourceforge.net/projects/gmod-avehicles/
	 
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
**************************************************************************************************
*/

---------------------------------------------------------------I got some of this code from Avon's jumper, thanks ---------------------------------
include("shared.lua")
local matLight = Material("sprites/light_ignorez")
local matBeam = Material("effects/lamp_beam")

function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
	self.WColor = Color(255,255,255,255)
end


function ENT:Draw()
	local WHITE = self.WColor
	if(not self:GetNWBool("On",false)) then return end
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


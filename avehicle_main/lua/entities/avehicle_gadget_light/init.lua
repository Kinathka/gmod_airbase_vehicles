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
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:DrawShadow(false)
end


function ENT:Toggle()
	if(self.flashlight) then
		SafeRemoveEntity(self.flashlight)
		self.flashlight = nil
		self:SetNWBool("On",false)
		return
	end
	
	self:SetNWBool("On",true)
	--local angForward = self.Entity:GetAngles() + Angle(90,0,0);
	self.flashlight = ents.Create("env_projectedtexture")
	self.flashlight:SetParent(self.Entity)
	self.flashlight:SetPos(self.Entity:GetPos())
	self.flashlight:SetAngles(self.Entity:GetAngles())
	self.flashlight:SetKeyValue("enableshadows",1)
	self.flashlight:SetKeyValue("farz",2048)
	self.flashlight:SetKeyValue("nearz",8)
	self.flashlight:SetKeyValue("lightfov",50)
	self.flashlight:SetKeyValue("lightcolor","255 255 255")
	self.flashlight:Spawn()
end
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
if not AVehicles then 
	Msg("\nAlienate Vehicle Base not installed! Please install it for this addon to work!\n")
end 
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Hardpoint Base"
ENT.Author			= "Warkanum"
ENT.Category = "AVehicles"
ENT.AVDebug			= false
ENT.IsAVehicleWeaponHP = true
ENT.IsAVehicleAttachable = true
ENT.AVehicleHardpointPostBallSockInsteadOfWeld = false --Use this carefully
/* Only set these if you want to force the settings.
ENT.AVehicleHardpointWeld = false
ENT.AVehicleHardpointParent = false
ENT.AVehicleHardpointPostNocollide = true
*/
ENT.IgnoreView = true
ENT.AVehicleWepName = "Base Wep"
ENT.HardPointKind = AVehicles.Types.HARDPOINT_UNIVERSAL
ENT.HardPointAngleAdd = Angle(0,0,0)
ENT.Spawnable		= false
ENT.AdminSpawnable	= false



if SERVER then
	AVehicles.RDWire.Install(ENT) 
end

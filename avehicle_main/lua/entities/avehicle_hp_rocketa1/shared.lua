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
ENT.Base 			= "avehicle_hardpoint_base"
ENT.PrintName		= "Rocket A1"
ENT.Author			= "Warkanum"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Category = "AVehicles"

ENT.AVehicleWepName = "Rocket A1"
---ENT.AVehicleHardpointWeld = false
--ENT.AVehicleHardpointParent = true

ENT.AVehicleHardpointWeld = true
ENT.AVehicleHardpointPostNocollide = false
ENT.AVehicleHardpointPostBallSockInsteadOfWeld = false --Use this carefully
ENT.HardPointKind = AVehicles.Types.HARDPOINT_STATIC -- AVehicles.Types.HARDPOINT_UNIVERSAL-- 
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.HardPointAngleAdd = Angle(0,0,0)

ENT.MaxMountedHealth = 300 --the max damage to do before it explodes while mounted.
ENT.FireTime = 0.4
ENT.Damageamount = 100
ENT.Forceamount = 40
ENT.ExpDel 		=  0.3
ENT.FrcDel 		=  0.2
ENT.MaxLifeTime	= 25
ENT.CopiesBeforeSelfEject = 32

if SERVER then
	AVehicles.RDWire.Install(ENT) 
end


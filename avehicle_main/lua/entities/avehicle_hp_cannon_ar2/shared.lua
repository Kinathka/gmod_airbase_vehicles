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
ENT.PrintName		= "Ar2 Gun"
ENT.Author			= "Warkanum"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Category = "AVehicles"

ENT.AVehicleWepName = "Ar2 Gun"
---ENT.AVehicleHardpointWeld = false
--ENT.AVehicleHardpointParent = true
--ENT.AVehicleHardpointPostNocollide = true
ENT.AVehicleHardpointPostBallSockInsteadOfWeld = false --Use this carefully
ENT.HardPointKind = AVehicles.Types.HARDPOINT_AIMABLE -- AVehicles.Types.HARDPOINT_UNIVERSAL-- 
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.FireTime = 0.15
ENT.Damageamount = 80
ENT.Forceamount = 100
ENT.Tracers = 1
ENT.SpreadVec =  Vector( 0.02, 0.02, 0.04 )
ENT.TracerName = "AirboatGunHeavyTracer"
ENT.BlastRadius = 30
ENT.BlastDamage = 90


if SERVER then
	AVehicles.RDWire.Install(ENT) 
end
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
ENT.PrintName		= "MiniGun"
ENT.Author			= "Warkanum"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.AVehicleWepName = "MiniGun"
---ENT.AVehicleHardpointWeld = false
--ENT.AVehicleHardpointParent = true
--ENT.AVehicleHardpointPostNocollide = true
ENT.AVehicleHardpointPostBallSockInsteadOfWeld = false --Use this carefully
ENT.HardPointKind = AVehicles.Types.HARDPOINT_AIMABLE -- AVehicles.Types.HARDPOINT_UNIVERSAL-- 
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true --Important for animations

--ENT.HeatUpSpeed = 0.5
--ENT.CoolDownSpeed = 0.8
ENT.FireTime = 0.04
ENT.Damageamount = 50
ENT.Forceamount = 20
ENT.Tracers = 0
ENT.SpreadVec =  Vector( 0.039, 0.052, 0.052 )
ENT.TracerName = "Tracer"
ENT.StartUpTime = 1.0
ENT.AlternativeSound = true;

ENT.SoundList = {
	Shoot=Sound("Avehicle_MiniGun.Shoot"),
	Fire=Sound("Avehicle_MiniGun.Fire"),
	Spin=Sound("Avehicle_MiniGun.Spin"),
	Start=Sound("Avehicle_MiniGun.WindUp"),
	Stop=Sound("Avehicle_MiniGun.WindDown")
}

if SERVER then
	AVehicles.RDWire.Install(ENT) 
end
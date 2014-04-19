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
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.CFG =  {}
AVehicles.Hooks = {}
AVehicles.Tools = {}
AVehicles.Keys =  {}
AVehicles.Types = {}
---------------------------------------------------------------The Body, Code----------------------------------------

--gmod_vehicle_viewmode = CreateClientConVar( "gmod_vehicle_viewmode", "1", true, true )

CreateConVar("AVehicles_version",AVehicles.Version)

AVehicles.Types.HARDPOINT_UNIVERSAL = 1
AVehicles.Types.HARDPOINT_AIMABLE = 2
AVehicles.Types.HARDPOINT_STATIC = 3
AVehicles.Types.HARDPOINT_BOMBBAY = 4
AVehicles.Types.HARDPOINT_ROCKET = 5
AVehicles.Types.HARDPOINT_SUPPORT = 6
AVehicles.Types.HARDPOINT_HOOK = 7
AVehicles.Types.HARDPOINT_SEAT = 8
AVehicles.Types.HARDPOINT_LARGE = 9
AVehicles.Types.HARDPOINT_SMALL = 10


function AVehicles.Types.HardPointMatchLogic(entkind, mountkind)
	if entkind == AVehicles.Types.HARDPOINT_SUPPORT and mountkind == AVehicles.Types.HARDPOINT_UNIVERSAL then return false end
	if mountkind == AVehicles.Types.HARDPOINT_SUPPORT and entkind == AVehicles.Types.HARDPOINT_UNIVERSAL then return false end
	if mountkind == AVehicles.Types.HARDPOINT_LARGE  and entkind == AVehicles.Types.HARDPOINT_LARGE then return true end
	if mountkind == AVehicles.Types.HARDPOINT_LARGE  and entkind == AVehicles.Types.HARDPOINT_UNIVERSAL then return true end
	if mountkind == AVehicles.Types.HARDPOINT_LARGE  then return true end
	if mountkind == AVehicles.Types.HARDPOINT_UNIVERSAL then return true end
	if entkind == AVehicles.Types.HARDPOINT_UNIVERSAL then return true end
	if entkind == mountkind then return true end
	return false
end

function AVehicles.Tools.NormalizeAngle(a)
	a = a%360;
	if a > 180 then
		a = a - 360;
	end
	return a;
end

--A better function to normalize a complete angle data type
function AVehicles.Tools.NormalizeAngles(ang)
	if ang then
		local newAngle = Angle(math.NormalizeAngle(ang.p), math.NormalizeAngle(ang.y), math.NormalizeAngle(ang.r))
		return newAngle
	else
		return Angle(0,0,0)
	end
end

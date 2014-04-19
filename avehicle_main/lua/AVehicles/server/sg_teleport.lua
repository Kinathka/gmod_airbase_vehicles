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
------------------This is for all the stargate addon stuff----------------------------------------------------------
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.stargate = AVehicles.stargate or {}
---------------------------------------------------------------The Body, Code----------------------------------------
function AVehicles.stargate.avehicle_viewfix(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	if IsValid(e) then
		local Passengers = e:GetPassengers()
		for k,p in pairs(Passengers) do
			if IsValid(p) then
				p:SetEyeAngles(p:GetAimVector():Angle() + Angle(0,ang_delta.y+180,0) )
				--Need recoding!
			end
		end
	end

end

-- Stargate Teleport Hook @ Warkanum
-- (Entity|Caller),(Entity|EventHorizon),(table|Attached Entities),(Bool|blocked)
function AVehicles.TeleportStart(entCaller, entEH, tblEnts, blocked)
	if IsValid(entCaller) and entCaller.IsAVehicle then
		entCaller:PreStargateTeleport(entEH, tblEnts, blocked)
	end
end
hook.Add( "StarGate.Teleport", "AVehicles.TeleportStart", AVehicles.TeleportStart)

--if StarGate then
--	StarGate.Teleport:Add("avehicle_base",AVehicles.stargate.avehicle_viewfix)
--end

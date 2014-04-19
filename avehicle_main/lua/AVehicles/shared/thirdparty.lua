/****************************************************************************
				--==Alienate==--

	aVehicles a.k.a Alienate Vehicles or Air Vehicles SENT for GarrysMod10
	Copyright (C) 2009  Warkanum,Kadingir,Lifecell

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
*/--******************************************************************************
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.Thirdparty = AVehicles.Thirdparty  or {}

---------------------------------------------------------------The Body, Code----------------------------------------

local function checkweaponseats()
	--if (file.Exists("../lua/entities/weapon_seat/shared.lua", true)) then
	--	return true
	--end
	if scripted_ents.Get("weapon_seat") then
		return true
	end
	return false
end

--Check whether a certain thirdparty addons has been installed. For example entities we use.
function AVehicles.Thirdparty.isInstalled(name)
	if (name == "weaponseat") then
		return checkweaponseats()	
	elseif (name == "stargate") then
		if StarGate then
			if StarGate.Installed then
				return true
			end
		end
	end
	
	return false
end
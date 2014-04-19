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
local fuelmustupdate = false
local fuelupdate = 0
local fuelrupdate = 0
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------

function ENT:FuelInitialize()
	self.FuelSystem = {}
	self.FuelSystem.unlimited = self.Fuel.unlimited
	self.FuelSystem.maxfuel = self.Fuel.maxfuel
	self.FuelSystem.usagepertick = self.Fuel.usagepertick
	self.FuelSystem.reservemax = self.Fuel.reservemax	
	self.FuelSystem.consumemul = 1
	self.FuelSystem.consumeticktime = self.Fuel.consumeticktime
	self.FuelSystem.consumetick = 0 --internal
	self.FuelSystem.fuel = self.FuelSystem.maxfuel or 0 --internal
	self.FuelSystem.resrv = self.FuelSystem.reservemax or 0--internal
end

--Consumes fuel, called in engine operation. To do, add Lifesupport.... @ Warkanum
function ENT:FuelConsume(amount)
	if (GetConVarNumber("avehicles_cvar_vehicle_fuelsystem") <= 0) then 
		self.FuelSystem.fuel = self.FuelSystem.maxfuel
		return 2;
	end
	if self.FuelSystem.unlimited then return 2 end
	if (self.FuelSystem.fuel <= 0) then
		if (self.FuelSystem.resrv <= 0) then
			return 0
		end
		self.FuelSystem.resrv = self.FuelSystem.resrv - (amount * self.FuelSystem.consumemul)
		return 1
	end
	self.FuelSystem.fuel = self.FuelSystem.fuel - (amount * self.FuelSystem.consumemul)
	return 2
end

function ENT:FuelUpdateValues()
	if (fuelmustupdate) then
		fuelmustupdate = false
		self.FuelSystem.fuel = fuelupdate
		self.FuelSystem.resrv = fuelrupdate
	end
end

function ENT:FuelisEmpty()
	if self.FuelSystem.unlimited then return false end
	if (self.FuelSystem.fuel <= 0) and (self.FuelSystem.resrv <= 0) then
		return true
	end
	return false
end

function ENT:FuelSetAmount(fuel, reserv)
	fuelupdate = math.Clamp(self.FuelSystem.maxfuel * (fuel/100),1,self.FuelSystem.maxfuel) or 1
	fuelrupdate = math.Clamp(self.FuelSystem.reservemax* (reserv/100),1, self.FuelSystem.reservemax) or 1
	fuelmustupdate = true
end


function ENT:FuelOnRemove()
	
end
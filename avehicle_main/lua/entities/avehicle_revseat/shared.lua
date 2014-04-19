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
Credits to CapsAdmin, his code inspired me for my own vehicle_seat.
*/
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "AVehicles"
ENT.PrintName = "Avehicle Rev Seat"
ENT.Author = "Warkanum"
ENT.Contact = ""
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Spawnable = false
ENT.AdminSpawnable = false


AccessorFunc( ENT, "isAVehicleSeat", "AVehicleSeat", FORCE_BOOL);

if SERVER then --------------Install wire and lifesupport if they exist.
	AVehicles.RDWire.Install(ENT)
end

function ENT:KeyValue(key, value)
	if key == "defaultmodel" then
		self.DefaultModel = value
	elseif key == "VehicleLocked" then
		if (value == "true") or (value == "1") then
			self.Locked = true;
		else
			self.Locked = false;
		end
	elseif key == "thirdviewdistance" then
		self.ThirdViewDistance = value
	elseif key == "alloweapons" then
		if (value == "true") or (value == "1") then
			self.AllowWeapons = true;
		else 
			self.AllowWeapons = false; 
		end
	end
end

/**
Entity & Player Table overrides
**/
local entity_meta = FindMetaTable("Entity");
local player_meta = FindMetaTable("Player");

if (AVehicles) then
	AVehicles.OldEntTable = AVehicles.OldEntTable or {};
	AVehicles.OldPlyTable = AVehicles.OldPlyTable or {};
	
	AVehicles.OldEntTable.IsVehicle = AVehicles.OldEntTable.IsVehicle or entity_meta.IsVehicle;
	function entity_meta:IsVehicle()
		if self.isAVehicleSeat then
			return true; 
		else
			return AVehicles.OldEntTable.IsVehicle(self);
		end
	end
	
	AVehicles.OldPlyTable.InVehicle = AVehicles.OldPlyTable.InVehicle or player_meta.InVehicle;
	function player_meta:InVehicle()
		if self:GetNWBool("AVehicleSeatOccupied") 
				and IsValid(self:GetNWEntity("AVehicleSeatEntity")) then
			return true;
		else
			return AVehicles.OldPlyTable.InVehicle(self);
		end
	end
	
	AVehicles.OldPlyTable.GetVehicle = AVehicles.OldPlyTable.GetVehicle or player_meta.GetVehicle;
	function player_meta:GetVehicle()
		local seat = self:GetNWEntity("AVehicleSeatEntity");
		if self:GetNWBool("AVehicleSeatOccupied") then
			if IsValid(seat) then
				return seat;
			end
		else
			return AVehicles.OldPlyTable.GetVehicle(self);
		end
	end
	
	if SERVER then
		AVehicles.OldEntTable.GetDriver = AVehicles.OldEntTable.GetDriver or entity_meta.GetDriver;
		function entity_meta:GetDriver()
			if (self.isAVehicleSeat) then
				return self.Occupant;
			else
				return AVehicles.OldEntTable.GetDriver(self);
			end
		end
		
		AVehicles.OldEntTable.GetPassenger = AVehicles.OldEntTable.GetPassenger or entity_meta.GetPassenger;
		function entity_meta:GetPassenger()
			if (self.isAVehicleSeat) then
				return self.Occupant;
			else
				return AVehicles.OldEntTable.GetPassenger(self);
			end
		end
		
		AVehicles.OldPlyTable.EnterVehicle = AVehicles.OldPlyTable.EnterVehicle or player_meta.EnterVehicle;
		function player_meta:EnterVehicle(entity)
			if IsValid(entity) and (entity.isAVehicleSeat) then
				entity:EnterSeat(self);
			else
				return AVehicles.OldPlyTable.EnterVehicle(self,entity);
			end
		end

		AVehicles.OldPlyTable.ExitVehicle = AVehicles.OldPlyTable.ExitVehicle or player_meta.ExitVehicle;
		function player_meta:ExitVehicle()
			local seat = self:GetNWEntity("AVehicleSeatEntity");
			if IsValid(seat) and self:GetNWBool("AVehicleSeatOccupied") then
				if gamemode.Call("CanExitVehicle", seat, self) then 
					seat:ExitSeat();
				end
			else
				return AVehicles.OldPlyTable.ExitVehicle(self);
			end
		end
		
	end
end


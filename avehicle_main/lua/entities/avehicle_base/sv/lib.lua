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

---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:PlayerCheck(ply)
	if ply and IsValid(ply) then
		if ply:IsPlayer() then
			return true
			--if ply:Alive() then
			--	return true
			--end
		end
	end
	return false
end

function ENT:ValidCreator()
	if self.AVehicle_Creator and IsValid(self.AVehicle_Creator) and self.AVehicle_Creator:IsPlayer() then
		return true
	end
	return false
end

function ENT:RemoveExstras()

end

function ENT:FindVehiclespawnpoint(range)
	local pos = self.Entity:GetPos()
	local dist = range
	local ent;
	for _,v in pairs(ents.FindByClass("avehicle_plyspawner*")) do
		if v.Is_aVehiclespawn then
			local r_dist = (pos - v:GetPos()):Length()
			if(dist >= r_dist) then
				dist = r_dist
				ent = v
			end
		end
	end
	return ent
end

--Gets the third person view. 0 = TP, 1 = FP, 2 = LFP @ Warkanum
function ENT:GetClientThirdPersonView(ply)
	if AVehicles.Vehicle.PlayersThirdPersonView then
		for k,v in pairs(AVehicles.Vehicle.PlayersThirdPersonView) do
			if k == ply then
				return v
			end
		end
	end
	return 1
end


function ENT:GetPassengers()
	local ps = {}
	local cnt = 0
	if self.PassengerCount >= 0 then
		for i=0, self.PassengerCount, 1 do
			if IsValid(self.Passengers[i]) then
				ps[cnt] = self.Passengers[i]
				cnt = cnt + 1
			end
		end
	end
	return ps
end


function ENT:CalcAimVectors(ply) --Returns hitpos vector
	if self:PlayerCheck(ply) and (self:GetClientThirdPersonView(ply) == 0) then
		local ang = ply:GetAimVector():GetNormal()
		local pos = ply:GetShootPos()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*990000)
		local attachables = {}
		if self.HardPointsInstalled then
			for _,v in pairs(self.HardPointsInstalled) do
				if v and v.ent then
					table.insert(attachables, v.ent)
				end
			end
		end
		local filterents = {self.Entity, ply}
		table.Add( filterents, self.PodsEnts)
		table.Add( filterents, self.Passengers)
		table.Add( filterents, self.Gagets.Bullseyes)
		table.Add( filterents, self.Gagets.Lights)
		table.Add( filterents, attachables)
		--self:EngineGetConstraintEnts()
		tracedata.filter = filterents
		local trace = util.TraceLine(tracedata)
		return trace.HitPos
	elseif self:PlayerCheck(ply) and (self:GetClientThirdPersonView(ply) == 1) then
		local ang = ply:GetAimVector():GetNormal()
		local pos = ply:GetShootPos()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*990000)
		local attachables = {}
		if self.HardPointsInstalled then
			for _,v in pairs(self.HardPointsInstalled) do
				if v and v.ent then
					table.insert(attachables, v.ent)
				end
			end
		end
		local filterents = {self.Entity, ply}
		table.Add( filterents, self.PodsEnts)
		table.Add( filterents, self.Passengers)
		table.Add( filterents, self.Gagets.Bullseyes)
		table.Add( filterents, self.Gagets.Lights)
		table.Add( filterents, attachables)
		--self:EngineGetConstraintEnts()
		tracedata.filter = filterents
		local trace = util.TraceLine(tracedata)
		return trace.HitPos
	else --If view is locked on vehicles, we want to trace in the vehicles forward direction.
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = self:GetForward()*800000
		local filterents = {self.Entity, ply}
		table.Add( filterents, self.PodsEnts)
		table.Add( filterents, self.Passengers)
		table.Add( filterents, self.Gagets.Bullseyes)
		table.Add( filterents, self.Gagets.Lights)

		tracedata.filter = filterents
		local trace = util.TraceLine(tracedata)
		return trace.HitPos
	end
	return Vector(0,0,0)
end
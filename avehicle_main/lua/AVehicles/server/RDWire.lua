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
--------------------------------------Globals,Functions & Autoruns--------------------------------------
AVehicles.RDWire = {}
AVehicles.RDWire.RD = {}
AVehicles.RDWire.Wire = {}
---------------------------------------------Serverside----------------------------------------------------
local RDThree

local function HasResources()
	local State = 0
	if(CAF) then
		if(CAF.GetAddon("Resource Distribution")) then
			State = State + 1
			if RDThree == nil then
				RDThree = CAF.GetAddon("Resource Distribution")
			end
		end
		if(CAF.GetAddon("Life Support")) then
			State = State + 2
		end
	end
	return State	
end

local function HasWire()
	if (WireAddon) and WireLib then
		return true
	end
	return false
end

function AVehicles.RDWire.Install(e)
	e.RD_AddRes = AVehicles.RDWire.RD.AddResource
	e.RD_GetRes = AVehicles.RDWire.RD.GetResourceAmount
	e.RD_UseRes = AVehicles.RDWire.RD.ConsumeResource
	e.RD_GiveRes = AVehicles.RDWire.RD.SupplyResource
	e.RD_GetUCap = AVehicles.RDWire.RD.GetUnitCapacity
	e.RD_GetNCap = AVehicles.RDWire.RD.GetNetworkCapacity
	e.RD_HasRes = AVehicles.RDWire.RD.HasResources
	e.WireDebugName = e.WireDebugName or e.EntityName or "Nameless"
	e.HasWire = HasWire()
	if (HasResources() >= 1) then
		e.HasRD3 = true
	end
	
	e.OnRemove = AVehicles.RDWire.OnRemove
	e.OnRestore = AVehicles.RDWire.OnRestore;

	--Special input types: NORMAL, ENTITY, ANGLE, VECTOR, COLOR, STRING, TABLE, ARRAY, ANY
	e.WireCreateOutputs = AVehicles.RDWire.Wire.CreateWireOutputs
	e.WireCreateInputs = AVehicles.RDWire.Wire.CreateWireInputs
	e.WireCreateSpecialOutputs = AVehicles.RDWire.Wire.CreateSpecialOutputs
	e.WireCreateSpecialInputs = AVehicles.RDWire.Wire.CreateSpecialInputs
	e.WireAdjustSpecialInputs = AVehicles.RDWire.Wire.AdjustSpecialInputs
	e.WireAdjustSpecialOutputs = AVehicles.RDWire.Wire.AdjustSpecialOutputs
	
	--e.WireTriggerInput = AVehicles.RDWire.Wire.TriggerInput
	e.WireTriggerOutput = AVehicles.RDWire.Wire.TriggerOutput
	
	e.WireSet = AVehicles.RDWire.Wire.SetWire
	e.WireGet = AVehicles.RDWire.Wire.GetWire
	
	e.PreEntityCopy = AVehicles.RDWire.PreEntityCopy
	e.PostEntityPaste = AVehicles.RDWire.PostEntityPaste
end

-- Wire
--function AVehicles.RDWire.Wire.TriggerInput(self,...)
--end

function AVehicles.RDWire.Wire.TriggerOutput(self,...)
	if(HasWire() and arg) then
		Wire_TriggerOutput(self.Entity,unpack(arg))
	end
end

function AVehicles.RDWire.Wire.CreateSpecialOutputs(self,...)
	if(HasWire() and arg) then
		self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,unpack(arg))
	end
end

function AVehicles.RDWire.Wire.CreateSpecialInputs(self,...)
	if(HasWire() and arg ) then
		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,unpack(arg))
	end
end

function AVehicles.RDWire.Wire.AdjustSpecialInputs(self,...)
	if(HasWire()  and arg) then
		self.Inputs = WireLib.AdjustSpecialInputs(self.Entity,unpack(arg))
	end
end

function AVehicles.RDWire.Wire.AdjustSpecialOutputs(self,...)
	if(HasWire()  and arg) then
		self.Outputs = WireLib.AdjustSpecialOutputs(self.Entity,unpack(arg))
	end
end


--Old and depricated wire functions. @ Warkanum
function AVehicles.RDWire.Wire.CreateWireOutputs(self,...)
	if(HasWire()  and arg) then
		self.Outputs = Wire_CreateOutputs(self.Entity,{unpack(arg)})
	end
end

function AVehicles.RDWire.Wire.CreateWireInputs(self,...)
	if(HasWire()  and arg ) then
		self.Inputs = Wire_CreateInputs(self.Entity,{unpack(arg)})
	end
end

function AVehicles.RDWire.Wire.SetWire(self,key,value)
	if(HasWire()  and arg ) then
		if(value == true) then 
			value = 1
		elseif(value == false) then
			value = 0
		end
		value = tonumber(value)
		if(value) then
			Wire_TriggerOutput(self.Entity,key,value)
			if(self.WireOutput) then
				self:WireOutput(key,value)
			end
		end
	end
end

function AVehicles.RDWire.Wire.GetWire(self,key,default)
	if(HasWire()  and arg ) then
		if(self.Inputs[key] and self.Inputs[key].Value) then
			return self.Inputs[key].Value or default or 0
		end
		return default or 0
	end
end

--Resource Distubutor
function AVehicles.RDWire.RD.AddResource(e,resource,maximum,default)
	if(HasResources() >= 1) then
		RDThree.AddResource(e.Entity,resource,maximum or 0, default or 0)	
	end
end


function AVehicles.RDWire.RD.GetResourceAmount(e,resource, default)
	if(HasResources() >= 1) then
		return RDThree.GetResourceAmount(e.Entity,resource) or default or 0
	end
	return default or 0
end

function AVehicles.RDWire.RD.ConsumeResource(e,resource,amount)
	if(HasResources() >= 1) then
		return RDThree.ConsumeResource(e.Entity,resource,amount or 0)
	end
end

function AVehicles.RDWire.RD.SupplyResource(e,resource,amount)
	if(HasResources() >= 1) then
		RDThree.SupplyResource(e.Entity, resource, amount or 0)
	end
end


function AVehicles.RDWire.RD.GetUnitCapacity(e,resource)
	if(HasResources() >= 1) then
		return RDThree.GetUnitCapacity(e.Entity,resource) or 0
	end
	return 0
end


function AVehicles.RDWire.RD.GetNetworkCapacity(e,resource)
	if(HasResources() >= 1) then
		return RDThree.GetNetworkCapacity(e.Entity,resource) or 0
	end
	return 0
end


--Remove & Restore
function AVehicles.RDWire.OnRemove(self)
	if(HasResources() >= 1) then
		RDThree.RemoveRDEntity(self.Entity)
	elseif(Dev_Unlink_All and self.resources2links) then
		Dev_Unlink_All(self.Entity)
	end
	if(HasWire() and (self.Outputs or self.Inputs)) then
		Wire_Remove(self.Entity)
	end
end

function AVehicles.RDWire.OnRestore(self)
	if(HasWire()  and arg) then
		Wire_Restored(self.Entity)
	end
end


-- For Duplicator
function AVehicles.RDWire.PreEntityCopy(self)
	--if(RD_BuildDupeInfo) then RD_BuildDupeInfo(self.Entity) end
	if(HasWire()) then
		local data = WireLib.BuildDupeInfo(self.Entity)
		if(data) then
			duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",data)
		end
	end
end

function AVehicles.RDWire.PostEntityPaste(self,Player,Ent,CreatedEntities)
	--if(RD_ApplyDupeInfo) then RD_ApplyDupeInfo(Ent,CreatedEntities) end
	if(HasWire()) then
		if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
			WireLib.ApplyDupeInfo(Player,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end)
		end
	end
end

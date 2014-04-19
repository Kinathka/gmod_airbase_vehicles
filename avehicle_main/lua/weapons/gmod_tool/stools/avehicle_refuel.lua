if SERVER then
	AddCSLuaFile( "weapons/gmod_tool/stools/avehicle_refuel.lua" )
end

--TOOL.AddToMenu		= true
TOOL.Tab			= "AVehicles"
TOOL.Category		= "Tools"			
TOOL.Name			= "Refuel"	
TOOL.Command		= nil			
TOOL.ConfigName		= ""		


TOOL.ClientConVar[ "dofillup" ] = "0"
TOOL.ClientConVar[ "fuel" ] = "0"
TOOL.ClientConVar[ "reserves" ] = "0"

if CLIENT then
	language.Add( "Tool_avehicle_refuel_name", "Alienate Vehicle Refuel Tool" )
	language.Add( "Tool_avehicle_refuel_desc", "Repairs or modifies Alienate Vehicles." )
	language.Add( "Tool_avehicle_refuel_0", "Left click to set fuel. Please check settings first!. Right Click to get fuel info." )
end


function TOOL:LeftClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	
	if (ent.IsAVehicle) then
		local dofillup = tobool(self:GetClientNumber("dofillup"))
		local fuel = math.Clamp(tonumber(self:GetClientNumber("fuel")),1,100)
		local reserves = math.Clamp(tonumber(self:GetClientNumber("reserves")),1,100)
		
		if ent.FuelSystem then
			if dofillup then
				ent:FuelSetAmount(100,100)
			else
				ent:FuelSetAmount(fuel,reserves)
			end
		end
		return true
	end
	return false
end

function TOOL:RightClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	if (ent.IsAVehicle) then
		local ent = trace.Entity
		
		if (ent.FuelSystem) then
			local fuel =  math.Round(ent.FuelSystem.fuel / ent.FuelSystem.maxfuel * 100)
			local reserves =  math.Round(ent.FuelSystem.resrv / ent.FuelSystem.reservemax * 100)
			
			self:GetOwner():ConCommand("avehicle_refuel_fuel "..math.Clamp(fuel,0, 100))
			self:GetOwner():ConCommand("avehicle_refuel_reserves "..reserves)
		end
		
		return true
	end
	return false
end

function TOOL:Reload( trace )

end

function TOOL:Think()

end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_avehicle_refuel_name", Description = "#Tool_avehicle_refuel_desc" })
	
	panel:AddControl("Slider", {
		Label = "Fuel Percentage",
		Type = "Float",
		Description = "Set the fuel value between 1 - 100",
		Min = "1",
		Max = "100",
		Command = "avehicle_refuel_fuel"
	})
	panel:AddControl("Slider", {
		Label = "Fuel Reserves Percentage",
		Type = "Float",
		Description = "Set the fuel reserves value between 1 - 100",
		Min = "1",
		Max = "100",
		Command = "avehicle_refuel_reserves"
	})
	panel:AddControl("CheckBox", {
		Label = "Fill up",
		Description = "Ignore values, just fill it up!",
		Command = "avehicle_refuel_dofillup"
	})

end
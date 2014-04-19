if SERVER then
	AddCSLuaFile( "weapons/gmod_tool/stools/avehicle_repair.lua" )
end

--TOOL.AddToMenu		= true
TOOL.Tab			= "AVehicles"
TOOL.Category		= "Tools"			
TOOL.Name			= "Repair"	
TOOL.Command		= nil			
TOOL.ConfigName		= ""		


TOOL.ClientConVar[ "dorepair" ] = "0"
TOOL.ClientConVar[ "doshield" ] = "0"
TOOL.ClientConVar[ "shield" ] = "1"

if CLIENT then
	language.Add( "Tool_avehicle_repair_name", "Alienate Vehicle Repair Tool" )
	language.Add( "Tool_avehicle_repair_desc", "Repairs or modifies Alienate Vehicles." )
	language.Add( "Tool_avehicle_repair_0", "Left click to repair. Please check settings first!. Right Click to get shield value." )
end


function TOOL:LeftClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	
	if (ent.IsAVehicle) then
		local canrepair = self:GetClientNumber("dorepair")
		local canshield = self:GetClientNumber("doshield")
		local shieldval = tonumber(self:GetClientNumber("shield"))
		
		if (canrepair) and (ent.Damage) then
			ent:RepairDamage()
		end
		
		if (canshield) and (ent.Damage) then
			ent:DamageSetShield(shieldval)
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

		if (ent.Damage) then
			self:GetOwner():ConCommand("avehicle_repair_shield "..ent:DamageGetShield())
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
	panel:AddControl("Header", { Text = "#Tool_avehicle_repair_name", Description = "#Tool_avehicle_repair_desc" })
	panel:AddControl("CheckBox", {
		Label = "Repair",
		Description = "Repair the vehicle",
		Command = "avehicle_repair_dorepair"
	})
	panel:AddControl("CheckBox", {
		Label = "Set Shield",
		Description = "Set the shield value",
		Command = "avehicle_repair_doshield"
	})
	panel:AddControl("Slider", {
		Label = "Set Shield",
		Type = "Float",
		Description = "Set the shield value",
		Min = "1",
		Max = "100",
		Command = "avehicle_repair_shield"
	})
end
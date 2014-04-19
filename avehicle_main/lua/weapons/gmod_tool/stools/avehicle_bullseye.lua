if SERVER then
	AddCSLuaFile( "weapons/gmod_tool/stools/avehicle_repair.lua" )
end

--TOOL.AddToMenu		= true
TOOL.Tab			= "AVehicles"
TOOL.Category		= "Tools"			
TOOL.Name			= "NPC Bullseye"	
TOOL.Command		= nil			
TOOL.ConfigName		= ""		


TOOL.ClientConVar[ "npc_class" ] = "zombie"
TOOL.ClientConVar[ "disposition" ] = "hate"

if CLIENT then
	language.Add( "Tool_avehicle_bullseye_name", "Alienate NPC Bullseye" )
	language.Add( "Tool_avehicle_bullseye_desc", "Add/Remove bullseye to AVehicle." )
	language.Add( "Tool_avehicle_bullseye_0", "Reload to install bullseye. Primary/Scondary to set relationship." )
end

local function GetNPCS(class)
	local npcs = ents.FindByClass("npc_"..class) or {}
	return npcs
end

local function BullseyeInstall(pos, avehicle)
	if not IsValid(avehicle) then return nil end
	local e = ents.Create("npc_bullseye")
	if IsValid(e) then
		e:SetPos(pos)
		e:SetAngles(avehicle:GetAngles())
		e:SetParent(avehicle)
		e:SetMaxHealth(10000)
		e:SetHealth(10000)
		e:SetSolid(SOLID_NONE)
		e.IgnoreView = true			--This is used to make shure we don't view our own entities
		e:Spawn()
		if e:IsNPC() then

		end
		table.insert(avehicle.Gagets.Bullseyes,e)
		return e
	end
	return nil
end

function TOOL:LeftClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	local class = self:GetClientInfo("npc_class") or "*"
	local disposition = self:GetClientNumber("disposition")
	if (ent.IsAVehicle) and (ent.Gagets.Bullseyes) then
		for _,v in pairs(ent.Gagets.Bullseyes) do
			if IsValid(v) and v:IsNPC() then
				for _,n in pairs(GetNPCS(class)) do
					if IsValid(n) and n:IsNPC() then
						n:AddEntityRelationship(v, disposition, 20)
					end
				end
			end
		end
		return true
	end
	return false
end

function TOOL:RightClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	local class = self:GetClientInfo("npc_class") or "*"
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	local disposition = self:GetClientNumber("disposition")
	if (ent.IsAVehicle) and (ent.Gagets.Bullseyes) then
		for _,v in pairs(ent.Gagets.Bullseyes) do
			if IsValid(v) and v:IsNPC() then
				for _,n in pairs(GetNPCS(class)) do
					if IsValid(n) and n:IsNPC() then
						n:AddEntityRelationship(v, disposition, 99)
					end
				end
			end
		end
		return true
	end
	return false
end

function TOOL:Think()

end

function TOOL:Reload( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (!ent.IsAVehicle) then return false end
	if (CLIENT) then return true end
	
	if (ent.IsAVehicle) then
		ent.Gagets = ent.Gagets or {} --Create these if they don't exist.
		ent.Gagets.Bullseyes = ent.Gagets.Bullseyes or {} --Create these if they don't exist.
		BullseyeInstall(trace.HitPos, ent)
		return true
	end
	return false
end



function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_avehicle_bullseye_name", Description = "#Tool_avehicle_bullseye_desc" })
	panel:AddControl("Label", {Text = "NPC Disposition"})
	panel:AddControl("ComboBox", {
		Label = "NPC Disposition",
		MenuButton = 0,
		Options = {
				["Hate"] = { avehicle_bullseye_disposition = "1" },
				["Fear"] = { avehicle_bullseye_disposition = "2" },
				["Like"] = { avehicle_bullseye_disposition = "3" },
				["Neutral"] = { avehicle_bullseye_disposition = "4" }
			}
	})
	panel:AddControl("TextBox", {
		Label = "NPC Class (npc_...)",
		Command = "avehicle_bullseye_npc_class",
		MaxLength = "200"
	})
end
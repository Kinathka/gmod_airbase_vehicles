if SERVER then
	--AddCSLuaFile( "weapons/gmod_tool/stools/avehicle_info_printer.lua" )
end

--TOOL.AddToMenu		= true
TOOL.Tab			= "AVehicles"
TOOL.Category		= "Developer"			
TOOL.Name			= "Info Tool"	
TOOL.Command		= nil			
TOOL.ConfigName		= ""	
TOOL.AdminSpawnable	= true		


if CLIENT then
	language.Add( "Tool_avehicle_info_printer_name", "Alienate Info Tool" )
	language.Add( "Tool_avehicle_info_printer_desc", "Prints entity angles and vectors etc." )
	language.Add( "Tool_avehicle_info_printer_0", "Left click to get entity. Right click to get first entity of two related entities." )
	language.Add( "Tool_avehicle_info_printer_1", "Right click another entity to get the related entity info." )
end


local function PrintEntInfo(ply, ent,trace)
	if IsValid(ent) then
		local info = "Info Tool: \n"
		local info2 = "Entity Phys Info: \n"
		local info3 = "Entity Directions: \n"
		info = info.."Entity Name: "..tostring(ent:GetName()).."\n"
		info = info.."Entity Class: "..tostring(ent:GetClass()).."\n"
		info = info.."Entity Model: "..tostring(ent:GetModel()).."\n"
		info = info.."Entity Skin: "..tostring(ent:GetSkin()).."\n"
		info = info.."Entity Velocity: "..tostring(ent:GetVelocity()).."\n"
		info = info.."Entity World Pos: "..tostring(ent:GetPos()).."\n"
		info = info.."Entity World Angles: "..tostring(ent:GetAngles()).."\n"
		info = info.."Entity Bone count: "..tostring(ent:GetBoneCount() ).."\n"
		info = info.."Entity Phys Attacker: "..tostring(ent:GetPhysicsAttacker() ).."\n"
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			info2 = info2.."Entity1 Phys Mass: "..tostring(phys:GetMass()).."\n"
			info2 = info2.."Entity1 Phys Volume: "..tostring(phys:GetVolume()).."\n"
			info2 = info2.."Entity1 Phys Material: "..tostring(phys:GetMaterial()).."\n"
			info2 = info2.."Entity1 Phys Inertia: "..tostring(phys:GetInertia()).."\n"
			info2 = info2.."Entity1 Phys Energy: "..tostring(phys:GetEnergy()).."\n"
		end
		info2 = info2.."Entity Worldspace(Length, Width, Height): "..tostring(ent:WorldSpaceAABB() ).."\n"
		
		--info3 = info3.."Entity Forward vector: "..tostring(ent:GetForward()).."\n"
		--info3 = info3.."Entity Up vector: "..tostring(ent:GetUp()).."\n"
		--info3 = info3.."Entity Right vector: "..tostring(ent:GetRight()).."\n"
		info3 = info3.."Trace local to Entity info:\n"
		info3 = info3.."HitPos local to entity: "..tostring(ent:WorldToLocal(trace.HitPos)).."\n"
		info3 = info3.."HitAngle local to entity: "..tostring(ent:WorldToLocalAngles(trace.HitPos:Angle())).."\n"
		ply:SendLua("LocalPlayer():ChatPrint( \"See console for the info... \")")
		MsgN(info)
		Msg(info2)
		Msg(info3)
		return true
	end
	return false
end

local function PrintEntInfo2(ply, ent, ent2)
	if IsValid(ent) then
		local info = "Info Tool: \n"
		local info2 = ""
		local info3 = ""
		info = info.."Entity1 Name: "..tostring(ent:GetName()).."\n"
		info = info.."Entity1 Class: "..tostring(ent:GetClass()).."\n"
		info = info.."Entity1 Model: "..tostring(ent:GetModel()).."\n"
		info = info.."Entity1 World Pos: "..tostring(ent:GetPos()).."\n"
		info = info.."Entity1 World Angles: "..tostring(ent:GetAngles()).."\n"
		if IsValid(ent2) then
			info2 = info2.."Entity2 Name: "..tostring(ent2:GetName()).."\n"
			info2 = info2.."Entity2 Class: "..tostring(ent2:GetClass()).."\n"
			info2 = info2.."Entity2 Model: "..tostring(ent2:GetModel()).."\n"
			info2 = info2.."Entity2 World Pos: "..tostring(ent2:GetPos())..")\n"
			info2 = info2.."Entity2 World Angles: "..tostring(ent2:GetAngles()).."\n"
			
			info3 = info3.."\nEntity2 local Pos to Entity1: "..tostring(ent:WorldToLocal(ent2:GetPos())).."\n"
			info3 = info3.."Entity2 local Angles to Entity1: "..tostring(ent:WorldToLocalAngles(ent2:GetAngles())).."\n"
		end
		ply:SendLua("LocalPlayer():ChatPrint( \"See console for the info... \")")
		MsgN(info)
		Msg(info2)
		Msg(info3)
		return true
	end
	return false
end

function TOOL:LeftClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	local ent = trace.Entity
	if (CLIENT) then return true end
	if not IsValid(ent) then return false end
	local ply = self:GetOwner()
	if ply:IsAdmin() then
		PrintEntInfo(ply, ent, trace)
		return true
	else
		ply:SendLua("LocalPlayer():ChatPrint( \"You need to be admin to use this! \")")
	end	
	
	return false
end

function TOOL:RightClick( trace )
	if (!IsValid(trace.Entity)) then return false end
	if (CLIENT) then return true end
	local ply = self:GetOwner()
	if ply:IsAdmin() then
		if (self:GetStage() == 0) then
			self.MasterEnt = trace.Entity
			self:SetStage(1)
			return true
		elseif self:GetStage() == 1 then
			if self.MasterEnt then
				PrintEntInfo2( ply, self.MasterEnt, trace.Entity)
				self:SetStage(0)
				self.MasterEnt = nil
				return true
			end
		else
			return false
		end
	else
		ply:SendLua("LocalPlayer():ChatPrint( \"You need to be admin to use this! \")")
	end
	
	return false
end


function TOOL:Reload( trace )
	self.MasterEnt = nil
end

function TOOL:Think()

end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_avehicle_refuel_name", Description = "#Tool_avehicle_refuel_desc" })

end
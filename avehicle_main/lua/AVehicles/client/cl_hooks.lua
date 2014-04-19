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
-- AddCSLua done in avehicles_start.lua
-------------------------------------------------------------- THE HEADER ----------------------------------------------------------------------------

---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
AVehicles.Hooks.DEFAULT_FOV = 90

-----------------------------------HudPaint Hook @ Warkanum
function AVehicles.Hooks.DrawClHud()
	if(!LocalPlayer() or !LocalPlayer():IsValid()) then return end
	if (AVehicles.Vehicle.IsIn) then --and (AVehicles.Vehicle.PodType != 1) then
		if (IsValid(AVehicles.Vehicle.Ent) and AVehicles.Vehicle.Ent~=LocalPlayer() and (AVehicles.Vehicle.PodType != 1))  then
			if AVehicles.Vehicle.Ent.CustomHud then
				AVehicles.Vehicle.Ent:DrawHud()
			end
		end
	end
end
hook.Add("HUDPaint", "AVehicleHud", AVehicles.Hooks.DrawClHud)

------------ Local rehook function
local function rehook()
	AVehicles.Hooks.OldCalcAVView = GAMEMODE.CalcVehicleThirdPersonView
	GAMEMODE.CalcVehicleThirdPersonView = AVehicles.Hooks.AVehicle_ViewCalc
end

hook.Add( "Initialize", "UpdateAVGMHooks", rehook )


----------------------------Vehicle THird person Calculations @ Warkanum
function AVehicles.Hooks.AVehicle_ViewCalc(Vehicle, ply, viewtable )
	--garrysmod 13 fucked up, testing here
	view = AVehicles.Hooks.OldCalcAVView(Vehicle,ply,viewtable)
	
	if (AVehicles.Vehicle.IsIn) and (AVehicles.Vehicle.Ent) then -- and (AVehicles.Vehicle.PodType != 1)  then
		local vEnt = AVehicles.Vehicle.Ent
		--if (vEnt:GetClass() == "avehicle_revseat") and (vEnt.AvehiclePodType >= 1) then return view end --Don't allow weapon seat views.
		if (IsValid(vEnt) and vEnt~=LocalPlayer()) then
			view.angles = AVehicles.Tools.NormalizeAngles(view.angles)
			if AVehicles.Vehicle.LockedFPV then
				view = vEnt:ClViewCalcFP(view.origin, view.angles, view.fov or AVehicles.Hooks.DEFAULT_FOV) --Just check if we are TP and Locked. Confusing but...
			elseif AVehicles.Vehicle.ViewThirdPerson then
				if not (GetConVarNumber("AVehicles_thirdpersonrotation") >= 1) then
					view.angles.r = 0
				end
				view = vEnt:ClViewCalc(view.origin, view.angles, view.fov or AVehicles.Hooks.DEFAULT_FOV)
			--else --We don't override the normal first person. Handled by the seats.
			end
		end
	end	
	
	return view --We must always return because we are overriding the Gamemode function.
end

--Hooks for Avehicles pod and Locked First person.  @ Warkanum
hook.Add("CalcView", "AVehicles_pod_CalcView", function(ply,origin,angles,fov,nearZ,farZ)
	local view = {}
	view.ply = ply
	view.origin = origin
	view.angles = angles
	view.fov = fov
	view.nearZ = nearZ
	view.farZ = farZ
	
	if (AVehicles.Vehicle.IsIn) and IsEntity(AVehicles.Vehicle.Ent) then
		local vEnt = AVehicles.Vehicle.Ent 

		if (IsEntity(vEnt) and vEnt~=LocalPlayer()) then

			view.angles = AVehicles.Tools.NormalizeAngles(view.angles)
			--if (vEnt:GetClass() == "avehicle_revseat") and (vEnt.AvehiclePodType >= 1) then --Don't allow weapon seat views.
				if AVehicles.Vehicle.LockedFPV then --and not AVehicles.Vehicle.ViewThirdPerson then

					return vEnt:ClViewCalcFP(view.origin, view.angles, view.fov or AVehicles.Hooks.DEFAULT_FOV) --Just check if we are TP and Locked. Confusing but...
				else
					local newview = vEnt:ClViewCalc(origin, angles, fov)
					view.origin = newview.origin
					view.angles = newview.angles
					view.fov = newview.fov
				end
			--end
		else
			return view
		end
	end
	
	return view
end)

local y = 0
local x = 0 
local r = 0
--Sends locked first person mousemove to the server. @ Warkanum
--this gets fuck up on singleplayer sometimes. Don't know why @ Warkanum
function AVehicles.Hooks.CreateMove(UCMD)
    if AVehicles.Vehicle.IsIn then
		if AVehicles.Vehicle.LockedFPV then
			//RunConsoleCommand("AVehicles_Impulse.MouseData",UCMD:GetMouseX(), UCMD:GetMouseY())
				net.Start( "AVehicles_Impulse_MouseData");
				net.WriteFloat(tonumber(UCMD:GetMouseX()));
				net.WriteFloat(tonumber(UCMD:GetMouseY()));
				net.SendToServer();
		end
		return true
	end
	return false
end
hook.Add("CreateMove", "AVehicles.Hooks.CreateMove", AVehicles.Hooks.CreateMove)


------------------Load / Save Keyfiles concommand hooks.   @   Warkanum
function AVehicles.Hooks.Cmd_GenerateKeyFiles( player, command, arguments )
	for sk,sv in pairs(AVehicles.Keys.Bindings) do
		AVehicles.Keys.SaveToFile(sk)
	end
end

function AVehicles.Hooks.Cmd_LoadKeyFiles( player, command, arguments )
	for sk,sv in pairs(AVehicles.Keys.Bindings) do
		AVehicles.Keys.LoadFromFile(sk)
	end
end

concommand.Add( "AVehicles_CreateKeymapFiles", AVehicles.Hooks.Cmd_GenerateKeyFiles) 
concommand.Add( "AVehicles_LoadKeymapFiles", AVehicles.Hooks.Cmd_LoadKeyFiles) 

/*
Developer Code hits @ warkanum
# Hook on createmove. Used to make player move limitless.
#     local x = 0   
#     local y = 0   
#     local ply = LocalPlayer()  
#     hook.Add("CreateMove", "Get Mouse Delta", function(ucmd)  
#         local sensitivity = 50  
#         x = x + (ucmd:GetMouseX() / (ply:GetInfo("sensitivity") * ply:GetInfo("m_yaw") < 0 and -sensitivity or sensitivity))  
#         y = y + (ucmd:GetMouseY() / (ply:GetInfo("sensitivity") * ply:GetInfo("m_pitch") < 0 and -sensitivity or sensitivity))  
#         --y = math.Clamp(y,-89,89) this limits the view  
#         ucmd:SetViewAngles(Angle(y,-x,0))  
#     end)  


hook.Add("CreateMove", "AVehicle:Seat:CreateMove", function(ucmd)
			if LocalPlayer():GetNWBool("AVehicleSeatOccupied") then
				if LocalPlayer():KeyDown(IN_USE) and LocalPlayer():KeyDown(IN_ATTACK) 
					and (IsValid(LocalPlayer():GetActiveWeapon()) 
					and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun") then return end
				
				local sensitivity = 50
				x = x + (ucmd:GetMouseX() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_yaw") < 0 and -sensitivity or sensitivity))
				y = y + (ucmd:GetMouseY() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_pitch") < 0 and -sensitivity or sensitivity))
				y = math.Clamp(y,-89,89)
				ucmd:SetViewAngles(Angle(y,-x,0))
				return true
			end
		end);

*/
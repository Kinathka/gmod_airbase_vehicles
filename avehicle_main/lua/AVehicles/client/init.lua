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
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.Hooks = {}
AVehicles.Vehicle = {}
AVehicles.Vehicle.IsIn = false
AVehicles.Vehicle.LockedFPV = false
AVehicles.Vehicle.Pos = -1
AVehicles.Vehicle.Ent = nil
AVehicles.Vehicle.Schema = " "
AVehicles.Vehicle.PodType = 0
AVehicles.Vehicle.ViewThirdPerson = true
AVehicles.Vehicle.LockedFPV = false
AVehicles.Hud = {}
AVehicles.Hud.DefaultHud = false
---------------------------------------------------------------The Body, Code----------------------------------------

/*
function AVehicles.CFGGetSYNC(data)
	AVehicles.Installed = true
	local objname = data:ReadString()
	local name = data:ReadString()
	AVehicles.CFG[objname] = {}
	AVehicles.CFG[objname][name] = {}
	
	for i=1,data:ReadChar() do
		local k = data:ReadString();
		local t = data:ReadChar(); -- What type are we?
		if(t == 0) then
			AVehicles.CFG[objname][name][k] = data:ReadBool();
		elseif(t == 1) then
			AVehicles.CFG[objname][name][k] = data:ReadString();
		elseif(t == 2) then
			AVehicles.CFG[objname][name][k] = data:ReadFloat();
		elseif(t == 3) then
			AVehicles.CFG[objname][name][k] = data:ReadChar();
		elseif(t == 4) then
			AVehicles.CFG[objname][name][k] = data:ReadShort();
		elseif(t == 5) then
			AVehicles.CFG[objname][name][k] = data:ReadLong();
		end
	end
	--Msg("1!!!!!!!1:" .. table.ToString(AVehicles.CFG[objname][name], objname..name, true))
end
usermessage.Hook("AVehicles_CFG",AVehicles.CFGGetSYNC);
*/
--Convars
CreateClientConVar("AVehicles_MouseLFPSensitivity", "2.0", true, true)

if not ConVarExists("AVehicles_thirdpersonrotation") then
    CreateConVar("AVehicles_thirdpersonrotation", '1', FCVAR_NOTIFY + FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_USERINFO + FCVAR_CLIENTDLL, "Rotates the client view with vehicle in third person mode.")
end

if not ConVarExists("AVehicles_hudposoverride") then
    CreateConVar("AVehicles_hudposoverride", "0", FCVAR_NOTIFY + FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_USERINFO + FCVAR_CLIENTDLL, "Sets the hud position: 0=default,1=BL,2=BC,3=BR,4=TL,5=TC,6=TR")
end

/* Depricated
usermessage.Hook("AVehicles_IsOnServer",
	function()
		AVehicles.Installed = true
		RunConsoleCommand("AVehicles_Impulse.MouseData",0, 0)
		----We can also initialize stuff here!
	end
)
*/
net.Receive("AVehicles_IsOnServer", 
	function( length, client )
		local ison = (net.ReadBit() > 0);
		AVehicles.Installed = ison;
		net.Start( "AVehicles_Impulse_MouseData");
		net.WriteFloat(tonumber(0));
		net.WriteFloat(tonumber(0));
		net.SendToServer();
		----We can also initialize stuff here!
	end
)

--Set true if the player is in a vehicle	@ Warkanum
/*
usermessage.Hook("AVehicles_IsInVehicle",
	function(um)
		AVehicles.Vehicle.IsIn = um:ReadBool() or false
		AVehicles.Vehicle.Pos = um:ReadShort() or -1
		AVehicles.Vehicle.Ent = um:ReadEntity() or nil
		AVehicles.Vehicle.Schema = um:ReadString() or " "
		AVehicles.Vehicle.PodType = um:ReadShort() or 0
	end
)
*/
net.Receive("AVehicles_IsInVehicle", 
	function( length, client )
		AVehicles.Vehicle.IsIn = (net.ReadBit() > 0) or false;
		AVehicles.Vehicle.Pos = net.ReadInt(8) or -1;
		AVehicles.Vehicle.Ent = net.ReadEntity() or nil;
		AVehicles.Vehicle.Schema =  net.ReadString() or " ";
		AVehicles.Vehicle.PodType = net.ReadInt(8) or 0;
	end
)

--Usermessage Hook for AVehicle pod
/*
usermessage.Hook("AVehicle_pod_enter", function(umr)
	local ply = umr:ReadEntity()
	local vehicle = umr:ReadEntity()
	hook.Call("PlayerEnteredVehicle", gmod.GetGamemode(), ply, vehicle, 1)
end)*/
net.Receive("AVehicle_pod_enter", 
	function( length, client )
		local ply = net.ReadEntity();
		local vehicle = net.ReadEntity();
		hook.Call("PlayerEnteredVehicle", gmod.GetGamemode(), ply, vehicle, 1)
	end
)


--We hide our default hud if we are in the vehicle	@ Warkanum
function AVehicles.Hud.HideHUD ( HudName )
	if (not AVehicles.Hud.DefaultHud) and AVehicles.Vehicle.IsIn and (AVehicles.Vehicle.PodType != 1)then
		if (HudName == "CHudHealth" or HudName == "CHudBattery" 
			or HudName == "CHudAmmo"  or HudName == "CHudSecondaryAmmo") then
			return false
		end
	end
end
hook.Add( "HUDShouldDraw", "AVehicles.Hud.HideHUD", AVehicles.Hud.HideHUD ) 

--Toggels the clients view 	@ Warkanum
local lastviewmode = 0
function AVehicles.ViewToggel()
	if lastviewmode == 0 then
		AVehicles.SetViewMode(1)
		lastviewmode = 1
	elseif lastviewmode == 1 then
									//so there is a bug. we remove this view for now
		AVehicles.SetViewMode(2)//2
		lastviewmode = 2//2
	elseif lastviewmode == 2 then
		AVehicles.SetViewMode(0)
		lastviewmode = 0
	else
		lastviewmode = 0
	end
end

--Set the viewmode of the vehicles. @ Warkanum
function AVehicles.SetViewMode(mode)
	if AVehicles.Vehicle.IsIn then
		if mode == 0 then
			RunConsoleCommand( "gmod_vehicle_viewmode", "1")
			RunConsoleCommand( "AVehicles_Impulse.View", "0") --this is used for server viewmode. Like mouse etc.
			AVehicles.Vehicle.ViewThirdPerson = true
			AVehicles.Vehicle.LockedFPV = false
		elseif mode == 1 then
			RunConsoleCommand( "gmod_vehicle_viewmode", "0")
			RunConsoleCommand( "AVehicles_Impulse.View", "1")
			AVehicles.Vehicle.ViewThirdPerson = false
			AVehicles.Vehicle.LockedFPV = false
		elseif mode == 2 then
			RunConsoleCommand( "gmod_vehicle_viewmode", "1") 
			RunConsoleCommand( "AVehicles_Impulse.View", "2")
			AVehicles.Vehicle.ViewThirdPerson = false
			AVehicles.Vehicle.LockedFPV = true
		end
	end
end

--Command to toggel client viewmode @ Warkanum
/*
concommand.Add("AVehicles_SetViewMode", function(p,_,args)
	if IsValid(p) and p == LocalPlayer() then
		if args[1] == "0" then
			AVehicles.SetViewMode(0)
		elseif args[1] == "1" then
			AVehicles.SetViewMode(1)
		elseif args[1] == "2" then
			AVehicles.SetViewMode(2)
		end
	end
end)
*/

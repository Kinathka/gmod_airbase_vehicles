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
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.Vehicle = AVehicles.Vehicle or {}
AVehicles.SVCFG = AVehicles.SVCFG or {}
AVehicles.Vehicle.PlayersThirdPersonView = AVehicles.Vehicle.PlayersThirdPersonView or {}  --Stores a table with players and their active views.
AVehicles.Vehicle.PlayersMouseData = AVehicles.Vehicle.PlayersMouseData or {}  --Stores data about the players mousedata.
AVehicles.Vehicle.PlayersAimPos = AVehicles.Vehicle.PlayersAimPos or {}
---------------------------------------------------------------The Body, Code----------------------------------------

//lets register net messages
//Cache the message
util.AddNetworkString( "AVehicles_IsOnServer" );
util.AddNetworkString( "AVehicles_IsInVehicle" );
util.AddNetworkString( "AVehicles_Impulse_MouseData");

if !ConVarExists("avehicles_cvar_vehicle_playerdamage") then
    CreateConVar("avehicles_cvar_vehicle_playerdamage", '1', FCVAR_NOTIFY, "Should players take damage when they are inside the vehicles?")
end

if !ConVarExists("avehicles_cvar_vehicle_damageshake") then
    CreateConVar("avehicles_cvar_vehicle_damageshake", '0', FCVAR_NOTIFY, "Shake players when vehicle gets damaged! (multiplier)")
end

if !ConVarExists("avehicles_cvar_vehicle_collisioneffects") then
    CreateConVar("avehicles_cvar_vehicle_collisioneffects", '1', FCVAR_NOTIFY, "Enable advanced collision effects!")
end

if !ConVarExists("avehicles_cvar_vehicle_fuelsystem") then
    CreateConVar("avehicles_cvar_vehicle_fuelsystem", '1', FCVAR_NOTIFY, "Enable the fuel system!")
end

if !ConVarExists("avehicles_cvar_newmovesystem") then
    CreateConVar("avehicles_cvar_newmovesystem", '0', FCVAR_NOTIFY, "USe the new move system!")
end

--Load serverside settings for avehicles, got some code from Avon's stargates with permission. @ warkanum
function AVehicles.LoadSettings()
	if(not AVehicles.INIParser) then include("ini_parser.lua") end;
	local ini = AVehicles.INIParser:new("AVehicles/config.ini");
	if (ini and IsValid(ini)) then
		for name,cfg in pairs(ini:get()) do
			if(name ~= "config") then
				AVehicles.SVCFG[name] = {};
				for k,v in pairs(cfg[1]) do
					v=v:Trim();
					local number = tonumber(v);
					if(number) then 
						v = number;
					elseif(v == "false" or v == "true") then
						v = util.tobool(v);
					end
					AVehicles.SVCFG[name][k] = v;

				end
			end
		end
	end
end
AVehicles.LoadSettings();
concommand.Add("Avehicles_reloadSettings",AVehicles.LoadSettings);

function AVehicles.Hooks.PlayerInitialSpawn(ply) 
	if(ply and ply:IsValid() and ply:IsPlayer()) then
		net.Start("AVehicles_IsOnServer");
		net.WriteBit(true);
		net.Send(ply);
	end
end
hook.Add("PlayerInitialSpawn","AVehicles.Hooks.PlayerInitialSpawn",AVehicles.Hooks.PlayerInitialSpawn)

/*
function AVehicles.LoadConfig(objname,ply) 
	if((not ply or ply:IsAdmin()) and objname) then 
		AVehicles.CFG[objname] = {}
		if(not AVehicles.INIParser) then include("ini_parser.lua") end
		local ini = AVehicles.INIParser:new("AVehicles/"..objname..".ini")
		for name,cfg in pairs(ini:get()) do
			if(name ~= "config") then
				AVehicles.CFG[objname][name] = {}
				--local sync = AVehicles.Tools.String.TrimExplode((cfg[1].SYNC or ""), ",")
				
				for k,v in pairs(cfg[1]) do
					v=v:Trim()
					local number = tonumber(v)
					if(number) then 
						v = number
					elseif(v == "false" or v == "true") then
						v = util.tobool(v)
					end
					AVehicles.CFG[objname][name][k] = v
					--Sync the values with the Client
					--if(table.HasValue(sync,k)) then
					--	AVehicles.CFG[objname].SYNC[name] = AVehicles.CFG[objname].SYNC[name] or {}
					--	AVehicles.CFG[objname].SYNC[name][k] = v
					--end
				end
			end
		end
		
	end
end
*/

--We must Call this function when we enter the vehicle (Get in and Eject)
function AVehicles.PlayerEnterVehicle(ply, active, pos, vEnt, schema, podtype)
	net.Start("AVehicles_IsInVehicle");
	net.WriteBit(active);
	net.WriteInt(tonumber(pos), 8);
	net.WriteEntity(vEnt);
	net.WriteString(schema);
	net.WriteInt(tonumber(podtype), 8);
	net.Send(ply);
end 

--------------------------------------------------Vehicle view from clients.	@ Warkanum
concommand.Add("AVehicles_Impulse.View",
	function(p,_,args)
		if args[1] == "0" then
			AVehicles.Vehicle.PlayersThirdPersonView[p] = 0
		elseif args[1] == "1" then
			AVehicles.Vehicle.PlayersThirdPersonView[p] = 1
		elseif args[1] == "2" then
			AVehicles.Vehicle.PlayersThirdPersonView[p] = 2
		else
			AVehicles.Vehicle.PlayersThirdPersonView[p] = 1
		end
	end
)


--Retrieves the clients custom mouse movements.@ Warkanum
/*
concommand.Add("AVehicles_Impulse.MouseData",
	function(p,_,args)
		local sense = 1.0
		if IsValid(p) then
			sense = p:GetInfoNum("AVehicles_MouseLFPSensitivity") or 2.0
		end
		AVehicles.Vehicle.PlayersMouseData[p] = AVehicles.Vehicle.PlayersMouseData[p] or {}
		AVehicles.Vehicle.PlayersMouseData[p].MouseX = (tonumber(args[1]) * sense)
		AVehicles.Vehicle.PlayersMouseData[p].MouseY = (tonumber(args[2]) * sense)
		--print("Ply send: ", args[1], args[2])
	end
)*/
net.Receive("AVehicles_Impulse_MouseData", 
	function( length, p)
		local sense = 1.0
		local x = net.ReadFloat();
		local y = net.ReadFloat();
		//MsgN("AV:MD: X="..x.." y="..y);
		if IsValid(p) and p:IsPlayer() then
			sense = p:GetInfoNum("AVehicles_MouseLFPSensitivity", 2.0) or 2.0
		end
		AVehicles.Vehicle.PlayersMouseData[p] = AVehicles.Vehicle.PlayersMouseData[p] or {}
		AVehicles.Vehicle.PlayersMouseData[p].MouseX = (tonumber(x) * sense)
		AVehicles.Vehicle.PlayersMouseData[p].MouseY = (tonumber(y) * sense)
	end
)

--New move system data. Captures player moveangles @Warkanum
function AVehicles.Hooks.SetupMove(ply, mv)
	if IsValid(ply) and ply:InVehicle() and (GetConVarNumber("avehicles_cvar_newmovesystem") >= 1) then
		AVehicles.Vehicle.PlayersMouseData[ply] = AVehicles.Vehicle.PlayersMouseData[ply] or {}
		AVehicles.Vehicle.PlayersMouseData[ply].MoveAngle = mv:GetMoveAngles() or Angle(0,0,0)
	end
end
hook.Add("SetupMove", "AVehicles.Hooks.SetupMove", AVehicles.Hooks.SetupMove)

--Check and fix server tags
if (AVehicles) and (AVehicles.Installed) then
	local othertags = GetConVarString("sv_tags");
	local avehiclesstr =  string.format("AVehicles%i", AVehicles.Version);
	if (othertags) then
		if not (string.find(othertags, avehiclesstr)) then
			local newtags = string.format("%s,%s",avehiclesstr, othertags);
			RunConsoleCommand("sv_tags", newtags);
		end
	else
		RunConsoleCommand("sv_tags", avehiclesstr);
	end
end




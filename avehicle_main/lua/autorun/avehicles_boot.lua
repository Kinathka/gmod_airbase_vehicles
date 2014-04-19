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
	Copyright (C) 2012  "Warkanum"
						a.k.a "Lifecell"
	Updated 2012-10
	
	Email: we.alienate@gmail.com (develoment@kinathka.co.za)
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

//Register AVehicles Global and set version information etc
AVehicles = {}
AVehicles.Version = 4.0;
AVehicles.Installed = true;
AVehicles.BootDetail = false; //detailed booting message
AVehicles.Version = 4.0;
AVehicles.VersionSVN = 64;
AVehicles.debugger = false;
AVehicles.LoadInterval = 0;
AVehicles.Coders = {" Main coder: Warkanum a.k.a Lifecell",
					" Help and support from: Avon ",
					" Heli Models and Inspiration: Flyboi"
				   };



local function modeget(mode)
	if (mode == "server" and SERVER) then return true; end
	if ((mode == "client" or mode == "vgui") and CLIENT) then return true; end
	if (mode == "shared") then return true; end
	return false;
end

function AVehicles.Load()
	//print startup messages
	MsgN("Alienate Vehicles [AVehicles] Booting...");
	MsgN("Author: Warkanum");
	MsgN("Version: "..AVehicles.Version.." (Gmod 13)");
	if SERVER then MsgN("AVehicles Mode: Server"); end
	if CLIENT then MsgN("AVehicles Mode: Client"); end
	
	AVehicles.LoadInterval = AVehicles.LoadInterval + 1;
	if (AVehicles.BootDetail) then MsgN("Interval: " ..AVehicles.LoadInterval); end
	
	
	for _,mode in pairs({"shared","server","client","vgui"}) do 
		if (modeget(mode) and file.Exists("AVehicles/"..mode.."/init.lua", "LUA")) then
			if (AVehicles.BootDetail) then MsgN("Loading: AVehicles/"..mode.."/init.lua"); end
			include("AVehicles/"..mode.."/init.lua");
		end
		
		local files, directories = file.Find("AVehicles/"..mode.."/*.lua", "LUA");
		//loop files
		for _,fp in pairs(files) do
			if(SERVER and mode ~= "server") then
				AddCSLuaFile("AVehicles/"..mode.."/"..fp)
			end
			if(modeget(mode) and fp ~= "init.lua") then
				if (AVehicles.BootDetail) then MsgN("Loading: AVehicles/"..mode.."/"..fp); end
				include("AVehicles/"..mode.."/"..fp);
			end
		end
	end
	if(SERVER) then
		AddCSLuaFile("autorun/avehicles_boot.lua") ;
		AddCSLuaFile("AVehicles/default_resources.lua");
		--AddCSLuaFile("weapons/gmod_tool/AVehicles_base_tool.lua");
	end
	
	--Add resources
	include("AVehicles/default_resources.lua");
	MsgN("!AVehicles Complete.\n");
end


function AVehicles.CallReload(p,override) -- Override is called in AVehicles_base/init.lua if someone calls lua_reloadents
	if(override or (not IsValid(p) or game.SinglePlayer() or p:IsAdmin())) then
		AVehicles.Load();
		for _,v in pairs(player.GetAll()) do
			v:SendLua("AVehicles.Load()")
		end
	else
		p:SendLua("AVehicles.Load()")
	end
end

if SERVER then
	concommand.Add("AVehicles__reload",AVehicles.CallReload)
end

//lets load the vehicles
AVehicles.Load();

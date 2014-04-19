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
-- AddCSLua done in avehicles_start.lua
---------------------------------------------------------------The Body, Code----------------------------------------
local KeysPressed = {}
local MousePressed = {}
local ThinkDelay = 0.1;		--Change this to increase/decrease the speed the client updates his keys on the server. 
							--This also increases network traffic!
							
AVehicles.Keys.Bindings = {}
---------------------------------------------------------------------------Return true if that routine is activated by a key @ Warkanum
function AVehicles.Keys.Active(name, routine)
	if (name and routine) then
		ply = LocalPlayer()
		routine = string.lower(routine)
		local newname = string.lower(name)
		if AVehicles.Keys.Routine[ply] then
			if AVehicles.Keys.Routine[ply][newname] then
				if AVehicles.Keys.Routine[ply][newname][routine] then
					return true
				end
			end
		end
	end
	return false
end


----------------------------------Send Pressed Keys to the server.  This way is much more efficient on network@ Warkanum
function AVehicles.Keys.SendToServer(name)
	ply = LocalPlayer()
	local keys = ""
	local active = ""
	local CanRun = false
	local newname = string.lower(name)
	if AVehicles.Keys.Routine[ply] then
		for sk, sv in pairs(AVehicles.Keys.Routine[ply]) do
			if (AVehicles.Vehicle.Schema == sk) then	--Only run the active shema
					for k,v in pairs(sv) do
						keys = keys .. tostring(k) .. ","
						if v then
							active = active .. "1,"
						else
							active = active .. "0,"
						end
					end
				CanRun = true
			end
		end
	end
	if CanRun then
		//RunConsoleCommand("AVehicles_Impulse.KeyRoutines",keys, active, newname)	
		//use of the new net function
		net.Start( "AVehicles_Impulse_KeyRoutines");
		net.WriteString(keys);
		net.WriteString(active);
		net.WriteString(newname);
		net.SendToServer();
	end
end

------------------------------------------Setup the routines, this must be called once in the sent client code  but is called in AVehicles.Keys.Install @ Warkanum
function AVehicles.Keys.Create(name, routines)
	if routines then
		local newname = string.lower(name)
		ply = LocalPlayer()
		AVehicles.Keys.Routine[ply] = AVehicles.Keys.Routine[ply] or {}
		AVehicles.Keys.Routine[ply][newname] = AVehicles.Keys.Routine[ply][newname] or {}
		AVehicles.Keys.Bindings[newname] = AVehicles.Keys.Bindings[newname] or  {}
		for k,v in pairs(routines) do
			v = string.lower(v)
			AVehicles.Keys.Routine[ply][newname][v] = false
			AVehicles.Keys.Bindings[newname][v] = AVehicles.Keys.Bindings[newname][v] or {}
			AVehicles.Keys.Bindings[newname][v].ismouse = false
			AVehicles.Keys.Bindings[newname][v].key = ""
			AVehicles.Keys.Bindings[newname][v].alt_ismouse = false
			AVehicles.Keys.Bindings[newname][v].alt_key = "~"  --Please note that the ~ is the character that says ignore me!
		end
		return true
	end
	return false
end

--------------------------------------------------------------------------------------------------Install the routines and binding tables - key bindings  (helper functions) @ Warkanum
local function Install_BindKey(name,k,v,rk,rv, keynames)
	local newname = string.lower(name)
	if k == string.lower(rv) then --Update this routine
		if string.find(keynames[rk], "MOUSE") then
			AVehicles.Keys.Bindings[newname][k].ismouse = true
			AVehicles.Keys.Bindings[newname][k].key = keynames[rk]
		elseif string.find(keynames[rk], "MWHEEL") then
			AVehicles.Keys.Bindings[newname][k].ismouse = true
			AVehicles.Keys.Bindings[newname][k].key = keynames[rk]
		else
			AVehicles.Keys.Bindings[newname][k].ismouse = false
			AVehicles.Keys.Bindings[newname][k].key = keynames[rk]
		end
	end
end

local function Install_BindAltKey(name,k,v,rk,rv, keynames)
	local newname = string.lower(name)
	if k == string.lower(rv) then --Update this routine
		if string.find(keynames[rk], "MOUSE") then
			AVehicles.Keys.Bindings[newname][k].alt_ismouse = true
			AVehicles.Keys.Bindings[newname][k].alt_key = keynames[rk]
		elseif string.find(keynames[rk], "MWHEEL") then
			AVehicles.Keys.Bindings[newname][k].alt_ismouse = true
			AVehicles.Keys.Bindings[newname][k].alt_key = keynames[rk]
		else
			AVehicles.Keys.Bindings[newname][k].alt_ismouse = false
			AVehicles.Keys.Bindings[newname][k].alt_key = keynames[rk]
		end
	end
end

--------------------------------------------------------------------------------------------------Install the routines and binding tables - key bindings @ Warkanum
function AVehicles.Keys.InstallKeyMap(name, keymap)
	if (name and keymap) then
		local newname = string.lower(name)
		local routines = {}
		local keynames = {}
		local altkeynames = {}
		for k,v in pairs(keymap) do
			routines[k] = v.routine
			keynames[k] = v.key
			altkeynames[k] = v.altkey or "~"
		end
		--MsgN(string.format("Installing Keymap: %s: \n%s ",newname , table.ToString(routines)))
		if AVehicles.Keys.Create(newname , routines) then
			
			for k,v in pairs(AVehicles.Keys.Bindings[newname ]) do
				k = string.lower(k)
				for rk,rv in pairs(routines) do
					Install_BindKey(newname ,k,v,rk,rv, keynames)
					if altkeynames[rk] then
						Install_BindAltKey(newname ,k,v,rk,rv, altkeynames)
					end
					
				end
			end
			--Also try to load the key settings from file
			if AVehicles.Keys.LoadFromFile(newname) then
			
			end
		end
	end
end

-- The old legacy function to bind the keys. This is just for backward compatibility! Use AVehicles.Keys.InstallKeyMap(name, keymap) instead.   @ Warkanum
-- This function doesn't support the new alt_key improvements. Better use InstallKeyMap, see above.
--The routines and keynames table indexes should be the same for correct binding. ex {"FW", "BW"} {"W", "S"}
function AVehicles.Keys.Install(name, routines, keys)
	if name and routines and keys then
		local newname = string.lower(name)
		local keymap = {}
		for k,v in pairs(routines) do
			keymap[k] = {}
			keymap[k].routine = routines[k]
			keymap[k].key = keys[k]
			keymap[k].altkey = "~"
		end
	AVehicles.Keys.InstallKeyMap(newname, keymap)
	end
end
--------------------------------------------------------------------------------------------------Update the routine - key bindings @ Warkanum
function AVehicles.Keys.UpdateOne(name, routine, keyname, altkeyname)
	if (routine and keyname and name) then
		local newname = string.lower(name)
		if AVehicles.Keys.Bindings[newname] then
			if AVehicles.Keys.Bindings[newname][routine] then
				if string.find(keyname, "MOUSE") then
					AVehicles.Keys.Bindings[newname][routine].ismouse = true
					AVehicles.Keys.Bindings[newname][routine].key = keyname
				elseif string.find(keyname, "MWHEEL") then
					AVehicles.Keys.Bindings[newname][routine].ismouse = true
					AVehicles.Keys.Bindings[newname][routine].key = keyname
				else
					AVehicles.Keys.Bindings[newname][routine].ismouse = false
					AVehicles.Keys.Bindings[newname][routine].key = keyname					
				end
				if altkeyname then
					if string.find(altkeyname, "MOUSE") then
						AVehicles.Keys.Bindings[newname][routine].alt_ismouse = true
						AVehicles.Keys.Bindings[newname][routine].alt_key = altkeyname or "~"
					elseif string.find(altkeyname, "MWHEEL") then
						AVehicles.Keys.Bindings[newname][routine].alt_ismouse = true
						AVehicles.Keys.Bindings[newname][routine].alt_key = altkeyname or "~"
					else
						AVehicles.Keys.Bindings[newname][routine].alt_ismouse = false
						AVehicles.Keys.Bindings[newname][routine].alt_key = altkeyname	or "~"	 			
					end
				end
				return true
			end
		end
	end
	return false
end

------------------------------------------------------------------------------------------------------Save the routines - key bindings  of a schema @ Warkanum
function AVehicles.Keys.SaveToFile(name)
	if (name) then
		local newname = string.lower(name)
		local binds = {}
		for k,v in pairs(AVehicles.Keys.Bindings[newname]) do
			k = string.lower(k)
			binds[k] = binds[k]  or {}
			binds[k].key = tostring(v.key)
			binds[k].ismouse = tostring(v.ismouse)
			binds[k].alt_key = tostring(v.alt_key)
			binds[k].alt_ismouse = tostring(v.alt_ismouse)
		end
		file.Write("AVehicles/keys/" ..newname .. ".txt", util.TableToKeyValues(binds))
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------Load the routines - key bindings  of a schema from a file @ Warkanum
function AVehicles.Keys.LoadFromFile(name)
	if name then
		local newname = string.lower(name)
		if file.Exists("AVehicles/keys/" ..newname .. ".txt", "DATA") then 
			local filedata = file.Read("AVehicles/keys/" ..newname .. ".txt") or ""
			local binds = util.KeyValuesToTable(filedata)
			if binds then
				for k,v in pairs(binds) do
					k = string.lower(k)
					AVehicles.Keys.Bindings[newname][k] = AVehicles.Keys.Bindings[newname][k] or {}
					AVehicles.Keys.Bindings[newname][k].ismouse = util.tobool(binds[k].ismouse)
					if (binds[k].key) then
						AVehicles.Keys.Bindings[newname][k].key = string.upper(binds[k].key)
					else
						AVehicles.Keys.Bindings[newname][k].key = "-1"
					end
					AVehicles.Keys.Bindings[newname][k].alt_ismouse = util.tobool(binds[k].alt_ismouse)
					if binds[k].alt_key then
						AVehicles.Keys.Bindings[newname][k].alt_key = string.upper(binds[k].alt_key)
					else
						AVehicles.Keys.Bindings[newname][k].alt_key = "-1"
					end
				end
			end
			return true
		end
	end
	return false
end

-------------------------------------------------------Bind Keys to Routines  helper function @ Warkanum
local function BindToRoutine(ply,key,altkey, name, routine, mouse, altmouse)
	local flag = false
	if mouse then
		if MousePressed[key] then 
			if not vgui.CursorVisible() then --So we can't move while we have a panel open.
				AVehicles.Keys.SetRoutineActive(ply, name, routine)
				flag = true
			end
		else
			AVehicles.Keys.SetRoutineInActive(ply, name, routine) 
		end
	end
	
	if altmouse and (not flag) then
		if MousePressed[altkey] then 
			if not vgui.CursorVisible() then --So we can't move while we have a panel open.
				AVehicles.Keys.SetRoutineActive(ply, name, routine)
				flag = true
			end
		else
			AVehicles.Keys.SetRoutineInActive(ply, name, routine) 
		end
		
	end
	
	if (not mouse) and (not flag) then
		if KeysPressed[key] then 
			if not vgui.CursorVisible() then --So we can't move while we have a panel open.
				AVehicles.Keys.SetRoutineActive(ply, name, routine)
				flag = true
			end
		else 
			AVehicles.Keys.SetRoutineInActive(ply, name, routine) 
		end
	end
	
	if (not altmouse) and (not flag) then
		if KeysPressed[altkey] then 
			if not vgui.CursorVisible() then --So we can't move while we have a panel open.
				AVehicles.Keys.SetRoutineActive(ply, name, routine) 
				flag = true
			end
		else 
			AVehicles.Keys.SetRoutineInActive(ply, name, routine) 
		end
	end

end

-------------------------------------------------------Bind Keys to Routines  @ Warkanum
------Helpers
local function GetAltKey(key) 
	if key then
		if not (key == "~") then
			return AVehicles.Keys.Keys[key]
		end
	end
	return KEY_NONE
end
local lastthink = 0
----------Main
function AVehicles.Keys.Bind()
	local ply = LocalPlayer()
	local Schema = ""
	for sk,sv in pairs(AVehicles.Keys.Bindings) do
		sk = string.lower(sk)
		if (AVehicles.Vehicle.Schema == sk) then	--Only run the active shema
			Schema = sk
			if sv then
				for k,v in pairs(sv) do
					k = string.lower(k)
					BindToRoutine(ply,AVehicles.Keys.Keys[v.key], GetAltKey(v.alt_key), sk, k, v.ismouse, v.alt_ismouse)
				end
			end
		end
	end
	
	if lastthink < CurTime() then
		lastthink = CurTime() + ThinkDelay 
		AVehicles.Keys.SendToServer(Schema)
	end
end

---------------------------------------------------- Hooks that check what keys the client pressed  @ Warkanum
local p = LocalPlayer()
function AVehicles.Hooks.CheckInputKey()
	if AVehicles.Vehicle.IsIn then --only run the binds if client is in the vehicle.
		for i=1, 106 do --I'm not going throug the xbox buttons, a waste
			if( input.IsKeyDown(i)) then
				KeysPressed[i] = true
			else
				KeysPressed[i] = false
			end
		end

		for i=MOUSE_FIRST, MOUSE_LAST do --The mouse buttons
			if not ((i == MOUSE_WHEEL_DOWN) or (i == MOUSE_WHEEL_UP )) then --Ignores the mouse event for these, handled with the bindpress hook (Gmod Problem)
				if(input.IsMouseDown(i)) then
					MousePressed[i] = true
				else
					MousePressed[i] = false
				end
			end
		end

		AVehicles.Keys.Bind()
		
		--Might aswell check if the player is in a pod, else eject him @ Warkanum
		if IsValid(p) then --In case of some magical weird event! SCI-FI, Yes.
			if not IsValid(p:GetVehicle()) then
				AVehicles.Vehicle.IsIn = false
				AVehicles.Vehicle.Pos = -1
				AVehicles.Vehicle.Ent = nil
			end
		end
	end
end
hook.Add("Think", "AVehicles.Hooks.CheckInputKey", AVehicles.Hooks.CheckInputKey)  

-----------------------------------------------Mouse wheel helper function @ Warkanum
local function MouseWheelTimer(key)
	MousePressed[key] = false
end

------------------------------------------------------Hook -------- I got this from Avon's code. Thanks Avon @ Warkanum
local lastbind = ""
function AVehicles.Hooks.PlayerBindPress(ply,bind, down)
	local bind = bind:Trim():lower()
	local key
	if (AVehicles.Vehicle.IsIn) then  --Remove the binds, like e for eject and ctrl for the view of the pod etc.
		if(bind == "invnext") then 
			key = MOUSE_WHEEL_DOWN 
		elseif(bind == "invprev") then
			key = MOUSE_WHEEL_UP
		end
		if(key) then
			MousePressed[key] = true
			if (AVehicles.Vehicle.IsIn) then AVehicles.Keys.Bind() end --Call the bind event, faster update
			timer.Simple(0.1, function() MouseWheelTimer(key);  end)
		end
	
		if vgui.CursorVisible() then
			return
		else
			--Block the binds in the block group if we are in the vehicle.

			/* Original
			local blockgroup = {"+duck", "+use", "+menu_context", "+menu", "noclip", "+reload", 
			"impulse 100", "+forward", "+back", "+moveleft", "+moveright", "+jump", "+walk", 
			"+speed" 
			}	
			*/
			--Updated because pod controllers use bind to detect keys. For passengers wire support.
			--We block the menu, noclip, duck(viewchange) and flashligh
			local blockgroup = {"+use","+duck","+menu_context", "+menu", "noclip", "impulse 100"}	
			for k,v in pairs(blockgroup) do
				if (string.find(bind, v) ) then
					--An exception for weapon pods.
					if (AVehicles.Vehicle.PodType == 1) and string.find(lastbind, "+walk") and (string.find(bind, "+use") 
						or string.find(bind, "+menu") or string.find(bind, "+menu_context")) then 
						lastbind = ""
						return
					end
					lastbind = ""
					return true --Don't allow this bind
				end
			end
			lastbind = bind
			return 
		end
		--AVehicles.Keys.Bind() --Just call this to update if think havent updated it yet.
	end
	return -- we must not change this else the player won't have his bindpress events
end
hook.Add("PlayerBindPress","AVehicles.Hooks.PlayerBind",AVehicles.Hooks.PlayerBindPress)


--Test
--AVehicles.Keys.Setup("default", {"FW","BW","LM","RM", "Engine", "roll0", "roll1", "SpeedUp", "SpeedDown"}) -- For testing do it manually
--AVehicles.Keys.Update("default", {"FW","BW","LM","RM", "Engine", "roll0", "roll1", "SpeedUp", "SpeedDown"}, {"W","S","A","D", "R", "MWHEELDOWN", "MWHEELUP", "SHIFT", "ALT"})
--AVehicles.Keys.SaveToFile("default")
--PrintTable(AVehicles.Keys.Bindings)
--AVehicles.Keys.LoadFromFile("default")
--Msg("After! \n\n")
--PrintTable(AVehicles.Keys.Bindings)
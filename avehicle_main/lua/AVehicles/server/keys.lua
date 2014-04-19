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

---------------------------------------------------------------The Body, Code----------------------------------------

util.AddNetworkString( "AVehicles_Impulse_KeyRoutines");

---------------------------------Get the Client Key bindings   Much better way than before! @ Warkanum
/*
concommand.Add("AVehicles_Impulse.KeyRoutines",
	function(p,_,args)
		local keys = {}
		local actions = {}
		keys = string.Explode(",", args[1]) 
		actions = string.Explode(",", args[2]) 
		for k,v in pairs(keys) do
			if v then
				--Msg("Key Pressed: ".. tostring(v) .. "   " .. tostring(actions[k]) ..  " Schema: " ..tostring(args[3]) .. "\n")
				if actions[k] == "1" then
					AVehicles.Keys.SetRoutineActive(p,args[3], v)
				else
					AVehicles.Keys.SetRoutineInActive(p,args[3], v)
				end
			end
		end
	end
)
*/

net.Receive("AVehicles_Impulse_KeyRoutines", 
	function( length, p)
		local keys = {}
		local actions = {}
		local nname = "";
	
		
		keys = string.Explode(",", net.ReadString());
		actions = string.Explode(",", net.ReadString()) ;
		nname = net.ReadString();
	
		
		for k,v in pairs(keys) do
			if v then
				--Msg("Key Pressed: ".. tostring(v) .. "   " .. tostring(actions[k]) ..  " Schema: " ..tostring(args[3]) .. "\n")
				if actions[k] == "1" then
					AVehicles.Keys.SetRoutineActive(p,nname, v)
				else
					AVehicles.Keys.SetRoutineInActive(p,nname, v)
				end
			end
		end
	end 
);



---------------------------------------------------------------------------Return true if that routine is activated by a key @ Warkanum
function AVehicles.Keys.Active(ply, name, routine)
	if (ply and name) then
		if AVehicles.Keys.Routine[ply] then
			routine = string.lower(routine)
			local newname = string.lower(name)
			if AVehicles.Keys.Routine[ply][newname] then
				if AVehicles.Keys.Routine[ply][newname][routine] then
					return true
				end
			end
		end
	end
	return false
end



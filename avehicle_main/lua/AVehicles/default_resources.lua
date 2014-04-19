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

--To send stuff to client, disable if you have problems. 
if SERVER then
	AVehicles.Resource_AllowAddResource = false; --Disabled by default, so check cfg files.
	AVehicles.Resource_PRINTINFO = true;
	AVehicles.Resource_totalfiles = 0
	
	if AVehicles.SVCFG and AVehicles.SVCFG["addresources"] then
		AVehicles.Resource_AllowAddResource = AVehicles.SVCFG["addresources"]["enabled"] or false;
		AVehicles.Resource_PRINTINFO = AVehicles.SVCFG["addresources"]["printinfo"] or false;
	end

	if AVehicles.Resource_AllowAddResource then
		MsgN("AVehicles: Loading resources.... ")
	else
		MsgN("AVehicles: Loading resources is disabled, please copy content to clients.")
	end
	
	--Helper Function I got from wiki.garrysmod.org @ Warkanum
	--dir: The directory to search. ext: the files extention to search for. example *.mdl
	--addrelated: Boolean, do we add related files. Example vmt will add vtf if true.
	function AVehicles.Resource_AddDir(dir, ext, addrelated)
		AVehicles.Resource_AddDir(dir, ext, addrelated, true);
	end
	
	--Helper Function I got from wiki.garrysmod.org @ Warkanum
	--dir: The directory to search. ext: the files extention to search for. example *.mdl
	--addrelated: Boolean, do we add related files. Example vmt will add vtf if true.
	--recursive: True = Scan this folder and it's subfolders. False = Only add current folder files
	function AVehicles.Resource_AddDir(dir, ext, addrelated, recursive)
		if AVehicles.Resource_AllowAddResource then
			local list = file.FindDir("../"..dir.."/*");
			if recursive then
				for _, fdir in pairs(list) do
					if fdir != ".svn" then
						AVehicles.AddResourcesDir(dir.."/"..fdir, addrelated, true);
					end
				end
			end
			local filecnt = 0
			for k,v in pairs(file.Find("../"..dir.."/" ..ext)) do
				if addrelated then
					resource.AddFile(dir.."/"..v);
				else
					resource.AddSingleFile(dir.."/"..v);
				end
				filecnt = filecnt + 1
			end
			AVehicles.Resource_totalfiles = AVehicles.Resource_totalfiles + filecnt
			if AVehicles.Resource_PRINTINFO then
				MsgN("AVehicles: Adding resource dir - " ..dir .. ": " ..filecnt.." Files.");
			end
			
		end
	end

	--Add avehicles resources, used for checking and logging maybe later. @ warkanum
	--path: The path of the file. addrelated: Boolean, do we add related files. Example vmt will add vtf if true.
	function AVehicles.Resource_Add(path, addrelated)
		if AVehicles.Resource_AllowAddResource then
			if addrelated then
				resource.AddFile(path);
			else
				resource.AddSingleFile(path)
			end
			AVehicles.Resource_totalfiles = AVehicles.Resource_totalfiles + 1
			if AVehicles.Resource_PRINTINFO then
				MsgN("AVehicles: Adding resource file - '" ..path.."'.");
			end
		end
	end

	--Load default resources
	AVehicles.Resource_AddDir("materials/AVehicles/Hud", "*.vmt", false, false)
	AVehicles.Resource_AddDir("materials/AVehicles/Hud", "*.vtf", false, false)
	--Replaced by addir
	--AVehicles.Resource_Add("materials/AVehicles/Hud/passenger.vmt", true); 
	--AVehicles.Resource_Add("materials/AVehicles/Hud/revbar.vmt", true);
	--AVehicles.Resource_Add("materials/AVehicles/Hud/RightHud.vmt", true);
	AVehicles.Resource_Add("materials/VGUI/entities/avehicle_plyspawner.vmt", true);
	AVehicles.Resource_Add("sound/alienate/engine_snd.wav", false);
	AVehicles.Resource_Add("sound/alienate/JumperEnginev2.wav", false);
	AVehicles.Resource_Add("sound/alienate/vehicle_damaged.wav", false);
	
	if AVehicles.Resource_AllowAddResource then
		MsgN("AVehicles: Resources added so far: " .. AVehicles.Resource_totalfiles .. " files.")
	end
end
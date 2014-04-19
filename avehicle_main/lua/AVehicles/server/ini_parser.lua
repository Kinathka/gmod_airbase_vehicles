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

	INI-Parser to parse .ini files and read out the data
	Original Creator/Coder: aVoN
	Modified by Lifecell a.k.a Warkanum
	Thanks Avon!
*/

AVehicles = AVehicles or {}
AVehicles.INIParser = {}
-- ############## Loads an ini file (object) @ aVoN
function AVehicles.INIParser:new(file_,no_autotrim)
	local obj = {}
	setmetatable(obj,self)
	self.__index = function(t,n)
		local nodes = rawget(t,"nodes")
		if(nodes) then
			if(nodes[n]) then
				return nodes[n]
			end
		end
		return self[n] -- Returns self or the nodes if directly indexed
	end
	if(file.Exists(file_, "DATA")) then
		obj.file = file_
		obj.notrim = no_autotrim
		obj.content = file.Read(file_) -- Saves raw content of the file
		obj.nodes = {} -- Stores all nodes of the ini
	else
		Msg("AVehicles INIParser:new -> File "..file_.." does not exist!\n")
		return
	end
	obj:parse()
	return obj
end

-- ############## Strips comments from a line(string) @ aVoN
function AVehicles.INIParser:StripComment(line)
	local found_comment = line:find("[;#]")
	if(found_comment) then
		line = line:sub(1,found_comment-1):Trim() -- Removes any non neccessayry stuff
	end
	return line
end

-- ############## Strips quotes from a string (when an idiot added them...) (string) @ aVoN
function AVehicles.INIParser:StripQuotes(s)
	-- Replaces accidently added quotes from alphanumerical strings
	return s:gsub("^[\"'](.+)[\"']$","%1") --" <-- needed, to make my NotePad++ to show the functions below
end

-- ############## Parses the inifile to a table (void) @ aVoN
function AVehicles.INIParser:parse()
	local exploded = string.Explode("\n",self.content)
	local nodes = {}
	local cur_node = ""
	local cur_node_index = 1
	for k,v in pairs(exploded) do
		local line = self:StripComment(v):gsub("\n","")
		if(line ~= "") then -- Only add lines with contents (no commented lines)
			if(line:sub(1,1) == "[") then -- Holy shit, it's a node
				local node_end = line:find("%]")
				if(node_end) then
					local node = line:sub(2,node_end-1) -- Get single node name
					nodes[node] = nodes[node] or {}
					cur_node = node
					cur_node_index = table.getn(nodes[node])+1
				else
					Msg("AVehicles INIParser:parse -> Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": Expected node!\n")
					self = nil
					return
				end
			else
				if(cur_node == "") then
					Msg("AVehicles INIParser:parse -> Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No node specified!\n")
					self = nil
					return
				else
					local data = string.Explode("=",line)
					-- This is needed, because garry missed to add a limit to string.Explode
					local table_count = table.getn(data)
					if(table_count > 2) then
						for k=3,table_count do
							data[2] = data[2].."="..data[k]
							data[k] = nil
						end
					end
					if(table_count == 2) then
						local key = ""
						local value = ""
						if(self.notrim) then
							key = self:StripQuotes(data[1])
							value = self:StripQuotes(data[2])
						else
							key = self:StripQuotes(data[1]):Trim()
							value = self:StripQuotes(data[2]):Trim()
						end
						nodes[cur_node][cur_node_index] = nodes[cur_node][cur_node_index] or {}
						nodes[cur_node][cur_node_index][key] = value
					else
						Msg("AVehicles INIParser:parse -> Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No datablock specified!\n")
						self = nil
						return
					end
				end
			end
		end
	end
	self.nodes = nodes
	Msg("AVehicles INIParser:parse -> File "..self.file.. " successfully parsed\n")
end

-- ############## Either you index the object directly, when you know, which value to index, or you simply get the full INI content (table) @ aVoN
function AVehicles.INIParser:get()
	return self.nodes
end

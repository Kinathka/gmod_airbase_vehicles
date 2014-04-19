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
---------------------------------------------Five minutes gui @ Warkanum-------------------------------------------------------------

AVehicles.VGUI = AVehicles.VGUI or {}
AVehicles.VGUI.Keys = {}
BtnBind = {}

local ply = LocalPlayer()
local SelectedSchema = ""
local SelectedRoutine = ""
local SelectedKey = ""
local SelectedOldKey = ""
local SelectedAltKey = ""
local DblBindName = ""
local LoadedFromFile = false

function AVehicles.VGUI.Keys:GetKeys()
	local lst = {}
	local int = 0
	if (AVehicles.Keys.Keys) then
		for k,v in pairs(AVehicles.Keys.Keys) do
			int = int + 1
			lst[int] = k
		end
	end
	return lst
end

function AVehicles.VGUI.Keys:GetSchemas()
	local lst = {}
	local int = 0
	if (AVehicles.Keys.Routine[ply]) then
		for k,v in pairs(AVehicles.Keys.Routine[ply]) do
			int = int + 1
			lst[int] = k
		end
	end
	return lst
end

function AVehicles.VGUI.Keys:GetRoutines(name) 
	local lst = {}
	local int = 0
	if (AVehicles.Keys.Routine[ply] and AVehicles.Keys.Routine[ply][name]) then
		for k,v in pairs(AVehicles.Keys.Routine[ply][name]) do
			int = int + 1
			lst[int] = k
		end
	end
	return lst
end


function AVehicles.VGUI.Keys:GetBindings(name) 
	local lst = {}
	local int = 0
	if (AVehicles.Keys.Bindings[name]) then
		for k,v in pairs(AVehicles.Keys.Bindings[name]) do
			int = int + 1
			lst[int] = lst[int] or {}
			lst[int]["name"] = k
			lst[int]["key"] = v.key
			lst[int]["alt_key"] = v.alt_key
		end
	end
	return lst
end

local function GetRoutineKey(schema, name) 
	if schema and name then
		local binds = AVehicles.VGUI.Keys:GetBindings(schema) 
		for k,v in pairs(binds) do
			if (v.name == name) then
				return v.key
			end
		end
	end
	return ""
end

local function GetRoutineAltKey(schema, name) 
	if schema and name then
		local binds = AVehicles.VGUI.Keys:GetBindings(schema) 
		for k,v in pairs(binds) do
			if (v.name == name) then
				return v.alt_key
			end
		end
	end
	return ""
end

local function CanBind(schema, oldkey, newkey) 
	local binds = AVehicles.VGUI.Keys:GetBindings(schema)
	for k,v in pairs(binds) do
		if ( string.lower(v.key) == string.lower(newkey) ) then
			if not ( string.lower(v.key) == string.lower(oldkey) ) then
				DblBindName = v.name
				return false
			end
		end
	end
	DblBindName = ""
	return true
end

local function CanBindAlt(schema, oldkey, newkey) 
	local binds = AVehicles.VGUI.Keys:GetBindings(schema)
	local flag = true
	DblBindName = ""
	for k,v in pairs(binds) do
		if ( string.lower(v.alt_key) == string.lower(newkey) ) then
			if not ( string.lower(v.alt_key) == string.lower(oldkey) ) then
				DblBindName = v.name
				flag = false
			end
		end
	end
	
	for k,v in pairs(binds) do
		if ( string.lower(v.key) == string.lower(newkey) ) then
			if not ( string.lower(v.key) == string.lower(SelectedOldKey) ) then
				DblBindName = v.name
				flag = false
			end
		end
	end
	return flag
end


function AVehicles.VGUI.KeyGui( )
	--Load the key settings from file.
	if AVehicles.Keys.LoadFromFile(name) then LoadedFromFile = true	 else LoadedFromFile = false end
	--The Frame
	local Frame = vgui.Create( "DFrame" )
	Frame:SetSize( 500, 400 )
	Frame:SetPos( 100, 100 )
	Frame:SetVisible( true )
	Frame:MakePopup( )
	Frame:SetTitle("Air Vehicles Key Config" )
	Frame.Think = function()
		if input.IsKeyDown(KEY_ESCAPE) then
			Frame:Close()
		end
		return
	end
	
	---------------Predefined Labels----------------------
	--Bevel
	local RoutineGetLbl = vgui.Create( "DLabel", Frame )
	RoutineGetLbl:SetPos(0, 280)
	RoutineGetLbl:SetSize( 500, 1 )
	
	--Routine Name Label
	local RoutineNameLbl = vgui.Create( "DLabel", Frame )
	RoutineNameLbl:SetText("Routine: ")
	RoutineNameLbl:SetPos(10, 290)
	RoutineNameLbl:SetSize( 150, 15 )
	--Routine Default Label
	local RoutineKeyLbl = vgui.Create( "DLabel", Frame )
	RoutineKeyLbl:SetText("Default Key: ")
	RoutineKeyLbl:SetPos(10, 310)
	RoutineKeyLbl:SetSize( 150, 15 )
	--Routine Default Alt Label
	local RoutineAltKeyLbl = vgui.Create( "DLabel", Frame )
	RoutineAltKeyLbl:SetText("Alt Key: ")
	RoutineAltKeyLbl:SetPos(10, 330)
	RoutineAltKeyLbl:SetSize( 150, 15 )
	--Routine New Label
	local RoutineNewKeyLbl = vgui.Create( "DLabel", Frame )
	RoutineNewKeyLbl:SetText("New Key: ")
	RoutineNewKeyLbl:SetPos(10, 350)
	RoutineNewKeyLbl:SetSize( 150, 15 )
	--Save Label
	local SaveLbl = vgui.Create( "DLabel", Frame )
	SaveLbl:SetText("")
	SaveLbl:SetPos(10, 370)
	SaveLbl:SetSize( 250, 15 )
	
	--Save button
	local SaveBtn = vgui.Create( "DButton", Frame )
	SaveBtn:SetText("Save!")
	SaveBtn:SetPos(400, 360)
	SaveBtn:SetSize( 80, 20 )
	SaveBtn:SetDisabled(true)
	SaveBtn.DoClick = function ( btn )
		if AVehicles.Keys.SaveToFile(SelectedSchema) then
			Frame:Close()
		else
			SaveLbl:SetText("Failed to save " .. SelectedSchema .. " schema!")
		end
	end	
	
	----------------------------------------Components-------------------------------
	--KeyBox Box Label
	local KeyBoxLbl = vgui.Create( "DLabel", Frame )
	KeyBoxLbl:SetText("Keys: ")
	KeyBoxLbl:SetPos(330, 30)
	KeyBoxLbl:SetSize( 150, 15 )

	---KeyBox Box
	local KeyBox = vgui.Create( "DComboBox", Frame )
	KeyBox:SetPos( 330, 45 )
	KeyBox:SetSize( 150, 200 )
	KeyBox.user_selected = 0;
	KeyBox.OnSelect = function(panel,index,value,data)
		KeyBox.user_selected = value;
	end
	
	--KeyBox:SetMultiple( false ) 
	local Keys = AVehicles.VGUI.Keys:GetKeys()
	table.sort(Keys)
	for k,v in pairs(Keys) do
		if not ((v == "") or (v == " ")) then
			KeyBox:AddChoice(v)
		end
	end
	
	--Key Set button
	local KeySetBtn = vgui.Create( "DButton", Frame )
	KeySetBtn:SetText("Set key")
	KeySetBtn:SetPos(330, 255)
	KeySetBtn:SetSize( 60, 20 )
	KeySetBtn:SetDisabled(true)
	
	
	
	KeySetBtn.DoClick = function ( btn ) 
		if KeyBox.user_selected and KeyBox.user_selected != 0 then
			SelectedKey = KeyBox.user_selected
			if CanBind(SelectedSchema, SelectedOldKey, SelectedKey) then
				RoutineNewKeyLbl:SetText("New Key: " .. SelectedKey)
				if AVehicles.Keys.UpdateOne(SelectedSchema, SelectedRoutine, SelectedKey, SelectedAltKey) then 
					SaveLbl:SetText("Key(" ..SelectedKey.. ") Saved... ")
					SaveBtn:SetDisabled(false)
				else
					SaveLbl:SetText("Key(" ..SelectedKey.. ") Failed to save... ")
				end
			else
				SaveLbl:SetText("Key(" ..SelectedKey.. ") bound to a other key! Routine: " .. DblBindName)
			end
		end
	end
	
	--Alt Key Set button
	local AltKeySetBtn = vgui.Create( "DButton", Frame )
	AltKeySetBtn:SetText("Set alt key")
	AltKeySetBtn:SetPos(410, 255)
	AltKeySetBtn:SetSize( 70, 20 )
	AltKeySetBtn:SetDisabled(true)
	AltKeySetBtn.DoClick = function ( btn ) 
		if KeyBox.user_selected and KeyBox.user_selected != 0 then
			SelectedKey = KeyBox.user_selected
			if CanBindAlt(SelectedSchema, SelectedAltKey, SelectedKey) then
				RoutineAltKeyLbl:SetText("New Alt Key: " ..SelectedKey)
				if AVehicles.Keys.UpdateOne(SelectedSchema, SelectedRoutine, SelectedOldKey, SelectedKey) then 
					SaveLbl:SetText("Key(" ..SelectedKey.. ") Saved... ")
					SaveBtn:SetDisabled(false)
				else
					SaveLbl:SetText("Key(" ..SelectedKey.. ") Failed to save... ")
				end
			else
				SaveLbl:SetText("Key(" ..SelectedKey.. ") bound to a other key! Routine: " .. DblBindName)
			end
		end
	end
	
	--Schema Box Label
	local SchemaBoxLbl = vgui.Create( "DLabel", Frame )
	SchemaBoxLbl:SetText("Vehicle Schemas: ")
	SchemaBoxLbl:SetPos(10, 30)
	SchemaBoxLbl:SetSize( 150, 15 )

	---Schema Box
	local SchemaBox = vgui.Create( "DComboBox", Frame )
	SchemaBox:SetPos( 10, 45 )
	SchemaBox:SetSize( 150, 200 )
	SchemaBox.user_selected = 0;
	SchemaBox.OnSelect = function(panel,index,value,data)
		SchemaBox.user_selected = value;
	end
	//SchemaBox:SetMultiple( false ) 
	local Schemas = AVehicles.VGUI.Keys:GetSchemas()
	for k,v in pairs(Schemas) do
		if not ((v == "") or (v == " ")) then
			SchemaBox:AddChoice(v)
		end
	end
	
	--Schema Activate button
	local SchemaBtn = vgui.Create( "DButton", Frame )
	SchemaBtn:SetText("Activate Schema")
	SchemaBtn:SetPos(10, 255)
	SchemaBtn:SetSize( 100, 20 )
	SchemaBtn.DoClick = function ( btn ) 
	--Begin of SchemaBtn DoClick function
		if SchemaBox.user_selected and SchemaBox.user_selected != 0 then
			SchemaBtn:SetDisabled(true)
			local schema = SchemaBox.user_selected
			SelectedSchema = schema
			--Routine Box Label
			local RoutineBoxLbl = vgui.Create( "DLabel", Frame )
			RoutineBoxLbl:SetText("Routines("..schema.."):")
			RoutineBoxLbl:SetPos(170, 30)
			RoutineBoxLbl:SetSize( 150, 15 )

			---Routine Box
			local RoutineBox = vgui.Create( "DComboBox", Frame )
			RoutineBox:SetPos( 170, 45 )
			RoutineBox:SetSize( 150, 200 )
			//RoutineBox:SetMultiple( false ) 
			RoutineBox.user_selected = 0;
			RoutineBox.OnSelect = function(panel,index,value,data)
				RoutineBox.user_selected = value;
			end
			local Routines = AVehicles.VGUI.Keys:GetRoutines(schema)
			table.sort(Routines)
			for k,v in pairs(Routines) do
				if not ((v == "") or (v == " ")) then
					RoutineBox:AddChoice(v)
				end
			end
			
	
			--Routine Get button
			local RoutineGetBtn = vgui.Create( "DButton", Frame )
			RoutineGetBtn:SetText("Get Binds")
			RoutineGetBtn:SetPos(170, 255)
			RoutineGetBtn:SetSize( 80, 20 )
			RoutineGetBtn.DoClick = function ( btn ) 
			-- Start of RoutineGetBtn DoClick Function
				if RoutineBox.user_selected and RoutineBox.user_selected != 0 then
					local routine = RoutineBox.user_selected
					RoutineNameLbl:SetText("Routine: " .. routine)
					SelectedRoutine = routine
					local oldkey = GetRoutineKey(SelectedSchema, routine)
					local altkey = GetRoutineAltKey(SelectedSchema, routine)
					RoutineKeyLbl:SetText("Default Key: " ..oldkey)
					if altkey == "~" then
						RoutineAltKeyLbl:SetText("Alt Key: None")
					else
						RoutineAltKeyLbl:SetText("Alt Key: " ..altkey)
					end
					SaveLbl:SetText("")
					SelectedOldKey = oldkey
					SelectedAltKey = altkey
					KeySetBtn:SetDisabled(false)
					AltKeySetBtn:SetDisabled(false)
				end
			end 
			-- End of RoutineGetBtn DoClick Function
			
	
		end
	end --^
	-- End of SchemaBtn DoClick Function
	
	
	



end 
 
concommand.Add( "AVehicles_vgui_keys", AVehicles.VGUI.KeyGui )

/*
 	--Keybox Label
	local KeyBoxLbl = vgui.Create( "DLabel", Frame )
	KeyBoxLbl:SetText("Keys: ")
	KeyBoxLbl:SetPos(200, 30)
	KeyBoxLbl:SetSize( 80, 15 )

	--Key box
	local KeyComboBox = vgui.Create( "DComboBox", Frame )
	KeyComboBox:SetPos( 200, 45 )
	KeyComboBox:SetSize( 200, 200 )
	KeyComboBox:SetMultiple( false ) -- Don't use this unless you know extensive knowledge about tables
	for k,v in pairs(AVehicles.Keys.Keys) do
		if not ((k == "") or (k == " ")) then
			KeyComboBox:AddChoice(k) -- Add our options
		end
	end


	--Selected Schema Label
	local SchemaLbl = vgui.Create( "DLabel", Frame )
	SchemaLbl:SetText("Schema: ")
	SchemaLbl:SetPos(40, 30)
	SchemaLbl:SetSize( 200, 20 )
	
	--Selected Routine 
	local RLbl = vgui.Create( "DLabel", Frame )
	RLbl:SetText("Routine: ")
	RLbl:SetPos(40, 100)
	RLbl:SetSize( 200, 20 )
	
	--Selected Routine Key
	local RKeyLbl = vgui.Create( "DLabel", Frame )
	RKeyLbl:SetText("Routine Key: ")
	RKeyLbl:SetPos(40, 120)
	RKeyLbl:SetSize( 200, 20 )
	
		--Routine select menu button
	local RoutineMenuBtn = vgui.Create( "DButton", Frame )
	RoutineMenuBtn:SetText("Routine Select Select")
	RoutineMenuBtn:SetPos(50, 80)
	RoutineMenuBtn:SetSize( 100, 20 )
	RoutineMenuBtn:SetDisabled(true)
	RoutineMenuBtn.DoClick = function ( btn ) --Begin of DoClick function
		local RoutineMenu = DermaMenu()
		RoutineMenu:SetParent(Frame)
		if SchemaActive then
			local Binds = AVehicles.VGUI.Keys:GetBindings(SelectedSchema) 
			for k,v in pairs(Binds) do
				RoutineMenu:AddOption(v.name, function() --Start of menu function
					RLbl:SetText("Routine: " .. v.name)
					SelectedBind = v.name
					RKeyLbl:SetText("Current Key: " .. v.key)
					-- Set button
						local KeySetBtn = vgui.Create( "DButton", Frame )
						KeySetBtn:SetText("Set key for " .. v.name)
						KeySetBtn:SetPos(50, 160)
						KeySetBtn:SetSize( 100, 20 )
						KeySetBtn.DoClick = function( btn ) 
						local selected = KeyComboBox:GetSelectedItems()
							if selected and selected[1] then
								Msg("You selected: " ..tostring(selected[1]:GetValue()) .. "\n")	
							end
						end
					
				end ) --End of menu function
			end
		end
		RoutineMenu:Open()
	end -- End of DoClick function
	
	--Schemas menu button
	local SchemaMenuBtn = vgui.Create( "DButton", Frame )
	SchemaMenuBtn:SetText("Schema Select")
	SchemaMenuBtn:SetPos(50, 50)
	SchemaMenuBtn:SetSize( 100, 20 )
	SchemaMenuBtn.DoClick = function ( btn )
		local SchemaMenu = DermaMenu()
		SchemaMenu:SetParent(Frame)
		--Schemas menu 
		local Schemas = AVehicles.VGUI.Keys:GetSchemas()
		for k,v in pairs(Schemas) do
			SchemaMenu:AddOption(v, function() 
				SchemaLbl:SetText("Schema: " ..v)
				SelectedSchema = v
				SchemaActive = true
				RoutineMenuBtn:SetDisabled(false)
			end ) --End of function
		end
		SchemaMenu:Open()
	end --End of DoClick Function
	
*/

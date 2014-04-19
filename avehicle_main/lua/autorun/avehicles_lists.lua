if SERVER then AddCSLuaFile("autorun/avehicles_lists.lua") end

local tbl = { 	
	Name = "AVeh Airboat Seat", 
	Class = "avehicle_revseat",
	Category = "AVehicles",
	Author = "Warkanum",
	Information = "A Seat without weapons",
	Model = "models/nova/airboat_seat.mdl",

	KeyValues = {
		defaultmodel = "models/Nova/airboat_seat.mdl",
		thirdviewdistance = 500,
		alloweapons = "false"
	}
}
list.Set( "Vehicles", "avehicle_revseat_noweps", tbl )


local tbl = { 	
	Name = "AVeh Airboat Seat (w)", 
	Class = "avehicle_revseat",
	Category = "AVehicles",
	Author = "Warkanum",
	Information = "A Seat With Weapons",
	Model = "models/nova/airboat_seat.mdl",

	KeyValues = {
		defaultmodel = "models/Nova/airboat_seat.mdl",
		thirdviewdistance = 500,
		alloweapons = "true"
	}
}
list.Set( "Vehicles", "avehicle_revseat_weps", tbl )

local tbl = { 	
	Name = "AVeh Chair (W)", 
	Class = "avehicle_revseat",
	Category = "AVehicles",
	Author = "Warkanum",
	Information = "A chair to sit in and shoot shit.",
	Model = "models/nova/airboat_seat.mdl",

	KeyValues = {
		defaultmodel = "models/nova/chair_wood01.mdl",
		thirdviewdistance = 300,
		alloweapons = "true"
	}
}
list.Set( "Vehicles", "avehicle_revseat_chair", tbl )
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
local IS_VALID_AVEHICLE = true
if not AVehicles then 
	Msg("\nAJumper29: Alienate Vehicle Base not installed! Please install it for this addon to work!\n")
end
if not file.Exists("models/flyboi/littlebird/littlebird_fb.mdl", "GAME") then
	MsgN("Alienate Vehicles: The model that this sent(avehicle_heli_mh6littlebird) uses does not exist! (models/flyboi/littlebird/littlebird_fb.mdl)")
	IS_VALID_AVEHICLE = false
end

ENT.Type 			= "anim"
ENT.Base 			= "avehicle_base"
ENT.PrintName		= "Heli MH6 Littlebird"
ENT.Author			= "Warkanum"
ENT.Category		= "AVehicles"
ENT.EntityName 		= "avehicle_heli_mh6littlebird"
ENT.Spawnable		= IS_VALID_AVEHICLE
ENT.AdminSpawnable	= IS_VALID_AVEHICLE 
ENT.AutomaticFrameAdvance = true --Important for animations

/*
/####//#####/#####/#####/#/#////#///###////####/
#////#/#///////#/////#///#/##///#//#///#//#////#
#//////#///////#/////#///#/#/#//#/#/////#/#/////
/##////#####///#/////#///#/#/#//#/#////////##///
///##//#///////#/////#///#/#//#/#/#///###////##/
/////#/#///////#/////#///#/#//#/#/#/////#//////#
#////#/#///////#/////#///#/#///##//#///#//#////#
/####//#####///#/////#///#/#////#///###////####/
Vehicle Settings:
*/

------------------------------------------------------------------Key bindings.------------------------------------------------------------
ENT.Keyschema					= ENT.EntityName --This must be in the child entity, the name must be different from parent. Usually entity class name
ENT.KeyMap						= {}
ENT.KeyMap[0]					= {routine = "PitchUp", key = "UPARROW", altkey = "~"} --The ~ char is used to ignore the altkey!
ENT.KeyMap[1]					= {routine = "PitchDown", key = "DOWNARROW", altkey = "~"}
ENT.KeyMap[2]					= {routine = "YawLeft", key = "LEFTARROW", altkey = "~"}
ENT.KeyMap[3]					= {routine = "YawRight", key = "RIGHTARROW", altkey = "~"}
ENT.KeyMap[4]					= {routine = "MoveLeft", key = "", altkey = "~"}
ENT.KeyMap[5]					= {routine = "MoveRight", key = "", altkey = "~"}
ENT.KeyMap[6]					= {routine = "hover", key = "SPACE", altkey = "~"}
ENT.KeyMap[7]					= {routine = "levelout", key = "CTRL", altkey = "~"}
ENT.KeyMap[8]					= {routine = "SpeedUp", key = "W", altkey = "~"}
ENT.KeyMap[9]					= {routine = "SpeedDown", key = "S", altkey = "~"}
ENT.KeyMap[10]					= {routine = "turbo", key = "", altkey = "~"}
ENT.KeyMap[11]					= {routine = "engine", key = "R", altkey = "~"}
ENT.KeyMap[12]					= {routine = "mouseaim", key = "M", altkey = "~"}
ENT.KeyMap[13]					= {routine = "viewdistance+", key = "9", altkey = "~"}
ENT.KeyMap[14]					= {routine = "viewdistance-", key = "0", altkey = "~"}
ENT.KeyMap[15]					= {routine = "ViewPosUp", key = "=", altkey = "~"}
ENT.KeyMap[16]					= {routine = "ViewPosDown", key = "-", altkey = "~"}
ENT.KeyMap[17]					= {routine = "toggelhud", key = "\\", altkey = "~"}
ENT.KeyMap[18]					= {routine = "toggelview", key = "V", altkey = "~"}
ENT.KeyMap[19]					= {routine = "eject", key = "X", altkey = "RALT"}
ENT.KeyMap[20]					= {routine = "RollLeft", key = "A", altkey = "~"}
ENT.KeyMap[21]					= {routine = "RollRight", key = "D", altkey = "~"}
ENT.KeyMap[22]					= {routine = "changeseat", key = "P", altkey = "~"}	
ENT.KeyMap[23]					= {routine = "freelook", key = "MOUSE2", altkey = "~"}
ENT.KeyMap[24]					= {routine = "fire", key = "MOUSE1", altkey = "~"}
ENT.KeyMap[25]					= {routine = "altfire", key = "ENTER", altkey = "~"}	
ENT.KeyMap[26]					= {routine = "nextweapon", key = "MWHEELUP", altkey = "~"}	
ENT.KeyMap[27]					= {routine = "prevweapon", key = "MWHEELDOWN", altkey = "~"}
ENT.KeyMap[28]					= {routine = "delegateweapons", key = "N", altkey = "~"}
ENT.KeyMap[29]					= {routine = "gear", key = "G", altkey = "~"}
ENT.KeyMap[30]					= {routine = "door", key = "O", altkey = "~"}
ENT.KeyMap[31]					= {routine = "countermeasure", key = "SHIFT", altkey = "~"}
----------------------------------Hardpoints------------------------------
ENT.HasHardPoints 				= true
ENT.AVHardPoints = {

	{id=0,kind=AVehicles.Types.HARDPOINT_AIMABLE,pos=Vector(80, 0, 20),ang=Angle(0,0,0),desc="Center below aimable mount."},
	{id=1,kind=AVehicles.Types.HARDPOINT_UNIVERSAL,pos=Vector(5, 45, 30),ang=Angle(0,0,0),desc="Bottom left static universal mount."},
	{id=2,kind=AVehicles.Types.HARDPOINT_UNIVERSAL,pos=Vector(5, -45, 30),ang=Angle(0,0,0),desc="Bottom right static universal mount."},

	
}	
---------------------------------------------------------------------Hud-------------------------------------------------------------------------------------
ENT.CustomHud 			= true --Usually true, Because we want to have a pointer
ENT.CroshairScale		= 5 --From 5 to 100 if you want to.
ENT.HudElementPosition	=  5 --0=BL,1=BC,2=BR,3=TL,4=TC,5=TR
------------------------------------------------------------------Pods & Passengers-------------------------------------------------------------------------
ENT.PassengerCount 		= 3
ENT.Restrict			= {}
ENT.Restrict.Use		= false  --Disallow use on entity. This does not include use on the seats
ENT.ParentAndWeldPods	= false --Only weld or both.
ENT.PodPositions = {}
ENT.PodDesc = {}
--Driver
ENT.PodPositions[0] = {}
ENT.PodPositions[0].Angles = Angle(0,-90,0)
ENT.PodPositions[0].Position = Vector(22,-13,40)
ENT.PodDesc[0] = {}
ENT.PodDesc[0].Type = 0
ENT.PodDesc[0].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[0].Visable = false
ENT.PodDesc[0].Collision = false
ENT.PodDesc[0].mass = 100 --This is to override seat mass.
--Co Driver
ENT.PodPositions[1] = {}
ENT.PodPositions[1].Angles = Angle(0,-90,0)
ENT.PodPositions[1].Position = Vector(22,13,40)
ENT.PodDesc[1] = {}
ENT.PodDesc[1].Type = 1
ENT.PodDesc[1].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[1].Visable = false
ENT.PodDesc[1].Collision = false
ENT.PodDesc[1].mass = 100 --This is to override seat mass.
--seat2
ENT.PodPositions[2] = {}
ENT.PodPositions[2].Angles = Angle(0,0,0)
ENT.PodPositions[2].Position = Vector(-5,40,25)
ENT.PodDesc[2] = {}
ENT.PodDesc[2].Type = 1
ENT.PodDesc[2].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[2].Visable = false
ENT.PodDesc[2].Collision = false
ENT.PodDesc[2].mass = 100 --This is to override seat mass.
--seat3
ENT.PodPositions[3] = {}
ENT.PodPositions[3].Angles = Angle(0,180,0)
ENT.PodPositions[3].Position = Vector(-5,-40,25)
ENT.PodDesc[3] = {}
ENT.PodDesc[3].Type = 1
ENT.PodDesc[3].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[3].Visable = false
ENT.PodDesc[3].Collision = false
ENT.PodDesc[3].mass = 100 --This is to override seat mass.

-----------------------------------------Veiw and spawn-----------------------------------------------------
ENT.SpawnPos					= {}
ENT.SpawnPos.SpawnerRange		= 2048 -- The range of a spawner device. Must be in range to spawn there
ENT.SpawnPos.SpawnOffset		= Vector(200,200,50) --Vector(40,20,-35) --The spawn offset, change if you want to spawn in the vehicles or somewhere
ENT.ThirdPersonViewOffset		= Vector(600, 0 ,-100) --Distance of thirs person view
--------------------------------------------------------------------------Engine & Physics-------------------------------------------------------------
ENT.LFPMouseSensitivity			= 2.0
ENT.EngineEnabled 				 = true
ENT.EngineUseCustom 			 = false
ENT.CustomEngine				 = {}
ENT.CustomEngine.RotorWash		 = true
ENT.CustomEngine.RotorWashAltitude  = 10
ENT.CustomEngine.GravitySystem   = true
ENT.CustomEngine.ContraintSystem = true
ENT.CustomEngine.StopOnExit 	 = true		--Do we Stop the engine if the pilot exits. This works with NoPilotStopEngineTime if enabled
ENT.CustomEngine.PitchSpeed 	 = 60
ENT.CustomEngine.YawSpeed		 = 80
ENT.CustomEngine.RollSpeed 		 = 30
ENT.CustomEngine.SideSpeed		 = 1
ENT.CustomEngine.SideUDSpeed	 = 10
ENT.CustomEngine.ForwardMaxSpeed = 1900
ENT.CustomEngine.BackwardMaxSpeed= 2000
ENT.CustomEngine.AngleAccel		 = 3.0
ENT.CustomEngine.MoveAccel		 = 90
ENT.CustomEngine.TurboSpeed		 = 1000
ENT.CustomEngine.TurboAccel		 = 90
ENT.CustomEngine.AccelMax		 = 10.0
ENT.CustomEngine.DecelMax		 = 10.0
ENT.CustomEngine.DragRate		 = 0.80 --80%
ENT.CustomEngine.AngleDragRate   = 1 --100%
---New simulated engine settings, apply only if ENT.EngineUseCustom is false.
ENT.SimEngine					= {}
ENT.SimEngine.hovers			= true --Will the vehicle fall to ground as soon as it stops moving?
ENT.SimEngine.speedtohover		= 50 --Speed to move in order to hover, else fall down to grown. Usefull for jets etc.
ENT.SimEngine.causerestart		= 1000 --Engines will restart when velocity falls below this else fall to grounf. Usefull for when crashed into a wall.
ENT.SimEngine.fwdaccspeed		= 4 --Forward-Backward: How fast to get up to speed and to slow down again.
ENT.SimEngine.trbaccspeed		= 3 --Turbo: How fast to get up to speed and to slow down again.
ENT.SimEngine.sideaccspeed		= 1 --Sideways:How fast to get up to speed and to slow down again.
ENT.SimEngine.udaccspeed		= 1 --Up-Down: How fast to get up to speed and to slow down again.
ENT.SimEngine.autorollspeedmax	= 1000 --Max speed for autoroll, if lower the vehicle will roll more on lower speed. (Only apply with mouse controller)
ENT.SimEngine.autorollmaxdeg	= 70 --Max roll angle in degree for autoroll. (Only apply with mouse controller)
ENT.SimEngine.angmovespeed		= Angle(2,2,2) --This angles represents the speed of pitch,yaw,roll respectively. (Only apply when keyboard controlled.)
-------------------------Fuel System-----------------------------
ENT.Fuel						= {}
ENT.Fuel.unlimited				= false --I bet puddle jumper do use some type of fuel
ENT.Fuel.maxfuel				= 2000 --Puddle Jumper goes off to other worlds. Of course they have plenty of fuel
ENT.Fuel.reservemax				= 1000
ENT.Fuel.usagepertick			= 1 
ENT.Fuel.consumeticktime		= 0.5
-----------------------------------------------------------------------------------Damage, Health-----------------------------------------------------------
ENT.DamageSystem				= {}
ENT.DamageSystem.SmokeEffectPos	= Vector(-87,0,99)
ENT.DamageSystem.DamageKickMul	= 0.001
ENT.DamageSystem.HullMax		= 4000-- i.a.w health,
ENT.DamageSystem.ExplodeRadius	= 1024
ENT.DamageSystem.ExplodeDamage	= 150
ENT.DamageSystem.Collisions		= true
ENT.DamageSystem.StopOnHit		= true --I would prefer this on if the physics is simulated
ENT.DamageSystem.CollisionHard  = 500
ENT.DamageSystem.CollisionSoft	= 200
ENT.DamageSystem.HitDamageMul   = 0.8 --The velocity times this is the damage
-----------------------------------------------------------------------------------------sound----------------------------------------------------------------------
ENT.Sounds						= {}
ENT.Sounds.EngineLoop			= "npc/attack_helicopter/aheli_rotor_loop1.wav"
ENT.Sounds.EngineStart			= "Flyboi/HelicopterStart.wav" 
ENT.Sounds.EngineStop			= "Flyboi/off.wav" 
ENT.Sounds.AlarmFile			= "alienate/vehicle_damaged.wav"
ENT.Sounds.DoorSnd				= "doors/door_metal_rusty_move1.wav"
ENT.Sounds.Enabled				= true
ENT.Sounds.EngineMinPitch		= 50
ENT.Sounds.EngineMaxPitch		= 200
ENT.Sounds.EngineSoundLevel		= 80
ENT.Sounds.EngineSoundVol		= 100
------------------------------------------------------------------------------------Models-----------------------------------------------------------------------------
ENT.Models = {
				Base="models/flyboi/littlebird/littlebird_fb.mdl",
				RotorBase="models/flyboi/littlebird/littlebirdrotorM_fb.mdl",
				RotorTail="models/flyboi/littlebird/littlebirdt_fb.mdl",
			}
util.PrecacheModel("models/flyboi/littlebird/littlebird_fb.mdl")

if CLIENT then------------------------------------------Setup the client keys, check tables in settings file.
	AVehicles.Keys.InstallKeyMap(ENT.Keyschema,ENT.KeyMap) --The newer keymap function.
end

if SERVER then -------------------------------------------Install wire and lifesupport if they exist.
	AVehicles.Hooks.RegisterVehicle(ENT.EntityName)
	AVehicles.RDWire.Install(ENT)
end

if SERVER then
	AddCSLuaFile("shared.lua")
	--Adding resources must be enabled in the config for this to work!
	--AVehicles.Resource_Add("models/Votekick/jumper/jumper_v3.mdl", true);
	--AVehicles.Resource_AddDir("models/Votekick/jumper/gibs", "*.mdl", true);
end


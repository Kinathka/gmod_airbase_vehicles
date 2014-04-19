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
if not AVehicles then 
	Msg("\nAJumper29: Alienate Vehicle Base not installed! Please install it for this addon to work!\n")
end 

ENT.Type 			= "vehicle"
ENT.Base 			= "avehicle_base"
ENT.PrintName		= "Puddle Jumper V2.9"
ENT.Author			= "Warkanum"
ENT.Category		= "AVehicles"
ENT.EntityName 		= "avehicle_puddlejumperv29"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true 
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
ENT.KeyMap[4]					= {routine = "MoveLeft", key = "A", altkey = "~"}
ENT.KeyMap[5]					= {routine = "MoveRight", key = "D", altkey = "~"}
ENT.KeyMap[6]					= {routine = "MoveUp", key = "SPACE", altkey = "~"}
ENT.KeyMap[7]					= {routine = "MoveDown", key = "CTRL", altkey = "~"}
ENT.KeyMap[8]					= {routine = "SpeedUp", key = "W", altkey = "~"}
ENT.KeyMap[9]					= {routine = "SpeedDown", key = "S", altkey = "~"}
ENT.KeyMap[10]					= {routine = "pods", key = "SHIFT", altkey = "~"}
ENT.KeyMap[11]					= {routine = "engine", key = "R", altkey = "~"}
ENT.KeyMap[12]					= {routine = "mouseaim", key = "M", altkey = "~"}
ENT.KeyMap[13]					= {routine = "viewdistance+", key = "9", altkey = "~"}
ENT.KeyMap[14]					= {routine = "viewdistance-", key = "0", altkey = "~"}
ENT.KeyMap[15]					= {routine = "ViewPosUp", key = "=", altkey = "~"}
ENT.KeyMap[16]					= {routine = "ViewPosDown", key = "-", altkey = "~"}
ENT.KeyMap[17]					= {routine = "toggelhud", key = "\\", altkey = "~"}
ENT.KeyMap[18]					= {routine = "toggelview", key = "V", altkey = "~"}
ENT.KeyMap[19]					= {routine = "eject", key = "X", altkey = "RALT"}
ENT.KeyMap[20]					= {routine = "RollLeft", key = "Q", altkey = "~"}
ENT.KeyMap[21]					= {routine = "RollRight", key = "E", altkey = "~"}
ENT.KeyMap[22]					= {routine = "Drones", key = "", altkey = "~"}
ENT.KeyMap[23]					= {routine = "Cloak", key = "", altkey = "~"}
ENT.KeyMap[24]					= {routine = "DHD", key = "1", altkey = "~"}
ENT.KeyMap[25]					= {routine = "Lights", key = "2", altkey = "~"}
ENT.KeyMap[26]					= {routine = "changeseat", key = "P", altkey = "~"}	
ENT.KeyMap[27]					= {routine = "freelook", key = "MOUSE2", altkey = "~"}
ENT.KeyMap[28]					= {routine = "fire", key = "MOUSE1", altkey = "~"}	
ENT.KeyMap[29]					= {routine = "nextweapon", key = "MWHEELUP", altkey = "~"}	
ENT.KeyMap[30]					= {routine = "prevweapon", key = "MWHEELDOWN", altkey = "~"}			
ENT.KeyMap[31]					= {routine = "door", key = "O", altkey = "~"}	
ENT.KeyMap[32]					= {routine = "altfire", key = "ENTER", altkey = "~"}		
ENT.KeyMap[33]					= {routine = "ViewAngUp", key = "]", altkey = "~"}
ENT.KeyMap[34]					= {routine = "ViewAngDown", key = "[", altkey = "~"}
----------------------------------Hardpoints------------------------------
ENT.HasHardPoints 				= true
ENT.AVHardPoints = {
	{id=1,kind=AVehicles.Types.HARDPOINT_UNIVERSAL,pos=Vector(36, 83, -4),ang=Angle(0,0,0),desc="Left Side"}, --,pod=0
	{id=2,kind=AVehicles.Types.HARDPOINT_UNIVERSAL,pos=Vector(36, -83., -4),ang=Angle(0,0,0),desc="Right Side"},
	{id=3,kind=AVehicles.Types.HARDPOINT_STATIC,pos=Vector(36, 49, 59),ang=Angle(0,0,0),desc="Left Top"},
	{id=4,kind=AVehicles.Types.HARDPOINT_STATIC,pos=Vector(36, -49, 59),ang=Angle(0,0,0),desc="Right Top"},
	{id=5,kind=AVehicles.Types.HARDPOINT_AIMABLE,pos=Vector(183, 0, -52),ang=Angle(0,0,0),desc="Center front Aimable"},
	{id=6,kind=AVehicles.Types.HARDPOINT_HOOK,pos=Vector(-178., 0, -57),ang=Angle(0,0,0),desc="Back end hookpoint"},
}					
---------------------------------------------------------------------Hud-------------------------------------------------------------------------------------
ENT.CustomHud 			= true --Usually true, Because we want to have a pointer
ENT.CroshairScale		= 8 --From 5 to 100 if you want to.
ENT.HudElementPosition	=  0 --0=BL,1=BC,2=BR,3=TL,4=TC,5=TR
------------------------------------------------------------------Pods & Passengers-------------------------------------------------------------------------
ENT.PassengerCount 				= 7  -- So six player in the jumper
ENT.Restrict			= {}
ENT.Restrict.Use		= false  --Disallow use on entity. This does not include use on the seats
ENT.ParentAndWeldPods	= true --Only weld or both.
ENT.PodPositions = {}
ENT.PodDesc = {}
--Driver
ENT.PodPositions[0] = {}
ENT.PodPositions[0].Angles = Angle(0,-90,0)
ENT.PodPositions[0].Position = Vector(40,20,-35) 
ENT.PodDesc[0] = {}
ENT.PodDesc[0].Type = 0
ENT.PodDesc[0].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[0].Visable = true
ENT.PodDesc[0].Collision = false
--Co Driver
ENT.PodPositions[1] = {}
ENT.PodPositions[1].Angles = Angle(0,-90,0)
ENT.PodPositions[1].Position = Vector(40,-20,-35)
ENT.PodDesc[1] = {}
ENT.PodDesc[1].Type = 0
ENT.PodDesc[1].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[1].Visable = true
ENT.PodDesc[1].Collision = false
--Passenger1
ENT.PodPositions[2] = {}
ENT.PodPositions[2].Angles = Angle(0,180,0)  
ENT.PodPositions[2].Position = Vector(-60,45,-35)
ENT.PodDesc[2] = {}
ENT.PodDesc[2].Type = 1
ENT.PodDesc[2].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[2].Visable = false
ENT.PodDesc[2].Collision = false
--Passenger2
ENT.PodPositions[3] = {}
ENT.PodPositions[3].Angles = Angle(0,0,0)
ENT.PodPositions[3].Position = Vector(-60,-45,-35)
ENT.PodDesc[3] = {}
ENT.PodDesc[3].Type = 1
ENT.PodDesc[3].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[3].Visable = false
ENT.PodDesc[3].Collision = false
--Passenger3
ENT.PodPositions[4] = {}
ENT.PodPositions[4].Angles = Angle(0,180,0) 
ENT.PodPositions[4].Position = Vector(-100,45,-35)
ENT.PodDesc[4] = {}
ENT.PodDesc[4].Type = 1
ENT.PodDesc[4].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[4].Visable = false
ENT.PodDesc[4].Collision = false
--Passenger5
ENT.PodPositions[5] = {}
ENT.PodPositions[5].Angles = Angle(0,0,0)
ENT.PodPositions[5].Position = Vector(-100,-45,-35)
ENT.PodDesc[5] = {}
ENT.PodDesc[5].Type = 1
ENT.PodDesc[5].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[5].Visable = false
ENT.PodDesc[5].Collision = false
--Passenger6
ENT.PodPositions[6] = {}
ENT.PodPositions[6].Angles = Angle(0,180,0) 
ENT.PodPositions[6].Position = Vector(-140,45,-35)
ENT.PodDesc[6] = {}
ENT.PodDesc[6].Type = 1
ENT.PodDesc[6].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[6].Visable = false
ENT.PodDesc[6].Collision = false
--Passenger7
ENT.PodPositions[7] = {}
ENT.PodPositions[7].Angles = Angle(0,0,0)
ENT.PodPositions[7].Position = Vector(-140,-45,-35)
ENT.PodDesc[7] = {}
ENT.PodDesc[7].Type = 1
ENT.PodDesc[7].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[7].Visable = false
ENT.PodDesc[7].Collision = false

-----------------------------------------Veiw and spawn-----------------------------------------------------
ENT.SpawnPos					= {}
ENT.SpawnPos.SpawnerRange		= 1024 -- The range of a spawner device. Must be in range to spawn there
ENT.SpawnPos.SpawnOffset		= Vector(0,0,-25) --The spawn offset, change if you want to spawn in the vehicles or somewhere
ENT.ThirdPersonViewOffset		= Vector(700, 0 ,-100) --Distance of thirs person view
--------------------------------------------------------------------------Engine & Physics-------------------------------------------------------------
ENT.EngineEnabled 				 = true
ENT.EngineUseCustom 			 = false
ENT.CustomEngine				 = {}
ENT.CustomEngine.RotorWash		 = true
ENT.CustomEngine.RotorWashAltitude  = 20
ENT.CustomEngine.GravitySystem   = true
ENT.CustomEngine.ContraintSystem = true
ENT.CustomEngine.StopOnExit 	 = true		--Do we Stop the engine if the pilot exits. This works with NoPilotStopEngineTime if enabled
ENT.CustomEngine.PitchSpeed 	 = 100
ENT.CustomEngine.YawSpeed		 = 120
ENT.CustomEngine.RollSpeed 		 = 80
ENT.CustomEngine.SideSpeed		 = 600
ENT.CustomEngine.SideUDSpeed	 = 600
ENT.CustomEngine.ForwardMaxSpeed = 1000
ENT.CustomEngine.BackwardMaxSpeed= 600
ENT.CustomEngine.AngleAccel		 = 5.0
ENT.CustomEngine.MoveAccel		 = 120
ENT.CustomEngine.TurboSpeed		 = 2000
ENT.CustomEngine.TurboAccel		 = 80
ENT.CustomEngine.AccelMax		 = 15.0
ENT.CustomEngine.DecelMax		 = 8.0
ENT.CustomEngine.DragRate		 = 0.80 --80%
ENT.CustomEngine.AngleDragRate   = 1 --100%
---New simulated engine settings, apply only if ENT.EngineUseCustom is false.
ENT.SimEngine					= {}
ENT.SimEngine.hovers			= true --Will the vehicle fall to ground as soon as it stops moving?
ENT.SimEngine.speedtohover		= 10 --Speed to move in order to hover, else fall down to grown. Usefull for jets etc.
ENT.SimEngine.causerestart		= 2000 --Engines will restart when velocity falls below this else fall to grounf. Usefull for when crashed into a wall.
ENT.SimEngine.fwdaccspeed		= 10 --Forward-Backward: How fast to get up to speed and to slow down again.
ENT.SimEngine.trbaccspeed		= 20 --Turbo: How fast to get up to speed and to slow down again.
ENT.SimEngine.sideaccspeed		= 5 --Sideways:How fast to get up to speed and to slow down again.
ENT.SimEngine.udaccspeed		= 8 --Up-Down: How fast to get up to speed and to slow down again.
ENT.SimEngine.autorollspeedmax	= 1600 --Max speed for autoroll, if lower the vehicle will roll more on lower speed. (Only apply with mouse controller)
ENT.SimEngine.autorollmaxdeg	= 80 --Max roll angle in degree for autoroll. (Only apply with mouse controller)
ENT.SimEngine.angmovespeed		= Angle(3,3,3) --This angles represents the speed of pitch,yaw,roll respectively. (Only apply when keyboard controlled.)
-------------------------Fuel System-----------------------------
ENT.Fuel						= {}
ENT.Fuel.unlimited				= false --I bet puddle jumper do use some type of fuel
ENT.Fuel.maxfuel				= 8000 --Puddle Jumper goes off to other worlds. Of course they have plenty of fuel
ENT.Fuel.reservemax				= 2000
ENT.Fuel.usagepertick			= 3 
ENT.Fuel.consumeticktime		= 0.9
-----------------------------------------------------------------------------------Damage, Health-----------------------------------------------------------
ENT.DamageSystem				= {}
ENT.DamageSystem.SmokeEffectPos	= Vector(-205,0,20)
ENT.DamageSystem.HullMax		= 5800-- i.a.w health, This is a puddle Jumper. It's kinda strong
ENT.DamageSystem.ExplodeRadius	= 800
ENT.DamageSystem.ExplodeDamage	= 400
ENT.DamageSystem.Collisions		= true
ENT.DamageSystem.StopOnHit		= true --I would prefer this on if the physics is simulated
ENT.DamageSystem.CollisionHard  = 1000
ENT.DamageSystem.CollisionSoft	= 400
ENT.DamageSystem.HitDamageMul   = 0.5 --The velocity times this is the damage
-----------------------------------------------------------------------------------------sound----------------------------------------------------------------------
ENT.Sounds						= {}
ENT.Sounds.AlarmFile			= "alienate/vehicle_damaged.wav"
ENT.Sounds.Enabled				= true
ENT.Sounds.EngineMinPitch		= 50
ENT.Sounds.EngineMaxPitch		= 200
ENT.Sounds.EngineSoundLevel		= 90
ENT.Sounds.EngineSoundVol		= 120
ENT.Sounds.Jumper={
	Fail={Sound("buttons/button19.wav"),Sound("buttons/combine_button2.wav")},
	Cloak=Sound("alienate/jumper/JumperCloak.mp3"),
	Uncloak=Sound("alienate/jumper/JumperUnCloak.mp3"),
	Startup=Sound("alienate/jumper/Startup.mp3"),
	EnginePodOpen=Sound("alienate/jumper/Drivepods1.mp3"),
	EnginePodClose=Sound("alienate/jumper/Drivepods2.mp3"),
	Explosion=Sound("alienate/jumper/JumperExplosion.mp3"),
	Door=Sound("alienate/jumper/jumperreardoor.wav"),
	Shutdown=Sound("alienate/jumper/jumperpowerdown.wav"),
	Engine=Sound("alienate/jumper/JumperEngineLoop.wav"),
	Hover=Sound("alienate/jumper/JumperHoverLoop.wav"),
}
------------------------------------------------------------------------------------Models-----------------------------------------------------------------------------
ENT.Models = {
				Base="models/Votekick/jumper/jumper_v3.mdl",
				Gibs={"models/Votekick/jumper/gibs/gib1.mdl",
				"models/Votekick/jumper/gibs/gib2.mdl",
				"models/Votekick/jumper/gibs/gib3.mdl",
				"models/Votekick/jumper/gibs/gib4.mdl",
				"models/Votekick/jumper/gibs/gib5.mdl",
				"models/Votekick/jumper/gibs/gib6.mdl",
				"models/Votekick/jumper/gibs/gib7.mdl"
				},

			}
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
	AVehicles.Resource_Add("models/Votekick/jumper/jumper_v3.mdl", true);
	AVehicles.Resource_AddDir("models/Votekick/jumper/gibs", "*.mdl", true);
	AVehicles.Resource_AddDir("sound/alienate", "*.wav", false);
	AVehicles.Resource_AddDir("materials/Votekick/jumper", "*.vmt", false);
	AVehicles.Resource_AddDir("materials/Votekick/jumper", "*.vtf", false);
	AVehicles.Resource_Add("materials/VGUI/entities/avehicle_puddlejumperv29.vmt", true);
	
	AVehicles.Resource_Add("sound/alienate/jumper_selfdestruct.wav", false);
	AVehicles.Resource_Add("sound/alienate/JumperEnginev2.wav", false);
end


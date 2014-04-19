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
	MsgN("Alienate Vehicle Base not installed! Please install it for this addon to work!\n")
	return
end 
-------------------------------------------------------------- THE HEADER ----------------------------------------------------------------------------
ENT.Type = "vehicle" --anim
ENT.Base = "base_anim"
ENT.PrintName = "Alienate Vehicle"
ENT.Author = "Warkanum"
ENT.Category = "AVehicles"
ENT.EntityName = "avehicle_base"
ENT.IsAVehicle = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true --Important for animations
ENT.WireDebugName = ENT.EntityName
ENT.CleanupCategoryName = "Alienate Vehicles"
--include("settings.lua") 
--I have moved the settings into the shared.lua file, because we don't want to send to much files to client.
/*
/####//#####/#####/#####/#/#////#///###////####/
#////#/#///////#/////#///#/##///#//#///#//#////#
#//////#///////#/////#///#/#/#//#/#/////#/#/////
/##////#####///#/////#///#/#/#//#/#////////##///
///##//#///////#/////#///#/#//#/#/#///###////##/
/////#/#///////#/////#///#/#//#/#/#/////#//////#
#////#/#///////#/////#///#/#///##//#///#//#////#
/####//#####///#/////#///#/#////#///###////####/
*/


------------------------------------------------------------------Key bindings.------------------------------------------------------------
/*
ENT.Keyschema					= ENT.EntityName --This must be in the child entity, the name must be different from parent. Usually entity class name
ENT.KeyMap						= {}
ENT.KeyMap[0]					= {routine = "PitchUp", key = "UPARROW", altkey = "~"} --The ~ char is used to ignore the altkey!
ENT.KeyMap[1]					= {routine = "PitchDown", key = "DOWNARROW", altkey = "~"}
ENT.KeyMap[2]					= {routine = "YawLeft", key = "LEFTARROW", altkey = "~"}
ENT.KeyMap[3]					= {routine = "YawRight", key = "RIGHTARROW", altkey = "~"}
ENT.KeyMap[4]					= {routine = "MoveLeft", key = "A", altkey = "~"}
ENT.KeyMap[5]					= {routine = "MoveRight", key = "D", altkey = "~"}
ENT.KeyMap[6]					= {routine = "MoveUp", key = "W", altkey = "~"}
ENT.KeyMap[7]					= {routine = "MoveDown", key = "S", altkey = "~"}
ENT.KeyMap[8]					= {routine = "SpeedUp", key = "SHIFT", altkey = "~"}
ENT.KeyMap[9]					= {routine = "SpeedDown", key = "CTRL", altkey = "~"}
ENT.KeyMap[10]					= {routine = "turbo", key = "1", altkey = "~"}
ENT.KeyMap[11]					= {routine = "engine", key = "R", altkey = "~"}
ENT.KeyMap[12]					= {routine = "mouseaim", key = "M", altkey = "~"}
ENT.KeyMap[13]					= {routine = "viewdistance+", key = "9", altkey = "~"}
ENT.KeyMap[14]					= {routine = "viewdistance-", key = "0", altkey = "~"}
ENT.KeyMap[15]					= {routine = "ViewPosUp", key = "=", altkey = "~"}
ENT.KeyMap[16]					= {routine = "ViewPosDown", key = "-", altkey = "~"}
ENT.KeyMap[17]					= {routine = "toggelhud", key = "\\", altkey = "~"}
ENT.KeyMap[18]					= {routine = "toggelview", key = "V", altkey = "~"}
ENT.KeyMap[19]					= {routine = "eject", key = "X", altkey = "P"}
ENT.KeyMap[20]					= {routine = "RollLeft", key = "Q", altkey = "~"}
ENT.KeyMap[21]					= {routine = "RollRight", key = "E", altkey = "~"}
ENT.KeyMap[22]					= {routine = "viewroll", key = "8", altkey = "~"}
ENT.KeyMap[23]					= {routine = "changeseat", key = "B", altkey = "~"}
ENT.KeyMap[24]					= {routine = "ViewAngUp", key = "]", altkey = "~"}
ENT.KeyMap[25]					= {routine = "ViewAngDown", key = "[", altkey = "~"}
*/
----------------------------------Hardpoints------------------------------
ENT.HasHardPoints 				= false
ENT.AVHardPoints = {
	{id=0,kind=AVehicles.Types.HARDPOINT_UNIVERSAL,pos=Vector(0,0,0),ang=Angle(0,0,0),desc="Description",/*pod=0 only add if want to restrict to that pod.*/}
}
		
---------------------------------------------------------------------Hud-------------------------------------------------------------------------------------
ENT.CustomHud 			= true --Usually true, Because we want to have a pointer
ENT.HudDrawAvehicleOverlay	= false
ENT.UseSightLazer 		= false	--To be able to use lazers at all this needs to be enabled in the vehicle.
ENT.CroshairScale		= 10 --From 5 to 100 if you want to.
ENT.HudElementPosition	=  0 --0=BL,1=BC,2=BR,3=TL,4=TC,5=TR
ENT.UseageHint			= "Alienate Vehicles usage hint. Press X to eject a vehicle. Press R to start the engines."
------------------------------------------------------------------Pods & Passengers-------------------------------------------------------------------------
ENT.PassengerCount 		= 0	--How many passengers do we have, this will add x many pods to the vehicle (this related to the index for the pods. 0 being driver 1 the first passenger.
ENT.Restrict			= {}
ENT.Restrict.Use		= false  --Disallow use on entity. This does not include use on the seats
ENT.ParentAndWeldPods	= false --Only weld or both.
ENT.PodPositions = {}
ENT.PodWeapons = {}
ENT.PodDesc = {}
--Driver
ENT.PodPositions[0] = {}
ENT.PodPositions[0].Angles = Angle(0,0,0) 
ENT.PodPositions[0].Position = Vector(0,0,0) 
ENT.PodDesc[0] = {}
ENT.PodDesc[0].Type = 0
ENT.PodDesc[0].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[0].Visable = true
ENT.PodDesc[0].Collision = false
ENT.PodDesc[0].HidePlayer = false --Hides the player (new revseat system)
ENT.PodDesc[0].mass = 100 --This is to override seat mass.
ENT.PodDesc[0].LimitView = 1 --0 means there are not limits, 1 means there is.
ENT.PodWeapons[0] = {} --depricated
--------------------------------------------------------------------------Engine & Physics-------------------------------------------------------------
ENT.EngineEnabled 				 = true	--Do we use the baseclass engine? {Will always be true!}
ENT.EngineUseCustom 			 = true -- Do we use the custom engine? Set false if you want to use physics simulate, shadow control.
ENT.NoPilotStopEngineTime		 = 0.2  --One second before the engines slows down on the pilot exit.
ENT.NoPilotKillEngineTime		 = 0 
ENT.CustomEngine				 = {} --Applies to both engines
ENT.CustomEngine.RotorWash		 = false --Effect on water and ground.
ENT.CustomEngine.RotorWashAltitude  = 20
ENT.CustomEngine.GravitySystem   = true --Applies only to Custom engine
ENT.CustomEngine.StopOnExit 	 = true	--Do we Stop any engine if the pilot exit. This works with NoPilotStopEngineTime if enabled
ENT.CustomEngine.PitchSpeed 	 = 100 --Applies to both engines, depending on events
ENT.CustomEngine.YawSpeed		 = 100 --Applies to both engines, depending on events
ENT.CustomEngine.RollSpeed 		 = 100 --Applies to both engines, depending on events
ENT.CustomEngine.SideSpeed		 = 100 --Applies to both engines, depending on events
ENT.CustomEngine.AngleAccel		 = 3.0 --Applies only to Custom engine
ENT.CustomEngine.MoveAccel		 = 4.0 --Applies to both engines, depending on events
ENT.CustomEngine.SideUDSpeed	 = 100 --Applies to both engines, depending on events
ENT.CustomEngine.ForwardMaxSpeed = 500 --Applies to both engines, depending on events
ENT.CustomEngine.BackwardMaxSpeed= 100 --Applies to both engines, depending on events
ENT.CustomEngine.TurboSpeed		 = 1800 --Applies to both engines, depending on events
ENT.CustomEngine.TurboAccel		 = 30 --Applies to both engines, depending on events
ENT.CustomEngine.AccelMax		 = 3.0 --Applies to both engines, depending on events
ENT.CustomEngine.DecelMax		 = 3.0 --Applies to both engines, depending on events
ENT.CustomEngine.DragRate		 = 0.8 --80% --Applies only to Custom engine
ENT.CustomEngine.AngleDragRate   = 1 --100% --Applies only to Custom engine
---New simulated engine settings, apply only if ENT.EngineUseCustom is false.
ENT.SimEngine					= {}
ENT.SimEngine.hovers			= true --Will the vehicle fall to ground as soon as it stops moving?
ENT.SimEngine.speedtohover		= 20 --Speed to move in order to hover, else fall down to grown. Usefull for jets etc.
ENT.SimEngine.causerestart		= 2000 --Engines will restart when velocity falls below this else fall to grounf. Usefull for when crashed into a wall.
ENT.SimEngine.fwdaccspeed		= 10 --Forward-Backward: How fast to get up to speed and to slow down again.
ENT.SimEngine.trbaccspeed		= 20 --Turbo: How fast to get up to speed and to slow down again.
ENT.SimEngine.sideaccspeed		= 3 --Sideways:How fast to get up to speed and to slow down again.
ENT.SimEngine.udaccspeed		= 5 --Up-Down: How fast to get up to speed and to slow down again.
ENT.SimEngine.autorollspeedmax	= 1900 --Max speed for autoroll, if lower the vehicle will roll more on lower speed. (Only apply with mouse controller)
ENT.SimEngine.autorollmaxdeg	= 85 --Max roll angle in degree for autoroll. (Only apply with mouse controller)
ENT.SimEngine.angmovespeed		= Angle(2,2,2) --This angles represents the speed of pitch,yaw,roll respectively. (Only apply when keyboard controlled.)

-------------------------Fuel System-----------------------------
ENT.Fuel						= {}
ENT.Fuel.unlimited				= false
ENT.Fuel.maxfuel				= 1000
ENT.Fuel.reservemax				= 1000
ENT.Fuel.usagepertick			= 1 
ENT.Fuel.consumeticktime		= 0.5

------------------------------------------------------------------------Mouse Controll Stuff-----------------------------------------------------------------
ENT.CustomEngine_MouseSpecial_MinPitch			= -40
ENT.CustomEngine_MouseSpecial_MaxPitch			= 40
ENT.CustomEngine_MouseSpecial_MinYaw			= -40
ENT.CustomEngine_MouseSpecial_MaxYaw			= 40
ENT.CustomEngine_MouseSpecial_FirstPerson_Mul	= 0.5    --How sensitive must First Person View Mouse Be?
ENT.CustomEngine_MouseSpecial_FirstPerson_OMul	= 0.5    --MinPitch, MaxPitch etc is connected to this, for first person there percentages.
ENT.CustomEngine_MouseSpecial_CanPitch			= true  --Are we able to pitch with mouse?
ENT.CustomEngine_MouseSpecial_CanYaw			= true  --Are we able to Yaw with mouse?
ENT.CustomEngine_MousePitchRate  				= 1.2	--The sensitivity of Pitch
ENT.CustomEngine_MouseYawRate  	 				= 1.2	--The sensitivity of Yaw
-----------------------------------------------------------------------------------Damage, Health-----------------------------------------------------------
ENT.DamageSystem				= {}
ENT.DamageSystem.HullFailAmount = 25
ENT.DamageSystem.SmokeEffectPos	= Vector(1,1,1)
ENT.DamageSystem.DamageKickMul	= 0.01
ENT.DamageSystem.repairlimit	= 20
ENT.DamageSystem.HullMax		= 1000-- i.a.w health 
ENT.DamageSystem.ExplodeRadius	= 1024
ENT.DamageSystem.ExplodeDamage	= 200
ENT.DamageSystem.Collisions		= true
ENT.DamageSystem.StopOnHit		= true
ENT.DamageSystem.CollisionHard  = 800  --How much is a hard hit, At this velocity, make a hardhit. 
ENT.DamageSystem.CollisionSoft	= 200  --Same as hard hit
ENT.DamageSystem.HitDamageMul   = 0.1 --The velocity times this is the damage
ENT.DamageSystem.ShakeOnHit		= true
-----------------------------------------------------------------------------------------Veiw and spawn-----------------------------------------------------
ENT.SpawnPos					= {}
ENT.SpawnPos.SpawnerRange		= 1024 -- The range of a spawner device. Must be in range to spawn there
ENT.SpawnPos.SpawnOffset		= Vector(-400,400,80) --The spawn offset, change if you want to spawn in the vehicles or somewhere
ENT.ThirdPersonViewOffset		= Vector(1000, 0 ,0) --Distance of thirs person view
ENT.AVehicleCreateOffset		= Vector(0,0, 200) --The offset of the spawning position of the vehicles.
ENT.ThirdPersonViewAngleAdjust	= Angle(10, 0, 0)
-----------------------------------------------------------------------------------------sound----------------------------------------------------------------------
ENT.Sounds						= {}
ENT.Sounds.EngineLoop			= "alienate/engine_snd.wav" 
ENT.Sounds.AlarmFile			= "alienate/vehicle_damaged.wav"
ENT.Sounds.Enabled				= true
ENT.Sounds.EngineMinPitch		= 50
ENT.Sounds.EngineMaxPitch		= 200
ENT.Sounds.EngineSoundLevel		= 80
ENT.Sounds.EngineSoundVol		= 100
------------------------------------------------------------------------------------Models-----------------------------------------------------------------------------
ENT.GibModels = {"models/gibs/helicopter_brokenpiece_01.mdl",
				"models/gibs/helicopter_brokenpiece_02.mdl",
				"models/gibs/helicopter_brokenpiece_03.mdl",
				"models/gibs/scanner_gib01.mdl",
				"models/gibs/strider_gib7.mdl",
				"models/gibs/strider_gib6.mdl",
				"models/gibs/airboat_broken_engine.mdl",
				"models/items/car_battery01.mdl",
				"models/props_citizen_tech/till001a_safetyarm01.mdl",
				"models/props_citizen_tech/till001a_base01.mdl",
				"models/props_combine/combine_barricade_bracket02b.mdl",
				"models/props_lab/blastdoor001b.mdl",
				"models/props_junk/TrashDumpster02b.mdl"
}

--ENT.Models = {
--				Base=""
--			}


----------------------------------------------------------------------------------------------------------------------------------------------------------------

if SERVER then
	--AVehicles.Hooks.RegisterVehicle(ENT.EntityName)
	AVehicles.RDWire.Install(ENT) 
	
	--Add this to child entity. (Note: Adding resources must be enabled in the config for this to work!)
	--AVehicles.Resource_AddDir("models/YourModelFolder", "*.mdl", true);
	--AVehicles.Resource_Add("materials/VGUI/entities/avehicle_puddlejumperv2.vmt", true);
end
if CLIENT then------------------------------------------Setup the client keys, check tables in settings file.
	--AVehicles.Keys.InstallKeyMap(ENT.Keyschema,ENT.KeyMap) --The newer keymap function.
end

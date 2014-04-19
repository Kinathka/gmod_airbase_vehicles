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

ENT.Type 			= "anim"
ENT.Base 			= "avehicle_base"
ENT.PrintName		= "Heli CH46"
ENT.Author			= "Warkanum"
ENT.Category		= "AVehicles"
ENT.EntityName 		= "avehicle_heli_ch46"
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
	{id=0,kind=AVehicles.Types.HARDPOINT_STATIC,pos=Vector(198, 0, 37),ang=Angle(0,0,0),desc="Center front below mount."},

	{id=1,kind=AVehicles.Types.HARDPOINT_AIMABLE,pos=Vector(47,-46, 71),ang=Angle(0,0,0),desc="Passenger right aimable mount.",pod=2}, --Force hp to pod 2
	{id=2,kind=AVehicles.Types.HARDPOINT_AIMABLE,pos=Vector(47,46, 71),ang=Angle(0,-90,0),desc="Passenger left aimable mount.",pod=3}, --Force hp to pod 3
	{id=3,kind=AVehicles.Types.HARDPOINT_AIMABLE,pos=Vector(-172, -30, 38),ang=Angle(0,-0,0),desc="Passenger back door aimable mount.",pod=19}, --Force hp to pod 3
	{id=4,kind=AVehicles.Types.HARDPOINT_STATIC,pos=Vector(-56, -61, 52),ang=Angle(0,0,0),desc="Side leftuniversal mount."},
	{id=5,kind=AVehicles.Types.HARDPOINT_STATIC,pos=Vector(-56, 61, 52),ang=Angle(0,0,0),desc="Side right universal mount."},

	{id=6,kind=AVehicles.Types.HARDPOINT_HOOK,pos=Vector(37, 0,30),ang=Angle(0,0,0),desc="Hook, Pickup mount"},
	
	--{id=6,kind=AVehicles.Types.HARDPOINT_SUPPORT,pos=Vector(80.3, 56.0,1.4),ang=Angle(0,0,0),desc="Support front left"}, 
	--{id=7,kind=AVehicles.Types.HARDPOINT_SUPPORT,pos=Vector(80.3, -56.0,1.4),ang=Angle(0,0,0),desc="Support front right"},
	--{id=8,kind=AVehicles.Types.HARDPOINT_SUPPORT,pos=Vector(-56.24, 55.84,1.0),ang=Angle(0,0,0),desc="Support back left"},
	--{id=9,kind=AVehicles.Types.HARDPOINT_SUPPORT,pos=Vector(-56.24, -55.84,1.0),ang=Angle(0,0,0),desc="Support back right"}, 
	
	

}	
---------------------------------------------------------------------Hud-------------------------------------------------------------------------------------
ENT.CustomHud 			= true --Usually true, Because we want to have a pointer
ENT.CroshairScale		= 5 --From 5 to 100 if you want to.
ENT.HudElementPosition	=  5 --0=BL,1=BC,2=BR,3=TL,4=TC,5=TR
------------------------------------------------------------------Pods & Passengers-------------------------------------------------------------------------
ENT.PassengerCount 		= 24
ENT.Restrict			= {}
ENT.Restrict.Use		= false  --Disallow use on entity. This does not include use on the seats
ENT.ParentAndWeldPods	= false --Only weld or both.
ENT.PodPositions = {}
ENT.PodDesc = {}
--Driver
ENT.PodPositions[0] = {}
ENT.PodPositions[0].Angles = Angle(0,-90,0)
ENT.PodPositions[0].Position = Vector(170,-22,68)
ENT.PodDesc[0] = {}
ENT.PodDesc[0].Type = 0
ENT.PodDesc[0].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[0].Visable = false
ENT.PodDesc[0].Collision = false
ENT.PodDesc[0].mass = 200 --This is to override seat mass.
--Co Driver
ENT.PodPositions[1] = {}
ENT.PodPositions[1].Angles = Angle(0,-90,0)
ENT.PodPositions[1].Position = Vector(170,22,68) 
ENT.PodDesc[1] = {}
ENT.PodDesc[1].Type = 0
ENT.PodDesc[1].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[1].Visable = false
ENT.PodDesc[1].Collision = false
ENT.PodDesc[1].mass = 200 --This is to override seat mass.
--Passenger1
ENT.PodPositions[2] = {}
ENT.PodPositions[2].Angles = Angle(0,180,0) 
ENT.PodPositions[2].Position = Vector(50,-30,50)
ENT.PodDesc[2] = {}
ENT.PodDesc[2].Type = 0
ENT.PodDesc[2].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[2].Visable = false
ENT.PodDesc[2].Collision = false

--Passenger2
ENT.PodPositions[3] = {}
ENT.PodPositions[3].Angles = Angle(0,0,0)
ENT.PodPositions[3].Position = Vector(50,30,50)  
ENT.PodDesc[3] = {}
ENT.PodDesc[3].Type = 0
ENT.PodDesc[3].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[3].Visable = false
ENT.PodDesc[3].Collision = false

--Passenger3
ENT.PodPositions[4] = {}
ENT.PodPositions[4].Angles = Angle(0,180,0)
ENT.PodPositions[4].Position = Vector(-10,30,50)  
ENT.PodDesc[4] = {}
ENT.PodDesc[4].Type = 0
ENT.PodDesc[4].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[4].Visable = false
ENT.PodDesc[4].Collision = false


--Passenger5
ENT.PodPositions[5] = {}
ENT.PodPositions[5].Angles = Angle(0,0,0)
ENT.PodPositions[5].Position = Vector(-10,-30,50) 
ENT.PodDesc[5] = {}
ENT.PodDesc[5].Type = 0
ENT.PodDesc[5].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[5].Visable = false
ENT.PodDesc[5].Collision = false

--Passenger6
ENT.PodPositions[6] = {}
ENT.PodPositions[6].Angles = Angle(0,180,0)
ENT.PodPositions[6].Position = Vector(-30,30,50)  
ENT.PodDesc[6] = {}
ENT.PodDesc[6].Type = 0
ENT.PodDesc[6].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[6].Visable = false
ENT.PodDesc[6].Collision = false


--Passenger7
ENT.PodPositions[7] = {}
ENT.PodPositions[7].Angles = Angle(0,0,0)
ENT.PodPositions[7].Position = Vector(-30,-30,50)
ENT.PodDesc[7] = {}
ENT.PodDesc[7].Type = 0
ENT.PodDesc[7].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[7].Visable = false
ENT.PodDesc[7].Collision = false

--Passenger8
ENT.PodPositions[8] = {}
ENT.PodPositions[8].Angles = Angle(0,180,0)
ENT.PodPositions[8].Position = Vector(-50,30,50)  
ENT.PodDesc[8] = {}
ENT.PodDesc[8].Type = 0
ENT.PodDesc[8].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[8].Visable = false
ENT.PodDesc[8].Collision = false

--Passenger9
ENT.PodPositions[9] = {}
ENT.PodPositions[9].Angles = Angle(0,0,0)
ENT.PodPositions[9].Position = Vector(-50,-30,50) 
ENT.PodDesc[9] = {}
ENT.PodDesc[9].Type = 0
ENT.PodDesc[9].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[9].Visable = false
ENT.PodDesc[9].Collision = false

--Passenger10
ENT.PodPositions[10] = {}
ENT.PodPositions[10].Angles = Angle(0,180,0)
ENT.PodPositions[10].Position = Vector(-70,30,50)   
ENT.PodDesc[10] = {}
ENT.PodDesc[10].Type = 0
ENT.PodDesc[10].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[10].Visable = false
ENT.PodDesc[10].Collision = false

--Passenger11
ENT.PodPositions[11] = {}
ENT.PodPositions[11].Angles = Angle(0,0,0)
ENT.PodPositions[11].Position = Vector(-70,-30,50)    
ENT.PodDesc[11] = {}
ENT.PodDesc[11].Type = 0
ENT.PodDesc[11].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[11].Visable = false
ENT.PodDesc[11].Collision = false

--Passenger12
ENT.PodPositions[12] = {}
ENT.PodPositions[12].Angles = Angle(0,180,0)
ENT.PodPositions[12].Position = Vector(-90,30,50)   
ENT.PodDesc[12] = {}
ENT.PodDesc[12].Type = 0
ENT.PodDesc[12].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[12].Visable = false
ENT.PodDesc[12].Collision = false

--Passenger13
ENT.PodPositions[13] = {}
ENT.PodPositions[13].Angles = Angle(0,0,0)
ENT.PodPositions[13].Position = Vector(-90,-30,50)   
ENT.PodDesc[13] = {}
ENT.PodDesc[13].Type = 0
ENT.PodDesc[13].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[13].Visable = false
ENT.PodDesc[13].Collision = false

--Passenger14
ENT.PodPositions[14] = {}
ENT.PodPositions[14].Angles = Angle(0,180,0)
ENT.PodPositions[14].Position = Vector(-110,30,50)  
ENT.PodDesc[14] = {}
ENT.PodDesc[14].Type = 0
ENT.PodDesc[14].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[14].Visable = false
ENT.PodDesc[14].Collision = false

--Passenger15
ENT.PodPositions[15] = {}
ENT.PodPositions[15].Angles = Angle(0,0,0)
ENT.PodPositions[15].Position = Vector(-110,-30,50)  
ENT.PodDesc[15] = {}
ENT.PodDesc[15].Type = 0
ENT.PodDesc[15].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[15].Visable = false
ENT.PodDesc[15].Collision = false

--Passenger16
ENT.PodPositions[16] = {}
ENT.PodPositions[16].Angles = Angle(0,180,0)
ENT.PodPositions[16].Position = Vector(-130,30,50)    
ENT.PodDesc[16] = {}
ENT.PodDesc[16].Type = 0
ENT.PodDesc[16].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[16].Visable = false
ENT.PodDesc[16].Collision = false

--Passenger17
ENT.PodPositions[17] = {}
ENT.PodPositions[17].Angles = Angle(0,0,0)
ENT.PodPositions[17].Position = Vector(-130,-30,50) 
ENT.PodDesc[17] = {}
ENT.PodDesc[17].Type = 0
ENT.PodDesc[17].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[17].Visable = false
ENT.PodDesc[17].Collision = false

--Passenger18
ENT.PodPositions[18] = {}
ENT.PodPositions[18].Angles = Angle(0,180,0)
ENT.PodPositions[18].Position = Vector(-150,30,50)  
ENT.PodDesc[18] = {}
ENT.PodDesc[18].Type = 0
ENT.PodDesc[18].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[18].Visable = false
ENT.PodDesc[18].Collision = false

--Passenger19
ENT.PodPositions[19] = {}
ENT.PodPositions[19].Angles = Angle(0,90,0)
ENT.PodPositions[19].Position = Vector(-155,-30,36)
ENT.PodDesc[19] = {}
ENT.PodDesc[19].Type = 0
ENT.PodDesc[19].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[19].Visable = false
ENT.PodDesc[19].Collision = false

--Passenger20
ENT.PodPositions[20] = {}
ENT.PodPositions[20].Angles = Angle(0,180,0)
ENT.PodPositions[20].Position = Vector(20,30,50)
ENT.PodDesc[20] = {}
ENT.PodDesc[20].Type = 0
ENT.PodDesc[20].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[20].Visable = false
ENT.PodDesc[20].Collision = false

 --Passenger21
ENT.PodPositions[21] = {}
ENT.PodPositions[21].Angles = Angle(0,0,0)
ENT.PodPositions[21].Position = Vector(110,-30,45)  
ENT.PodDesc[21] = {}
ENT.PodDesc[21].Type = 0
ENT.PodDesc[21].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[21].Visable = false
ENT.PodDesc[21].Collision = false

 --Passenger22
ENT.PodPositions[22] = {}
ENT.PodPositions[22].Angles = Angle(0,180,0)
ENT.PodPositions[22].Position = Vector(110,30,44)  
ENT.PodDesc[22] = {}
ENT.PodDesc[22].Type = 0
ENT.PodDesc[22].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[22].Visable = false
ENT.PodDesc[22].Collision = false

 --Passenger23
ENT.PodPositions[23] = {}
ENT.PodPositions[23].Angles = Angle(0,0,0)
ENT.PodPositions[23].Position = Vector(90,-30,45)   
ENT.PodDesc[23] = {}
ENT.PodDesc[23].Type = 0
ENT.PodDesc[23].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[23].Visable = false
ENT.PodDesc[23].Collision = false

 --Passenger24
ENT.PodPositions[24] = {}
ENT.PodPositions[24].Angles = Angle(0,180,0)
ENT.PodPositions[24].Position = Vector(90,30,45)  
ENT.PodDesc[24] = {}
ENT.PodDesc[24].Type = 0
ENT.PodDesc[24].Model = "models/nova/jeep_seat.mdl"
ENT.PodDesc[24].Visable = false
ENT.PodDesc[24].Collision = false


-----------------------------------------Veiw and spawn-----------------------------------------------------
ENT.SpawnPos					= {}
ENT.SpawnPos.SpawnerRange		= 2048 -- The range of a spawner device. Must be in range to spawn there
ENT.SpawnPos.SpawnOffset		= Vector(-370,0,10) --Vector(40,20,-35) --The spawn offset, change if you want to spawn in the vehicles or somewhere
ENT.ThirdPersonViewOffset		= Vector(800, 0 ,-200) --Distance of thirs person view

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
ENT.CustomEngine.SideSpeed		 = 0.3
ENT.CustomEngine.SideUDSpeed	 = 10
ENT.CustomEngine.ForwardMaxSpeed = 2100
ENT.CustomEngine.BackwardMaxSpeed= 1290
ENT.CustomEngine.AngleAccel		 = 2.0
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
ENT.Fuel.usagepertick			= 1.2 
ENT.Fuel.consumeticktime		= 0.4
-----------------------------------------------------------------------------------Damage, Health-----------------------------------------------------------
ENT.DamageSystem				= {}
ENT.DamageSystem.SmokeEffectPos	= Vector(-87,0,99)
ENT.DamageSystem.DamageKickMul	= 0.001
ENT.DamageSystem.HullMax		= 5000-- i.a.w health,
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
ENT.Sounds.DoorSnd				= "doors/doormove3.wav"
ENT.Sounds.Enabled				= true
ENT.Sounds.EngineMinPitch		= 50
ENT.Sounds.EngineMaxPitch		= 200
ENT.Sounds.EngineSoundLevel		= 80
ENT.Sounds.EngineSoundVol		= 100
------------------------------------------------------------------------------------Models-----------------------------------------------------------------------------
ENT.Models = {
				Base="models/Flyboi/Ch46/ch46_fb.mdl",
				RotorBase="models/Flyboi/Ch46/ch46rotorm_fb.mdl",
			}
ENT.GibsModels = {
	"models/huey/gibs/gib1_vk.mdl",
	"models/huey/gibs/gib2_vk.mdl",
	"models/huey/gibs/gib3_vk.mdl",
	"models/huey/gibs/gib4_vk.mdl"
}
util.PrecacheModel("models/Flyboi/Huey/huey_fb.mdl")

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


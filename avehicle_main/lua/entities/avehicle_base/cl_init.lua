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
/*
//###//#/////#/#####/#////#/#####
/#///#/#/////#/#/////##///#///#//
#//////#/////#/#/////#/#//#///#//
#//////#/////#/#####/#/#//#///#//
#//////#/////#/#/////#//#/#///#//
#//////#/////#/#/////#//#/#///#//
/#///#/#/////#/#/////#///##///#//
//###//#####/#/#####/#////#///#//
Client:
*/
-------------------------------------------------------------- THE HEADER ----------------------------------------------------------------------------
-----------Include--------
include("shared.lua")

-----------------------Definitions---------------------
ENT.Sounds = ENT.Sounds or {}
language.Add("aVehicle_base","AVehicle")
ENT.Effect_smokes = { 
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016"
}
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------

function ENT:Initialize()
	//self.Entity:SetShouldDrawInViewMode( true )
	self.ServerInfoTick = 0
	self.ServerInfoTickTime = 0.4 --Update client info every second
	self.ThirdPersonViewVec		= self.ThirdPersonViewOffset
	self.ThirdPersonAngleAdjust = self.ThirdPersonViewAngOffset or Angle(0,0,0)
	
	self.HudPosition = self.HudElementPosition or 0
	self.Flags = {}
	self.Flags.EngineSnd = false
	self.Damage = {}
	self.Fuel = {}
	self.Fuel.reserves = 100
	self.Fuel.fuel = 100
	self.Damage.Hull = 100
	self.Damage.HullFailureAmount = self.DamageSystem.HullFailAmount or 25
	self.Engine = {}
	self.Engine.Phys = {}
	self.Engine.Active = false
	self.ClientIn = false
	self.PassengersIn = 0
	self.hasSentHints = false
	self.ActiveWeaponName = "None"
	self.WeaponNames = {}
	self.HardPointEnts = {}
	self.WeaponsRefreshed = false
	self.SlowStatusUpdateTick = 0
	--This must be last because we may used variables declared earlier.
	self:SoundsInitialize() 
	self:HudInitialize()
	self:EventsInitialize()
	self:GetWeaponsNames()
	self.AimViewAngleAdjustment = Angle(0,0,0) //self.ThirdPersonViewAngleAdjust or Angle(0,0,0) --Since we are not doing it clientside anymore
	self.Emitter = ParticleEmitter(self.Entity:GetPos(), true)
end


function ENT:Draw()
	self.Entity:DrawModel()
	if self.Engine.Active and (self.Damage.Hull < self.Damage.HullFailureAmount) then
		self:DrawDamageEffect()
	end
end



function ENT:DrawDamageEffect()
	if (self.Emitter) then
		
		local pos = Vector(1,1,1)
		if (self.DamageSystem.SmokeEffectPos) then
			pos = self.Entity:GetPos() +(self.Entity:GetUp() * self.DamageSystem.SmokeEffectPos.z) + (self.Entity:GetForward() * self.DamageSystem.SmokeEffectPos.x) + (self.Entity:GetRight() * self.DamageSystem.SmokeEffectPos.y) 
		else
			pos = self.Entity:GetPos() +(self.Entity:GetUp() * 10) +(self.Entity:GetForward() * -200) 
		end
		
		local fwd = self.Entity:GetForward()
		local rht = self.Entity:GetRight()
		local vel = self.Entity:GetVelocity()
		local roll = math.Rand(-10,20)
		local id = self.Entity:EntIndex()
		local ang = self.Entity:GetAngles()
		
		local particle = self.Emitter:Add(table.Random(self.Effect_smokes),pos)
		particle:SetVelocity((fwd*-10)*Vector(math.random(1,4), math.random(1,4), math.random(1,4)))
		particle:SetDieTime(3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(10)
		particle:SetStartSize(55)
		particle:SetEndSize(50)
		particle:SetColor(Color(20,20,20,255))
		particle:SetRoll(roll)

		
		--self.Emitter:Finish()
	end
end

function ENT:Think()
	if IsValid(self.Entity) then
		self:EventsRun() --Run clientside events (key binds and routines etc)
		--Get information from server
		if self.ServerInfoTick < CurTime() then
			self.ServerInfoTick = CurTime() + self.ServerInfoTickTime
			self:GetStatus()
		end

		/*
		--Send a few hints, only once.
		if not self.hasSentHints and AVehicles.Vehicle.IsIn then
			GM:AddNotify("Welcome to AVehicles. Please go to Alienate Vehicles Tab, Controls to see your bindings.", NOTIFY_HINT, 10)
			if not self.Engine.Active then
				GM:AddNotify("You must start your engine before you can move. Normally 'R' else check Controls.", NOTIFY_HINT, 10)
			end
			self.hasSentHints = true
		end
		*/
		if not self.Flags.EngineSnd then
			if self.Engine.Active then
				self:SoundsEngineStart()
				self.Flags.EngineSnd = true
			end
		end
		
		if self.Flags.EngineSnd then
			if not self.Engine.Active then
				self.Flags.EngineSnd = false
				self:SoundsEngineStop()
			end
		end
		
		self:SoundsEnginePitchCall(self.Engine.Active)
	end
end


function ENT:GetStatus()
	--Some vars get send via usermessages ()
	--AVehicles.Vehicle.IsIn = false      Client Var that indicates if the client is in the vehicle
	--AVehicles.Vehicle.Pos = -1	client var that indicates the client sit position, 0 being the driver
	--AVehicles.Vehicle.Ent  	Cleint Var, the vehicle entity
	--Get the damage  from the server
	self.Damage.Hull = self.Entity:GetNetworkedInt("Damage_Hull") or 0
	self.Fuel.fuel =  self.Entity:GetNetworkedInt("Fuel_Left") or 0
	self.Fuel.reserves =  self.Entity:GetNetworkedInt("Fuel_Reserves") or 0
	--Get Engine speed and stuff
	self.Engine.Phys.Speed = self.Entity:GetNetworkedInt("Engine_Speed") or 0
	self.Engine.Phys.TurboSpeed = self.Entity:GetNetworkedInt("Engine_TurboSpeed") or 0
	self.Engine.Active = self.Entity:GetNetworkedBool("Engine_Active")
	
	local canupdate = self.Entity:GetNetworkedBool("AVehicle_Weapons_isUpdating") or false
	if canupdate and not self.WeaponsRefreshed then self.WeaponsRefreshed = true end
	
	
	if self.WeaponsRefreshed and AVehicles.Vehicle.IsIn then
		self.WeaponsRefreshed = false
		self:GetWeaponsNames()
		--self:GetHardPointIds() --For future use.
	end
	
	--Slow updates for this that doesn't need real time info.
	if self.SlowStatusUpdateTick < CurTime() then
		self.SlowStatusUpdateTick = CurTime() + 5
		self:GetHardpointEntsAndIds()
	end
	
	if AVehicles.Vehicle.IsIn then
		self.PassengersIn = self.Entity:GetNetworkedInt("Passengers_InCount") or 0
		self.ActiveWeaponName  = self:GetSelectedWeapon(self.Entity:GetNetworkedString("AVehicle_Weapons_selected") or "")
	end
	
end

--Get the weapon name of by seat position and index. @ Warkanum
function ENT:GetSelectedWeaponName(PlyPos, wepIndex)
	if self.PodWeapons and self.PodWeapons[PlyPos] then
		if self.PodWeapons[PlyPos][wepIndex] then
			return self.PodWeapons[PlyPos][wepIndex]
		end
	end
	return ""
end


--Returns the selected weapon and returns it's name. @ Warkanum
function ENT:GetSelectedWeapon(weps)
	if weps then
		for k,v in pairs(string.Explode(",",weps)) do
			local info = string.Explode("=",v)
			if (tonumber(info[1]) == AVehicles.Vehicle.Pos) and self.WeaponNames[tonumber(info[2])] then
				return self.WeaponNames[tonumber(info[2])] --self:GetSelectedWeaponName(AVehicles.Vehicle.Pos, tonumber(info[2]))
			end
		end
	end
	return "None"
end

function ENT:GetWeaponsNames()
	local wepStr = self.Entity:GetNetworkedString("AVehicle_Weapons_names")
	local pods = string.Explode(";", wepStr) or {}
	for k,v in pairs(pods) do
		if v and (v != "") then
			local podwep = string.Explode("|", v)
			if tonumber(podwep[1]) == AVehicles.Vehicle.Pos then
				self.WeaponNames = string.Explode(",", podwep[2])
				--table.remove(self.WeaponNames,table.getn(self.WeaponNames))
				return true
			end
		end
	end
end

function ENT:GetHardpointEntsAndIds()
	local str = self.Entity:GetNetworkedString("AVehicle_Hardpoints_IdAndEntsId")
	local nodes = string.Explode(";", str) or {}
	for k,v in pairs(nodes) do
		if v and (v != "") then
			local types = string.Explode("=", v)
			self.HardPointEnts[tonumber(types[1])] = ents.GetByIndex(tonumber(types[2]))
		end
	end
end

function ENT:OnRemove()
	self:SoundsOnRemove()
	if IsValid(self.EntDamageTrail) then
		self.EntDamageTrail:Remove()
	end
end

--the very important viewcalc function, called by avehicles for third person view. @ warkanum
local lastviewpos = Vector(0,0,0)
function ENT:ClViewCalc(origin, angles, fov)
	local lply = LocalPlayer()
	local view = {}

	view.origin = origin
	if AVehicles.Vehicle.ViewThirdPerson then
		view.angles = angles + self.AimViewAngleAdjustment
	else
		view.angles = angles
	end
	view.fov = fov
	local pos = self:GetPos()
	/*
	local podcount = self.Entity:GetNetworkedInt("AVehicle_pod_count") or 0
	local pods = {}
	for t=0,podcount do
		local ent = ents.GetByIndex(self.Entity:GetNetworkedInt("AVehicle_pod_"..tostring(t) )) or nil
		if ent then
			pods[t] = ent
		end
	end
	*/
	local VeiwVec = self.ThirdPersonViewVec or self.ThirdPersonViewOffset or Vector(200, 0, 0)
	local offset = (view.angles:Forward() * VeiwVec.X) + (view.angles:Up() * VeiwVec.Z) + (view.angles:Right() * VeiwVec.Y)
	local neworigin = (pos - offset)

	local trace = {
			start = pos,
			endpos = neworigin,
			mask = MASK_SOLID_BRUSHONLY + MASK_PLAYERSOLID_BRUSHONLY  + CONTENTS_SOLID , //We only care about hitting the world
			--filter = self.Entity,
			mins = Vector(-15,-15,-15),
			maxs = Vector(15,15,15)
				}
	local tr = util.TraceHull( trace )
		if tr.Hit then
			if tr.HitWorld  then
				view.origin = tr.HitPos
			elseif IsValid(tr.Entity) then
				if  tr.Entity.IgnoreView then
					view.origin = lastviewpos
				else
					view.origin = tr.HitPos
				end
			end
		else
			view.origin = neworigin
		end
		lastviewpos = view.origin

	return view
end

--the very important viewcalc function, called by avehicles for locked first person view. @ warkanum
function ENT:ClViewCalcFP(origin, angles, fovv)
	local lply = LocalPlayer()
	local view = {}
	view.origin = origin
	view.angles = angles
	if (fovv) then
		view.fov = fovv + 20
	else
		view.fov = 90
	end
	
	if AVehicles.Vehicle and AVehicles.Vehicle.IsIn and IsValid(AVehicles.Vehicle.Ent) then
		local ent = AVehicles.Vehicle.Ent
		local pos = ent:GetPos()+(ent:GetUp()*20)+(ent:GetForward()*20)
		local ang = ent:GetAngles()
		view.origin = pos
		view.angles = ang
	end

	return view
end


/*
#####/#/////#/#####/#////#/#####//####/
#/////#/////#/#/////##///#///#///#////#
#//////#///#//#/////#/#//#///#///#/////
#####//#///#//#####/#/#//#///#////##///
#///////#/#///#/////#//#/#///#//////##/
#///////#/#///#/////#//#/#///#////////#
#////////#////#/////#///##///#///#////#
#####////#////#####/#////#///#////####/
Events:
*/

---------------------------------------------------------------------------Clientside events---------------------------------------------------------
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:EventsInitialize()
	self.BaseTimer = {}
	self.BaseTimer.Hud = 0
	self.BaseTimer.View = 0
	self.BaseTimer.Viewroll = 0
end

local Routine = AVehicles.Keys.Active --Quick reference, with clientside we don't include the player argument

function ENT:EventsRun()
	--Event for client player
	if AVehicles.Vehicle.IsIn then
		--Toggel view, function AVehicles.ViewToggel() is used for client @ Warkanum TPV, FPV, LFPV
		if Routine(self.Keyschema,"toggelview") then
			if self.BaseTimer.View < CurTime() then
				self.BaseTimer.View = CurTime() + 0.5
				AVehicles.ViewToggel()
			end	
		end 

		--Toggelhud
		if Routine( self.Keyschema,"toggelhud") then
			if self.BaseTimer.Hud < CurTime() then
				self.BaseTimer.Hud = CurTime() + 0.5
				if self.Hud.Enabled then
					self.Hud.Enabled = false
				else
					self.Hud.Enabled = true
				end
			end	
		end
		
		--Change 3rd person view distance
		if Routine(self.Keyschema,"viewdistance+") then
			self.ThirdPersonViewVec.X = math.Clamp(self.ThirdPersonViewVec.X + 5, -50, 2500)
		elseif Routine(self.Keyschema,"viewdistance-") then
			self.ThirdPersonViewVec.X = math.Clamp(self.ThirdPersonViewVec.X - 5, -50, 2500)
		end 
		
		--Change 3rd person view offset vector
		if Routine(self.Keyschema,"ViewPosUp") then
			self.ThirdPersonViewVec.Z = math.Clamp(self.ThirdPersonViewVec.Z + 1, -2000, 2500)
		elseif Routine(self.Keyschema,"ViewPosDown") then
			self.ThirdPersonViewVec.Z = math.Clamp(self.ThirdPersonViewVec.Z - 1, -2000, 2500)
		end 
		
		--Change 3rd person view offset angle
		if Routine(self.Keyschema,"ViewAngUp") then
			self.ThirdPersonAngleAdjust.p = math.Clamp(self.ThirdPersonAngleAdjust.p + 1, -30, 30)
		elseif Routine(self.Keyschema,"ViewAngDown") then
			self.ThirdPersonAngleAdjust.p = math.Clamp(self.ThirdPersonAngleAdjust.p - 1, -30, 30)
		end 
		
	
	end
end

function ENT:EventsOnRemove()
	
end



/*
#////#/#////#/####//
#////#/#////#/#///#/
#////#/#////#/#////#
######/#////#/#////#
#////#/#////#/#////#
#////#/#////#/#////#
#////#/#////#/#///#/
#////#//####//####//
Hud:
*/

function ENT:HudInitialize()
	self.Hud = {}
	self.Hud.Enabled = true
end 


local HudObjRt = 0
function ENT:DrawHud()

	
	if self.Hud.Enabled then
		local isTheDriver = false
		if (AVehicles.Vehicle.Pos == 0) then
			isTheDriver = true
		end
		
		local fontname = "Default"
		local scr_w, scr_h
		scr_w = ScrW()
		scr_h = ScrH()
		
		--The Hud!, Overide this function in your entity, do not change here!
		local tex=surface.GetTextureID("sprites/strider_blackball")
		local tpw = ScrW() *0.01
		local tph = ScrH() *0.01
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,100)
		
		surface.DrawTexturedRect((scr_w*0.5)-(self.CroshairScale*0.5), (scr_h*0.5)-(self.CroshairScale*0.5), self.CroshairScale,self.CroshairScale )
		
		if self.HudDrawAvehicleOverlay then
			--Draw Base back
			local baseBack=surface.GetTextureID("AVehicles/Hud/BackBack")
			surface.SetTexture(baseBack)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRect(0,0 , scr_w, scr_h)
		end
		
		--Hud position vars
		local pnld_w = 384
		local pnld_h = 140
		local pnld_left = 0
		local pnld_top = 0
		local bwith = 10
		
		if (GetConVarNumber("AVehicles_hudposoverride") >= 1) then
			self.HudPosition = (GetConVarNumber("AVehicles_hudposoverride") or 1) - 1 --Fix this later
		end
		
		if (self.HudPosition == 0) then --Left bottom
			pnld_left = 0
			pnld_top = scr_h - pnld_h
		elseif (self.HudPosition == 1) then --Center bottom
			pnld_left = (scr_w/2) - (pnld_w / 2)
			pnld_top = scr_h - pnld_h
		elseif (self.HudPosition == 2) then --right bottom
			pnld_left = scr_w - pnld_w
			pnld_top = scr_h - pnld_h
		elseif(self.HudPosition == 3) then --Left top
			pnld_left = 0
			pnld_top = 0
		elseif (self.HudPosition == 4) then --Center top
			pnld_left = (scr_w/2) - (pnld_w / 2)
			pnld_top = 0
		elseif (self.HudPosition == 5) then --right top
			pnld_left = scr_w - pnld_w
			pnld_top = 0
		end
		
		--Draw details panel
		local RightHud=surface.GetTextureID("AVehicles/Hud/pnldetails")
		surface.SetTexture(RightHud)
		surface.SetDrawColor(255,255,255,140)
		surface.DrawTexturedRect(pnld_left, pnld_top , pnld_w, pnld_h)
		
		--Health, Fuel etc
		local bcolor = Color(0,0,75,20)
		local fcolor = Color(255,255,255,255)
		draw.SimpleText("Hull Strength: " ..tostring(self.Damage.Hull).."%",fontname,pnld_left+5 , pnld_top+8, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Fuel: " ..tostring(self.Fuel.fuel).."%",fontname,pnld_left+5 , pnld_top+28, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText("Fuel Reserves: " ..tostring(self.Fuel.reserves).."%",fontname,pnld_left+5 , pnld_top+48, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if isTheDriver then
			draw.SimpleText("Driver / Pilot ",fontname,pnld_left+5 , pnld_top+68, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Passenger: " ..tostring(AVehicles.Vehicle.Pos).." ",fontname,pnld_left+5 , pnld_top+68, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		--Draw engine speeds

		--local speedh = math.Round(egs + tbs)
		--draw.SimpleText("Engines: ", "ScoreboardText", cW+120, cH+50, Color(100,20,20,200), 0, 1)
		--draw.SimpleText(tostring(speedh), "ScoreboardText", cW+218, cH+64, Color(100,20,20,200), 0, 1)
		

		
		if isTheDriver then
			--draw.SimpleText("Driver", "ScoreboardText", scr_w-26, cH-60, Color(100,20,20,200), 0, 1)
			--Draw engine active indicator, wich is a spinning rectangle for now

			if self.Engine.Active then
				local tbs = (self.Engine.Phys.TurboSpeed or 1) / (self.CustomEngine.TurboSpeed or 1) * 5
				local egs = (self.Engine.Phys.Speed or 1) / (self.CustomEngine.ForwardMaxSpeed or 1) * 2
		
				HudObjRt = HudObjRt + 0.3 + tbs + egs
				if HudObjRt >= 360 then
					HudObjRt = 0
				end
			end
			
			local revbar=surface.GetTextureID("AVehicles/Hud/rotmotor")
			surface.SetTexture(revbar)
			surface.SetDrawColor(255,255,255,240)
			surface.DrawTexturedRectRotated(pnld_left+pnld_w-bwith-64,pnld_top+pnld_h-bwith-32 , 64, 64, 360-HudObjRt)
			
						
			--Fuel warning	
			if (self.Fuel.reserves <= 1) then
				draw.WordBox(8, pnld_left+140 , pnld_top+pnld_h-bwith-100, "  FUEL EMPTY!", fontname, Color(200,0,0,200) , Color(200,200,200,255))
			elseif (self.Fuel.fuel <= 0)then
				draw.SimpleText(" FUEL LOW! ",fontname, pnld_left+140 , pnld_top+pnld_h-bwith-100, Color(200,0,0,200),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		
		--Damage warning
		if (self.Damage.Hull < self.Damage.HullFailureAmount) then
			draw.WordBox(8, pnld_left+140 , pnld_top+pnld_h-bwith-60, "HULL FAILURE!", fontname, Color(200,0,0,200) , Color(200,200,200,255))
		end
		
		--Draw selected weapon name self:GetActiveWeaponName()
		--draw.WordBox(8, pnld_left+pnld_w-bwith-140 , pnld_top+bwith+10, "WEAPON [ "..self.ActiveWeaponName .." ]", fontname, Color(0,0,0,200) , Color(250,250,250,255))
		draw.SimpleText("WEAPON [ "..self.ActiveWeaponName .." ]", fontname, pnld_left+pnld_w-bwith-140 , pnld_top+bwith+10, fcolor,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		--Draw passenger icons
		if self.PassengersIn >= 0 then
			local Passenger=surface.GetTextureID("AVehicles/Hud/passenger")
			surface.SetTexture(Passenger)
			surface.SetDrawColor(255,255,255,255)
			local Psw = 0
			for i=1,self.PassengersIn,1 do
				Psw = Psw + 20
				surface.DrawTexturedRect(pnld_left+Psw,pnld_top+pnld_h-bwith-20 , 10, 20)
			end
		end
				
		local trace = {
			start = self:GetPos(),
			endpos = (self:GetForward() * 90000),
			mask = MASK_SOLID_BRUSHONLY + MASK_PLAYERSOLID_BRUSHONLY  + CONTENTS_SOLID,  
			filter = self.Entity
		}
		local trace =  util.TraceLine(trace)
		self:DrawAVCrosshair(trace.HitPos)
		--self:DrawAVCrosshair(self:GetPos() + self:GetForward() * 9000)
	end
end

--Forward Aim crosshair. Now we always know which way is forward. @ Warkanum
function ENT:DrawAVCrosshair(targetpos)
	local pos = targetpos:ToScreen()
	local size = 15
	local marker=surface.GetTextureID("AVehicles/Hud/marker")
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(marker)
	surface.DrawTexturedRect(pos.x, pos.y,size,size)
end


/*
/####////###///#////#/#////#/####////####/
#////#//#///#//#////#/##///#/#///#//#////#
#//////#/////#/#////#/#/#//#/#////#/#/////
/##////#/////#/#////#/#/#//#/#////#//##///
///##//#/////#/#////#/#//#/#/#////#////##/
/////#/#/////#/#////#/#//#/#/#////#//////#
#////#//#///#//#////#/#///##/#///#//#////#
/####////###////####//#////#/####////####/
Sounds:
*/

----------------------------------------------------Clientside Sound--------------------------------------------------
--------------------------No more sounds spikes in my netgraph, lol-----------------------------------------------
-----------------------Definitions---------------------

---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:SoundsInitialize()
	self.Sound_Handlers = {}
	self.Sound_Flags = {}
	self.Sound_Handlers.EngineLoop =  CreateSound(self.Entity, Sound(self.Sounds.EngineLoop ))
	self.Sound_Handlers.AlarmLoop =  CreateSound(self.Entity, Sound(self.Sounds.AlarmFile ))
	self.Sound_Flags.EngineSoundPlaying = false
end 

function ENT:SoundsEngineStart()
	if self.Sounds.Enabled then
		if not self.Sound_Flags.EngineSoundPlaying then
			self.Sound_Flags.EngineSoundPlaying = true
			self.Sound_Handlers.EngineLoop:SetSoundLevel(self.Sounds.EngineSoundLevel)
			self.Sound_Handlers.EngineLoop:PlayEx(self.Sounds.EngineSoundVol, 100)
		end
	end
end 

function ENT:SoundsEngineStop()
	if self.Sounds.Enabled then
		if self.Sound_Flags.EngineSoundPlaying then
			self.Sound_Flags.EngineSoundPlaying = false
			self.Sound_Handlers.EngineLoop:Stop()
		end
	end
end 

function ENT:SoundsEnginePitchCall(active)
	if self.Sounds.Enabled and active then
		local velocity = self.Entity:GetVelocity()
		local pitch = self.Entity:GetVelocity():Length()
		------------------------------Doppler effect idea -> Thanks @ Jumper Code 
		local doppler_effect = 0
		if(not AVehicles.Vehicle.IsIn) then
			local direction = (LocalPlayer():GetPos() - self.Entity:GetPos() )
			doppler_effect = velocity:Dot(direction)/(150*direction:Length())
		end
		
		self.Sound_Handlers.EngineLoop:ChangePitch(math.Clamp(60 + pitch/15,60,180) + doppler_effect, 0.1)
	

	end
end 


function ENT:SoundsOnRemove()
	if self.Sound_Handlers.EngineLoop then self.Sound_Handlers.EngineLoop:Stop() end
	
end

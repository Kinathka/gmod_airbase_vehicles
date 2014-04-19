if not AVehicles then 
	Msg("\nAVehicle Base not installed! Please install it for this addon to work!\n")
end 

include('shared.lua')

language.Add("avehicle_heli_huey","Huey Venom")


function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Emitter = ParticleEmitter(self.Entity:GetPos(), true)
	self.DriverHud = true
	self.EngineStarted = false
	self.Flags.EngineSndStart = false
	self.FrontRotor = nil
	self.BackRotor = nil
	self.Crashed = false
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if IsValid(self.Entity) then
		--Engine start sound
		if not self.Flags.EngineSndStart then
			if (not self.Engine.Active and self.EngineStarted) then
				self:SoundsEngineStartupStart()
				self.Flags.EngineSndStart = true
			end
		end
		
		if self.Flags.EngineSndStart then
			if (self.Engine.Active) then
				self.Flags.EngineSndStart = false
				self:SoundsEngineStartupStop()
			elseif not self.EngineStarted then
				self.Flags.EngineSndStart = false
				self:SoundsEngineStartupStop()
			end
		end
		--Engine loop sound
		if not self.Flags.EngineSnd then
			if (self.Engine.Active and self.EngineStarted) then
				self:SoundsEngineStartupStop()
				self:SoundsEngineLoopStart()
				self.Flags.EngineSnd = true
			end
		end
		
		if self.Flags.EngineSnd then
			if not self.Engine.Active then
				self.Flags.EngineSnd = false
				self:SoundsEngineLoopStop()
			end
		end
		
		self:SoundsEnginePitchCall(self.Engine.Active)
	end
end

function ENT:GetStatus()
	self.BaseClass.GetStatus(self) --Call baseclass getstatus, always! @ Warkanum
	self.EngineStarted = self:GetNWBool("avengine_started") or false
	local rotorentid = self:GetNWInt("avengine_rotor_fronti") or -1
	local rotorentidb = self:GetNWInt("avengine_rotor_backi") or -1
	self.FrontRotor = ents.GetByIndex(rotorentid)
	self.BackRotor = ents.GetByIndex(rotorentidb)
	self.Crashed = self:GetNWBool("Crashed") or false
end

local ArrowMaterial = Material("WeltEnSTurm/helihud/arrow")
local MainColor = Color(70,199,50,150)

ENT.RenderGroup = RENDERGROUP_BOTH

local HudCol=Color(70,199,50,150)
function ENT:Draw()
	self.BaseClass.Draw(self)

	local pos = self:GetPos()
	local fwd = self:GetForward()
	local up = self:GetUp()
	local ri = self:GetRight()
	local ang = self:GetAngles()
	local uptm=self:GetNetworkedInt("Engine_TurboSpeed")
	local upm =self:GetNetworkedInt("Engine_Speed")/1900
	ang:RotateAroundAxis(ri, 90)
	ang:RotateAroundAxis(fwd, 90)
	local spos=self.PodPositions[0].Position --the local position of the pilot seat
	cam.Start3D2D(pos+ri*-(3.75+spos.y)+fwd*(12+spos.x)+up*(37.76+spos.z), ang, 0.015)
	surface.SetDrawColor(MainColor)
	surface.DrawRect(235, 249, 10, 2)
	surface.DrawRect(255, 249, 10, 2)
	surface.DrawRect(249, 235, 2, 10)
	surface.DrawRect(249, 255, 2, 10)
	surface.DrawRect(-3, 0, 3, 500)
	surface.DrawRect(500, 0, 3, 500)
	surface.DrawRect(7, 0, 3, 500)
	surface.DrawRect(490, 0, 3, 500)
	--markers
	surface.DrawRect(-6,-3,19,3)
	surface.DrawRect(-6,500,19,3)
	surface.DrawRect(487,-3,19,3)
	surface.DrawRect(487,500,19,3)
	surface.DrawRect(9,248,5,3)
	surface.DrawRect(485,248,5,3)

	surface.DrawRect(1, 500-uptm*500, 5, uptm*500) --rotor speed bar
	surface.DrawLine(30, 5*ang.r-200+2.77*ang.p, 220, 5*ang.r-200+2.77*(ang.p*0.12)) --artificial horizon, left line
	surface.DrawLine(30, 5*ang.r-200+2.77*ang.p+1, 220, 5*ang.r-200+2.77*(ang.p*0.12)+1)
	surface.DrawLine(280, 5*ang.r-200-2.77*(ang.p*0.12), 470, 5*ang.r-200-2.77*ang.p) --artificial horizon, right line
	surface.DrawLine(280, 5*ang.r-200-2.77*(ang.p*0.12)+1, 470, 5*ang.r-200-2.77*ang.p+1)
	surface.SetMaterial(ArrowMaterial)
	surface.DrawTexturedRect(-20,250-upm*250-10,20,20) --green arrow
	surface.DrawTexturedRectRotated(498,math.Clamp(250-self:GetVelocity().z/5.249*5,0,500),20,20,180) --Z speed arrow
	surface.SetTextColor(HudCol)
	--surface.SetFont("MenuLarge")
	surface.SetTextPos(-10, 505) 
	surface.DrawText("SPD")
	surface.SetTextPos(-10, 520)
	surface.DrawText(math.floor(self:GetVelocity():Length()/17.6))
	
	local tr=util.QuickTrace(pos,Vector(0,0,-999999),self.Entity)
	surface.SetTextPos(485,505)
	surface.DrawText("ALT")
	surface.SetTextPos(485,520)
	surface.DrawText(math.floor((pos.z-tr.HitPos.z)/5.249))
	
	cam.End3D2D()
	
	if self.EngineStarted then
		self:DrawEngineEffect()
	end
	if self.Crashed then
		self:DrawHeliEffect()
	end
end

function ENT:DrawHeliEffect()
	local pos = Vector(1,1,1)

	pos = self.Entity:GetPos() +(self.Entity:GetUp() * math.random(-80,80)) +(self.Entity:GetForward() * math.random(-100,100)) +(self.Entity:GetRight() * math.random(-40,40)) 
	
	local fwd = self.Entity:GetForward()
	local rht = self.Entity:GetRight()
	local vel = self.Entity:GetVelocity()
	local roll = math.Rand(-10,20)
	local id = self.Entity:EntIndex()
	local ang = self.Entity:GetAngles()
	
	if (self.Emitter) then
	
		local particle = self.Emitter:Add(table.Random(self.Effect_smokes),pos)
		particle:SetVelocity((fwd*-10)*Vector(math.random(1,7, math.random(1,7), math.random(1,7))))
		particle:SetDieTime(3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(10)
		particle:SetStartSize(100)
		particle:SetEndSize(50)
		particle:SetColor(Color(100,100,100,255))
		particle:SetRoll(roll)
		
		--self.Emitter:Finish()
	end
end

function ENT:DrawHud()
	self.BaseClass.DrawHud(self) --Adding this still draws default hud. Also look at hud position in shared.lua
	self.DriverHud = true
	if self.DriverHud then
		--The Hud!, Overide this function in your entity, do not change here!
		local tpw = ScrW() *0.01
		local tph = ScrH() *0.01
		local espeed = -5
		local VSpeeds = Angle(0,0,0)
		
		if self.Engine.Active then
			espeed = self.Engine.Phys.Speed or 0
			VSpeeds = 0 --Fix this
		end
		local dmg = self.Damage.Hull
		
		--To Do: Remove magic numbers
		
		--Croshair
		local tex=surface.GetTextureID("WeltEnSTurm/helihud/arrow")--sprites/strider_blackball
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,100)
		surface.DrawTexturedRect((ScrW()*0.5)-(self.CroshairScale*0.5), (ScrH()*0.5)-(self.CroshairScale*0.5), self.CroshairScale,self.CroshairScale )
		
		local bgr=surface.GetTextureID("HeliHUD/rpm_background")
		local needle=surface.GetTextureID("HeliHUD/airspeed_needle")
		local base=surface.GetTextureID("HeliHUD/compass_popup_base")
		local compass=surface.GetTextureID("HeliHUD/compass_dial")
		local orb=surface.GetTextureID("HeliHUD/attitude_bg")
		local orring=surface.GetTextureID("HeliHUD/attitude_or")
		local orhz=surface.GetTextureID("HeliHUD/attitude_hrz")
		local engineon=surface.GetTextureID("sprites/splodesprite")
		--Engine Meeter
		surface.SetTexture(base)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw, tph, 132, 132)
		
		surface.SetTexture(bgr)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw+3, tph, 128, 128)
	
		surface.SetTexture(needle)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(tpw+34, tph+72, 2, 40, (espeed*4)-140)
		
		surface.SetTexture(needle)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(tpw+96, tph+72, 2, 40, (120-(espeed*1.5) ) )
		
		--Compass
		surface.SetTexture(base)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw+128, tph, 132, 132)
		
		local angle = self:GetAngles().Yaw
		surface.SetTexture(compass)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(tpw+131+65, tph+65, 126, 126, angle)
		

		--Orientation
		surface.SetTexture(base)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw+256, tph, 132, 132)
		

		local angle = math.Clamp((self:GetAngles().Pitch *0.5), -15, 15)
		surface.SetTexture(orhz)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw+266+math.abs(angle*0.5), tph+40+angle, 110-(math.abs(angle)), 55)
		
		local angle = self:GetAngles().Roll
		surface.SetTexture(orring)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(tpw+256+66, tph+64, 114, 114, angle)
		
		surface.SetTexture(orb)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(tpw+259, tph, 128, 128)
		
		/*
		--Damage Indicator
		surface.SetTexture(base)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(ScrW()-132-tpw, tph, 132, 132)
		draw.SimpleText("Forward "..tostring(self.FForwardFlag).."X", "ScoreboardText", ScrW()-tpw-100, tph+40, Color(30,30,30,120), 0, 1)
		--draw.SimpleText("Damage", "ScoreboardText", ScrW()-tpw-100, tph+40, Color(30,30,30,120), 0, 1)
		--draw.SimpleText(tostring(dmg).."%", "ScoreboardText", ScrW()-tpw-100, tph+60, Color(30,30,30,120), 0, 1)
		--draw.SimpleText("", "ScoreboardText", ScrW()-tpw-100, tph+100, Color(30,30,30,120), 0, 1)
		*/
	else
		local base=surface.GetTextureID("HeliHUD/compass_popup_base")
		--Damage Indicator
		surface.SetTexture(base)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(ScrW()-132-tpw, tph, 132, 132)
		draw.SimpleText("Forward "..tostring(self.FForwardFlag).."X", "ScoreboardText", ScrW()-tpw-100, tph+40, Color(30,30,30,120), 0, 1)
		--draw.SimpleText("Damage", "ScoreboardText", ScrW()-tpw-100, tph+40, Color(30,30,30,120), 0, 1)
		--draw.SimpleText(tostring(dmg).."%", "ScoreboardText", ScrW()-tpw-100, tph+60, Color(30,30,30,120), 0, 1)
		--draw.SimpleText("", "ScoreboardText", ScrW()-tpw-100, tph+100, Color(30,30,30,120), 0, 1)
	end
end

	

--the very important viewcalc function, called by avehicles for locked first person view. @ warkanum
function ENT:ClViewCalcFP(origin, angles, fov)
//	LocalPlayer():ChatPrint("asd")
	if AVehicles.Vehicle and AVehicles.Vehicle.IsIn  and IsValid(AVehicles.Vehicle.Ent) then
		local view={}
		local ent = AVehicles.Vehicle.Ent
		local pos = ent:GetPos()+(ent:GetUp()*80)+(ent:GetForward()*104)
		view.origin = pos
		view.angles=ent:GetAngles()
		view.fov=fov+20
		return view
	end
end

--Override to add rotors as filters ents.
--the very important viewcalc function, called by avehicles for third person view. @ warkanum
local lastviewpos = Vector(0,0,0)
function ENT:ClViewCalc(origin, angles, fov)
	--This is better! @Warkanum
	return self.BaseClass.ClViewCalc(self, origin, angles, fov)
end


function ENT:DrawEngineEffect()

	local pos = self.Entity:GetPos() +(self.Entity:GetForward() * -130) + (self.Entity:GetRight() * 22.06)  +(self.Entity:GetUp() * 101) 
	local pos2 = self.Entity:GetPos() +(self.Entity:GetForward() * -130) + (self.Entity:GetRight() * -24.06)  +(self.Entity:GetUp() * 101) 
	local roll = math.Rand(-90,90)

	if (self.Emitter) then
		-- Heatwave 1
		local particle = self.Emitter:Add("sprites/heatwave",pos)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(40)
		particle:SetEndSize(20)
		particle:SetColor(Color(255,255,255,255))
		particle:SetRoll(roll)
			
		--self.Emitter:Finish()
		
		-- Heatwave 2
		particle = self.Emitter:Add("sprites/heatwave",pos2)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(40)
		particle:SetEndSize(20)
		particle:SetColor(Color(255,255,255,255))
		particle:SetRoll(roll)
			
		--self.Emitter:Finish()
	end
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
Vehicle Clientside Events:
*/

---------------------------------------------------------------------------Clientside events---------------------------------------------------------
--If we do not override it, baseclass gets run. @ Warkanum
--Incase you want to add something, call these respectively.
--self.BaseClass.EventsInitialize(self)
--self.BaseClass.EventsRun(self)

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
ENT.Sounds = ENT.Sounds or {}
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:SoundsInitialize()
	self.Sound_Handlers = {}
	self.Sound_Flags = {}
	self.Sound_Handlers.EngineLoop =  CreateSound(self.Entity, Sound(self.Sounds.EngineLoop ))
	self.Sound_Handlers.EngineStart = CreateSound(self.Entity, Sound(self.Sounds.EngineStart ))
	self.Sound_Handlers.AlarmLoop =  CreateSound(self.Entity, Sound(self.Sounds.AlarmFile ))
	
	
	self.Sound_Flags.EngineSoundPlaying = false
	self.Sound_Flags.EngineStartupPlaying = false

end 

function ENT:SoundsEngineLoopStart()
	if self.Sounds.Enabled then
		if not self.Sound_Flags.EngineSoundPlaying then
			self.Sound_Flags.EngineSoundPlaying = true
			self.Sound_Handlers.EngineStart:Stop()
			self.Sound_Handlers.EngineLoop:SetSoundLevel(self.Sounds.EngineSoundLevel)
			self.Sound_Handlers.EngineLoop:PlayEx(self.Sounds.EngineSoundVol, 100)
		end
	end
end 

function ENT:SoundsEngineLoopStop()
	if self.Sounds.Enabled then
		if self.Sound_Flags.EngineSoundPlaying then
			self.Sound_Flags.EngineSoundPlaying = false
			self.Sound_Handlers.EngineLoop:Stop()
		end
	end
end 


function ENT:SoundsEngineStartupStart()
	if self.Sounds.Enabled then
		if not self.Sound_Flags.EngineStartupPlaying then
			self.Sound_Flags.EngineStartupPlaying = true
			self.Sound_Handlers.EngineStart:SetSoundLevel(self.Sounds.EngineSoundLevel)
			self.Sound_Handlers.EngineStart:PlayEx(self.Sounds.EngineSoundVol, 160)
		end
	end
end 

function ENT:SoundsEngineStartupStop()
	if self.Sounds.Enabled then
		if self.Sound_Flags.EngineStartupPlaying then
			self.Sound_Flags.EngineStartupPlaying = false
			self.Sound_Handlers.EngineStart:Stop()
		end
	end
end 


function ENT:SoundsEnginePitchCall(active)
	if self.Sounds.Enabled and active then
		local velocity = self.Entity:GetVelocity()
		local pitch = self.Entity:GetVelocity():Length()
		------------------------------Doppler effect idea -> Thanks @ Jumper Code 
		local doppler_effect = 0
		if(not self.ClientIn) then
			local direction = (LocalPlayer():GetPos() - self.Entity:GetPos() )
			doppler_effect = velocity:Dot(direction)/(150*direction:Length())
		end
		local VelocityPitch = (math.Clamp(60 + pitch/15,60,120)*0.3)
		local EnginePitch = 40 -- math.Clamp((self.Engine.Phys.Speed*5)+60, 55, 60)
		if IsValid(self.FrontRotor) then
			EnginePitch = math.Clamp(((self.FrontRotor:GetVelocity():Length() - self:GetVelocity():Length()) / 2000) * 200, 30, 50)
		end
		self.Sound_Handlers.EngineLoop:ChangePitch(EnginePitch + VelocityPitch + doppler_effect, 0.1)

	end
end 


function ENT:SoundsOnRemove()
	if self.Sound_Handlers.EngineLoop then self.Sound_Handlers.EngineLoop:Stop() end
	self.Sound_Handlers.EngineStart:Stop()

end

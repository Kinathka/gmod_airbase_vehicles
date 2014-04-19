if not AVehicles then 
	Msg("\nAVehicle Base not installed! Please install it for this addon to work!\n")
end 
include('shared.lua')
language.Add("avehicle_heli_mh6littlebird","Heli ah6")

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

function ENT:Draw()
	self.BaseClass.Draw(self)
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
		local tex=surface.GetTextureID("sprites/strider_blackball")
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
function ENT:ClViewCalcFP(origin, angles, fovv)
	local lply = LocalPlayer()
	local view = {}
	view.origin = origin
	view.angles = angles
	if (fovv) then
		view.fov = fovv
	else
		view.fov = 90
	end
	
	if AVehicles.Vehicle and AVehicles.Vehicle.IsIn  and IsValid(AVehicles.Vehicle.Ent) then
		local ent = AVehicles.Vehicle.Ent
		local pos = ent:GetPos()+(ent:GetUp()*80)+(ent:GetForward()*30)+(ent:GetRight()*13) --Vector(25,-13,50)
		local ang = ent:GetAngles()
		view.origin = pos
		view.angles = ang
	end

	return view
end

--Override to add rotors as filters ents.
--the very important viewcalc function, called by avehicles for third person view. @ warkanum
local lastviewpos = Vector(0,0,0)
function ENT:ClViewCalc(origin, angles, fov)
	local lply = LocalPlayer()
	local view = {}
	view.origin = origin
	view.angles = angles
	view.fov = fov
	local pos = self:GetPos()
	local podcount = self.Entity:GetNetworkedInt("AVehicle_pod_count") or 0
	local pods = {}
	for t=0,podcount do
		local ent = ents.GetByIndex(self.Entity:GetNetworkedInt("AVehicle_pod_"..tostring(t) )) or nil
		if ent then
			pods[t] = ent
		end
	end
	
	
	local VeiwVec = self.ThirdPersonViewVec or self.ThirdPersonViewOffset or Vector(200, 0, 0)
	local offset = (view.angles:Forward() * VeiwVec.X) + (view.angles:Up() * VeiwVec.Z) + (view.angles:Right() * VeiwVec.Y)
	local neworigin = (pos - offset)
	local filterents = {self.Entity,self.FrontRotor,self.BackRotor,}
	table.Add(filterents, pods)
	table.Add(filterents, self.HardPointEnts)
	
	local trace = {
			start = pos,
			endpos = neworigin,
			filter = filterents
				}
	local tr = util.TraceLine( trace )
		if tr.Hit then
			if tr.HitWorld  then
				view.origin = tr.HitPos * 0.98
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



function ENT:DrawEngineEffect()

	local pos = self.Entity:GetPos() +(self.Entity:GetForward() * -75) + (self.Entity:GetUp() *-9) 
	local roll = math.Rand(-90,90)
	
	if (self.Emitter) then
		
		-- Heatwave
		local particle = self.Emitter:Add("sprites/heatwave",pos)
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

if not AVehicles then 
	Msg("\nAJumper:AVehicle Base not installed! Please install it for this addon to work!\n")
end 

include('shared.lua')

language.Add("avehicle_puddlejumperv29","AV Puddle Jumper V 2.9")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Emitter = ParticleEmitter(self.Entity:GetPos(), true)
	self.Wings = false
	self.Cloaked = false
	self.Flags = {}
	self.Flags.EngineSnd = false
	self.Flags.HoverSnd = false
	self.ShieldStrength = 0
	self.ServerInfoTick = 0
end


function ENT:GetStatus()
	self.BaseClass.GetStatus(self)

	--Get the damage  from the server
	self.Damage.Hull = self.Entity:GetNetworkedInt("Damage_Hull") or 0
	self.ShieldStrength = self:GetNWInt("avehicle_sg_shield_strength") or 0
end

function ENT:Think()
	if IsValid(self.Entity) then
		if self.Wings then
			self:DrawEngineEffect()
		end
		
		self:EventsRun() --Run clientside events (key binds and routines etc)
		--Get information from server, not critical info ins't that important and fast.
		if self.ServerInfoTick < CurTime() then
			self.ServerInfoTick = CurTime() + self.ServerInfoTickTime
			self:GetStatus()
		end
		
		--Critical Info.
		self.Wings = self.Entity:GetNWBool("AVehicle_Jumper_Wings") or false
		self.Cloaked = self.Entity:GetNWBool("AVehicle_Jumper_Cloaked") or false
		
		if self.Engine.Active and self.Wings then
			if not self.Flags.EngineSnd then
				self:SoundsEngineStart()
				self.Flags.EngineSnd = true
			end
			if self.Flags.HoverSnd then
				self:SoundsHoverStop()
				self.Flags.HoverSnd = false
			end
		elseif (self.Engine.Active and !self.Wings) then
			if not self.Flags.HoverSnd then
				self:SoundsHoverStart()
				self.Flags.HoverSnd = true
			end
			if self.Flags.EngineSnd then
				self:SoundsEngineStop()
				self.Flags.EngineSnd = false
			end
		end
		if self.Cloaked then
			if self.Flags.EngineSnd then
				self:SoundsEngineStop()
				self.Flags.EngineSnd = false
			end
			if self.Flags.HoverSnd then
				self:SoundsHoverStop()
				self.Flags.HoverSnd = false
			end
		end
		
		if not self.Engine.Active then
			if self.Flags.EngineSnd then
				self.Flags.EngineSnd = false
				self:SoundsEngineStop()
			end
			if self.Flags.HoverSnd then
				self.Flags.HoverSnd = false
				self:SoundsHoverStop()
			end
		end
		if self.Engine.Active then
			self:SoundsEnginePitchCall(true)
		end
		
	end
end


function ENT:Draw()
	self.BaseClass.Draw(self)
	if self.Wings then
		self:DrawEngineEffect()
	end
end


-- I modified this but got the idea from Avon and RononDex. @ Warkanum
function ENT:DrawEngineEffect()
	local pos = {}
	
	local el = self.Entity:GetAttachment(self.Entity:LookupAttachment("EngineLeft"))
	local er = self.Entity:GetAttachment(self.Entity:LookupAttachment("EngineRight"))
	
	if (self.Emitter) then
	
		pos[1] = self.Entity:GetPos() + (self.Entity:GetRight() * 80) + (self.Entity:GetUp() * -20) +(self.Entity:GetForward() * -100) 
		pos[2] = self.Entity:GetPos() + (self.Entity:GetRight() * -80) + (self.Entity:GetUp() * -20) +(self.Entity:GetForward() * -100) 
		pos[1] = el.Pos + self.Entity:GetForward()*-50
		pos[2] = er.Pos + self.Entity:GetForward()*-50
		
		for i=1,2  do
			local fwd = self.Entity:GetForward()
			local vel = self.Entity:GetVelocity()
			local roll = math.Rand(-90,90)
			local id = self.Entity:EntIndex()
			local ang = self.Entity:GetAngles()
			

			--pos:Rotate(self.Entity:GetAngles())
			-- Blue core
			local particle = self.Emitter:Add("sprites/bluecore",pos[i])
			particle:SetVelocity(vel - 500*fwd)
			particle:SetDieTime(0.045)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(150)
			particle:SetStartSize(23)
			particle:SetEndSize(22.5)
			particle:SetColor(Color(255,255,255,255))
			particle:SetRoll(roll)
			
			-- Heatwave
			local particle = self.Emitter:Add("sprites/heatwave",pos[i])
			particle:SetDieTime(0.2)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(40)
			particle:SetEndSize(18)
			particle:SetColor(Color(255,255,255,255))
			particle:SetRoll(roll)
			
			
			-- Light from the engine
			local dynlight = DynamicLight(id + 4096*i)
			dynlight.Pos = pos[i]
			dynlight.Brightness = 5
			dynlight.Size = 384
			dynlight.Decay = 1024
			dynlight.R = 134
			dynlight.G = 215
			dynlight.B = 245
			dynlight.DieTime = CurTime()+1

			
		end
		--self.Emitter:Finish()
		
	end
end





function ENT:ClViewCalc(origin, angles, fov)
	--I prefer you see the basecla
	return self.BaseClass.ClViewCalc(self, origin, angles, fov)
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

	if AVehicles.Vehicle and AVehicles.Vehicle.IsIn  and IsValid(AVehicles.Vehicle.Ent) then
		local ent = AVehicles.Vehicle.Ent
		local pos = ent:GetPos()+(ent:GetUp()*20)+(ent:GetForward()*70)
		local ang = ent:GetAngles()
		view.origin = pos
		view.angles = ang
	end

	return view
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
		
		draw.WordBox(8, pnld_left+5 , pnld_top+2, "Hull Strength: " ..tostring(self.Damage.Hull).."%", fontname, bcolor , fcolor)
		draw.WordBox(8, pnld_left+5 , pnld_top+22, "Fuel: " ..tostring(self.Fuel.fuel).."%", fontname, bcolor, fcolor )
		draw.WordBox(8, pnld_left+5 , pnld_top+42, "Fuel Reserves: " ..tostring(self.Fuel.reserves).."%", fontname, bcolor, fcolor)
		draw.WordBox(8, pnld_left+70 , pnld_top+22, "Shield: " ..tostring(self.ShieldStrength).."%", fontname, bcolor, fcolor)
		if isTheDriver then
			draw.WordBox(8, pnld_left+5 , pnld_top+62, "Position: Driver", fontname, bcolor, fcolor )
		else
			draw.WordBox(8, pnld_left+5 , pnld_top+62, "Position: " ..tostring(AVehicles.Vehicle.Pos).." seat", fontname, bcolor, fcolor )
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
				draw.WordBox(8, pnld_left+140 , pnld_top+pnld_h-bwith-100, "  FUEL LOW!  ", fontname, Color(200,0,0,200) , Color(200,200,200,255))
			end
		end
		
		--Damage warning
		if (self.Damage.Hull < self.Damage.HullFailureAmount) then
			draw.WordBox(8, pnld_left+140 , pnld_top+pnld_h-bwith-60, "HULL FAILURE!", fontname, Color(200,0,0,200) , Color(200,200,200,255))
		end
		
		--Draw selected weapon name self:GetActiveWeaponName()
		draw.WordBox(8, pnld_left+pnld_w-bwith-140 , pnld_top+bwith+10, "WEAPON [ "..self.ActiveWeaponName .." ]", fontname, Color(0,0,0,200) , Color(250,250,250,255))
		
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
function ENT:EventsInitialize()
	self.BaseClass.EventsInitialize(self)
end

local Routine = AVehicles.Keys.Active --Quick reference, with clientside we don't include the player argument

function ENT:EventsRun()
	self.BaseClass.EventsRun(self)
	if AVehicles.Vehicle.IsIn then
		if Routine(self.Keyschema,"toggelview") then

		end 
	end
end

function ENT:EventsOnRemove()
	
end
*/


----------------------------------------------------Clientside Sound--------------------------------------------------
--------------------------No more sounds spikes in my netgraph, lol-----------------------------------------------
-----------------------Definitions---------------------
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:SoundsInitialize()
	self.Sound_Handlers = {}
	self.Sound_Flags = {}
	self.Sound_Handlers.EngineLoop =  CreateSound(self.Entity, Sound(self.Sounds.Jumper.Engine ))
	self.Sound_Handlers.HoverLoop =  CreateSound(self.Entity, Sound(self.Sounds.Jumper.Hover))
	self.Sound_Handlers.AlarmLoop =  CreateSound(self.Entity, Sound(self.Sounds.AlarmFile ))
	self.Sound_Flags.EngineSoundPlaying = false
	self.Sound_Flags.HoverSoundPlaying = false
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

function ENT:SoundsHoverStart()
	if self.Sounds.Enabled then
		if not self.Sound_Flags.HoverSoundPlaying then
			self.Sound_Flags.HoverSoundPlaying = true
			self.Sound_Handlers.HoverLoop:SetSoundLevel(self.Sounds.EngineSoundLevel)
			self.Sound_Handlers.HoverLoop:PlayEx(self.Sounds.EngineSoundVol-20, 100)
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

function ENT:SoundsHoverStop()
	if self.Sounds.Enabled then
		if self.Sound_Flags.HoverSoundPlaying then
			self.Sound_Flags.HoverSoundPlaying = false
			self.Sound_Handlers.HoverLoop:Stop()
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
		
		if self.Sound_Flags.EngineSoundPlaying and pitch > 0  then
			self.Sound_Handlers.EngineLoop:ChangePitch(tonumber(math.Clamp(40 + pitch/40,40,140) + doppler_effect), 0.5)
		end
		if self.Sound_Flags.HoverSoundPlaying and pitch > 0 then
			self.Sound_Handlers.HoverLoop:ChangePitch(tonumber(math.Clamp(60 + pitch/30,80,120) + doppler_effect), 0.5)
		end			
	end
end 


function ENT:SoundsOnRemove()
	if self.Sound_Handlers.EngineLoop then self.Sound_Handlers.EngineLoop:Stop() end
	if self.Sound_Handlers.HoverLoop then self.Sound_Handlers.HoverLoop:Stop() end
end

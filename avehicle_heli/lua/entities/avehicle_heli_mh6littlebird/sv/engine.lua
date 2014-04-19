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
#####-#----#---###---#-#----#-#####
#-----##---#--#---#--#-##---#-#----
#-----#-#--#-#-----#-#-#-#--#-#----
#####-#-#--#-#-------#-#-#--#-#####
#-----#--#-#-#---###-#-#--#-#-#----
#-----#--#-#-#-----#-#-#--#-#-#----
#-----#---##--#---#--#-#---##-#----
#####-#----#---###---#-#----#-#####
*/
function ENT:SetupRotorEngine()
	--Helicopter Rotor Engine values
	self.RotorEngine = {}
	self.RotorEngine.SlowDownSpeed = 3
	self.RotorEngine.BalancePitchAdd = 2.5
	self.RotorEngine.BalanceRollAdd = 3.2
	self.RotorEngine.PitchSpeedMul = 0.3
	self.RotorEngine.RollSpeedMul = 0.2
	self.RotorEngine.AutoRollCounter = 0
	self.RotorEngine.MaxSideSpeed = 400
	self.RotorEngine.MaxFWDSpeed = 600
	self.RotorEngine.levelout = false
	self.RotorEngine.hovermode = true
	self.RotorToEngineSpeed = 200 --The speed that the main rotor must turn for the engine to work.
end

function ENT:StartEngine()
	if self.IsBadlyDamaged then return false end
	if not self.Engine.Active then
		--Do startup sequence here.
		self.EngineStarted = true
		self:SetNWBool("avengine_started", self.EngineStarted)
		--After sequence activate the engine.
		timer.Simple(3.0, function() 
			if IsValid(self) then
				self.BaseClass.EngineOn(self) --Call baseclass engine on, this actually starts the main engines.
				self:SetNWBool("avengine_started", self.EngineStarted)
			end
		end)
	end
end


--A little override to fix a bug that I had. @ Warkanum
function ENT:EngineOff()
	self:StopEngine()
	self.Engine.Active = false
	self.Entity:SetNetworkedBool("Engine_Active", self.Engine.Active)
end

function ENT:EngineOn()
	if self.IsBadlyDamaged then return false end
	self:StartEngine()
end

function ENT:StopEngine()
	self.EngineStarted = false
	self.Engine.Active = false
	self.Entity:SetNetworkedBool("Engine_Active", self.Engine.Active)
	self:SetNWBool("avengine_started", self.EngineStarted)
end


-------------------Check some engine operational stuff here. @ Warkanum
-- Override in child entities if you want to change something.
function ENT:EngineOperationChecks()
	self.BaseClass.EngineOperationChecks(self)
	
	--check if we have a rotor that is turning at speed else turn off engine.
	if IsValid(self.Rotors.Front) and self.Engine.Active and self.EngineStarted then
		local phys = self.Rotors.Front:GetPhysicsObject()
		if phys:IsValid() and (phys:GetAngleVelocity():Length() < self.RotorToEngineSpeed) then
			self:StopEngine()
			self:DamageHurt(800, "rotor")
		end
	end

	--Water Check, then hamper mobility.
	if self.Engine.Phys.Submerged then
		self:DamageHurt(100, "water")
		self:StopEngine()
	end

end

--Call it through PhysicsSimulate. It returns the ShadowControl Params @ Warkanum
function ENT:EnginePhysicsSimulate( phys, deltatime )
	if (self.Engine.Active) then --and (deltatime > 0.01) 
		phys:Wake()
		local fwd = self:GetForward()
		local side = self:GetRight()
		local up = self:GetUp()
		local vpos = self:GetPos()
		local arot = self:GetAngles()
		local vvel = phys:GetVelocity()
		--What, What's this? Stop the simulation if we want to stop. Ex. We ran into a wall.
		if (self.Engine.Simulated.emergencystop) then
			if vvel:Length() < self.Engine.Simulated.causerestart then
				self.Engine.Simulated.emergencystop	 = false
			end
			
			self.Engine.Simulated.fwd = 0
			self.Engine.Simulated.side = 0
			self.Engine.Simulated.ud = 0
			return false --Bail and don't update.
		end
		
		--check if we have a rotor that is turning
		if IsValid(self.Rotors.Front) and not self.IsBadlyDamaged then
			local phys = self.Rotors.Front:GetPhysicsObject()
			if phys:IsValid() and (phys:GetAngleVelocity():Length() < self.RotorToEngineSpeed) then
				return false --Bail and don't update.
			end
		end
		
		--Turbo Checking
		local fwdacc = self.Engine.Simulated.fwdaccspeed
		local fwdspeed = self.Engine.Phys.Speed
		if fwdspeed < 0 then
			fwdacc = fwdacc * 1.5
		end

		local pitchspeed = self.RotorEngine.PitchSpeedMul
		local rollspeed = self.RotorEngine.RollSpeedMul
		if self.RotorEngine.hovermode then
			pitchspeed = self.RotorEngine.PitchSpeedMul * 0.6
			rollspeed = self.RotorEngine.RollSpeedMul * 0.4
			fwdacc = fwdacc * 0.8
			fwdspeed = math.Clamp(fwdspeed, -100, 100)
		end
		
		if (math.abs(arot.p) > self.RotorEngine.BalancePitchAdd) then
			self.Engine.Simulated.fwd = math.Clamp(self.Engine.Simulated.fwd+(pitchspeed*arot.p), self.RotorEngine.MaxFWDSpeed*-0.8, self.RotorEngine.MaxFWDSpeed)
		else
			self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,0,self.RotorEngine.SlowDownSpeed)
		end
		
		if math.abs(arot.r) > self.RotorEngine.BalanceRollAdd and (math.abs(self.RotorEngine.AutoRollCounter) < 3.0) then
			self.Engine.Simulated.side = math.Clamp(self.Engine.Simulated.side+(rollspeed*arot.r),self.RotorEngine.MaxSideSpeed*-1,self.RotorEngine.MaxSideSpeed)
		else
			self.Engine.Simulated.side = math.Approach(self.Engine.Simulated.side,0,self.RotorEngine.SlowDownSpeed)
		end
		
		if self:OnGround() then --Just a check for smooth landing
			self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,0,1.5)
			self.Engine.Simulated.side = math.Approach(self.Engine.Simulated.side,0,3.0)
		end
		
		--self.Engine.Simulated.fwd = math.Approach(self.RotorEngine.PitchBuffer,1000,self.RotorEngine.PitchBufferSpeed)
		--self.Engine.Simulated.side = math.Approach(self.RotorEngine.RollBuffer,1000,self.RotorEngine.RollBufferSpeed)
		
		self.Engine.Simulated.ud = math.Approach(self.Engine.Simulated.ud,fwdspeed,fwdacc)
		
		
		--Mouse and control angles
		if self.Engine.MouseSteer then
			if (self:GetClientThirdPersonView(self.Passengers[0]) == 2) then --Locked FP
				if IsValid(self.Passengers[0]) then
					--self.Passengers[0]:SetEyeAngles(arot)
					local mouseX = 0
					local mouseY = 0
					-- self.Passengers[0]:GetCurrentCommand():MouseX() --Bombs garrysmod and lately returns an error. I use a workaround.
					if AVehicles.Vehicle.PlayersMouseData and AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]] then
						mouseX = AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MouseX
						mouseY = AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MouseY
					end
					local ExtraRoll = math.Clamp(mouseX*-1,-1*self.Engine.Simulated.autorollmaxdeg,self.Engine.Simulated.autorollmaxdeg) 
					local mul = math.Clamp((vvel:Length()/self.Engine.Simulated.autorollspeedmax),0,1)
					self.RotorEngine.AutoRollCounter = (ExtraRoll*mul*-1)
					self.Engine.Simulated.ang.y = arot.y + math.Clamp(mouseX*-1,-100,100)
					self.Engine.Simulated.ang.p = arot.p + math.Clamp(mouseY,-100,100)
					--self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,(ExtraRoll*mul*-1)+self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
					--self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
				else
					self.Engine.Simulated.ang = arot --If we don't have a pilot, just stay at that rotation
				end
			else --Free FP and TP
				if IsValid(self.Passengers[0]) and ((not self.RotorEngine.hovermode and not self.Engine.Simulated.mousefreelook) or (self.RotorEngine.hovermode and self.Engine.Simulated.mousefreelook)) then
					local aim = self.Passengers[0]:GetAimVector()
					local ang = aim:Angle()
					if (self:GetClientThirdPersonView(self.Passengers[0]) == 0) then
						ang = aim:Angle() + (self.AimViewAnjustment *(-1))
					end
					local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(vpos + aim).y)),-1*self.Engine.Simulated.autorollmaxdeg,self.Engine.Simulated.autorollmaxdeg)
					local mul = math.Clamp((vvel:Length()/self.Engine.Simulated.autorollspeedmax),0,1)
					self.RotorEngine.AutoRollCounter = (ExtraRoll*mul*-1)
					self.Engine.Simulated.ang.y = ang.y
					self.Engine.Simulated.ang.p = ang.p
				else
					self.Engine.Simulated.ang = arot --If we don't have a pilot, just stay at that rotation
					self.RotorEngine.AutoRollCounter = 0
				end
			end
			
			self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,self.RotorEngine.AutoRollCounter+self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
		else

			self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
			self.Engine.Simulated.ang.p = math.ApproachAngle(self.Engine.Simulated.ang.p,self.Engine.Phys.Pitch,self.Engine.Simulated.angmovespeed.p)
			self.Engine.Simulated.ang.y = math.ApproachAngle(self.Engine.Simulated.ang.y,self.Engine.Phys.Yaw,self.Engine.Simulated.angmovespeed.y)
		end
		
		if self.RotorEngine.levelout then
			self.Engine.Phys.Roll = 0
			self.Engine.Phys.Pitch = 0
			self.Engine.Phys.Yaw = 0
			self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,0 ,0.5)
			self.Engine.Simulated.side = math.Approach(self.Engine.Simulated.side,0 ,0.5)
			self.Engine.Simulated.ang.r = 0
			self.Engine.Simulated.ang.p = 0
		end
		
		if self.RotorEngine.hovermode then
			self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,math.Clamp(self.Engine.Simulated.fwd,-100,100),2.0)
			self.Engine.Simulated.side = math.Approach(self.Engine.Simulated.side,math.Clamp(self.Engine.Simulated.side,-100,100),2.0)
		end
		
		local FlightPhys ={
			secondstoarrive	= 1;
			pos = vpos + (fwd*self.Engine.Simulated.fwd) + (side*self.Engine.Simulated.side) + (up*self.Engine.Simulated.ud);
			maxangular		= 10000; --10000
			maxangulardamp	= 3000; --1000
			maxspeed			= 12000; --1000000
			maxspeeddamp		= 8000; --500000
			dampfactor		= 1;
			teleportdistance	= 0;--5000
		}
		--Update angel depending on the controller.
		if self.Engine.MouseSteer then
			FlightPhys.angle = self.Engine.Simulated.ang
		else
			FlightPhys.angle = self:LocalToWorldAngles(self.Engine.Simulated.ang)
		end
		
		--Angular levelout
		if self.RotorEngine.levelout then
			FlightPhys.angle.r = 0
			FlightPhys.angle.p = 0
			--FlightPhys.angle.y = 0
		end
		
		if self.Damage.HasExpleded and not self.IsBadlyDamaged then
			FlightPhys.angle.r = FlightPhys.angle.r + math.random(1,10)
			FlightPhys.angle.p = FlightPhys.angle.p + math.random(1,10)
			FlightPhys.angle.y = FlightPhys.angle.y + math.random(20,100)
		end
		
		phys:ComputeShadowControl(FlightPhys)
		return true
	else
		self.Engine.Phys.Roll			= 0
		self.Engine.Phys.Pitch			= 0
		self.Engine.Phys.Yaw			= 0
		self.Engine.Simulated.side		= 0
		self.Engine.Simulated.ud		= 0
		self.Engine.Phys.UpDownSpeed	= 0
		self.Engine.Phys.StrafeSpeed	= 0
		self.Engine.Phys.Speed			= 0
		self.Engine.Simulated.fwd		= 0
		self.Engine.Phys.TurboSpeed		= 0
		self.Engine.Simulated.ang		= Angle(0,0,0)
	end
	return
end

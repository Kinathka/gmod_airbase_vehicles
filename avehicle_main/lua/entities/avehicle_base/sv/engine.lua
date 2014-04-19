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


---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
----------------------Initialize Engine System Variables @ Warkanum
function ENT:EngineInitialize()
	self.Engine = {}
	self.AIControlledEngine 				= false
	self.Engine.Active 						= false
	self.Engine.RemoteControlled			= false
	self.Engine.Simulated					= {}
	self.Engine.Simulated.emergencystop		= false --Internal use
	self.Engine.Simulated.mousefreelook		= false	 --if on, mouse will be unlock and you can look freely. --internal, set in events
	self.Engine.Simulated.hovers			= self.SimEngine.hovers --Will the vehicle fall to ground as soon as it stops moving?
	self.Engine.Simulated.causerestart		= self.SimEngine.causerestart --Engines will restart when velocity falls below this. Use for when crashed into a wall.
	self.Engine.Simulated.fwd 				= 0 --Internal use
	self.Engine.Simulated.side 				= 0 --Internal use
	self.Engine.Simulated.ud 				= 0 --Internal use
	self.Engine.Simulated.fwdaccspeed		= self.SimEngine.fwdaccspeed
	self.Engine.Simulated.trbaccspeed		= self.SimEngine.trbaccspeed
	self.Engine.Simulated.sideaccspeed		= self.SimEngine.sideaccspeed
	self.Engine.Simulated.udaccspeed		= self.SimEngine.udaccspeed
	self.Engine.Simulated.autorollspeedmax	= self.SimEngine.autorollspeedmax
	self.Engine.Simulated.autorollmaxdeg	= self.SimEngine.autorollmaxdeg
	self.Engine.Simulated.speedtohover		= self.SimEngine.speedtohover
	self.Engine.Simulated.ang				= Angle(0,0,0) --Internal use
	self.Engine.Simulated.angmovespeed		= self.SimEngine.angmovespeed
	self.Engine.Phys						= {} --Internal use
	self.Engine.Phys.Roll					= 0 --Internal use
	self.Engine.Phys.Pitch					= 0 --Internal use
	self.Engine.Phys.Yaw					= 0 --Internal use
	self.Engine.Phys.UpDownSpeed			= 0 --Internal use
	self.Engine.Phys.StrafeSpeed			= 0 --Internal use
	self.Engine.Phys.Speed					= 0 --Internal use
	self.Engine.Phys.TurboSpeed				= 0 --Internal use
	self.Engine.Phys.DragRate				= self.CustomEngine.DragRate
	self.Engine.Phys.AngleDragRate  		= self.CustomEngine.AngleDragRate
	self.Engine.Phys.FixedZAxis				= false --Developer use	
	--self.Engine.LastPilotSense				= 0 --Internal

	self.Engine.MouseSteer							= true  --Internal use --Steer with mouse if not then controls
	self.Engine.CustomEngine 						= {}
	self.Engine.CustomEngine.GravitySysEnabled		= self.CustomEngine.GravitySystem
	self.Engine.CustomEngine.GravityEnabled			= false --Changed internally
	self.Engine.CustomEngine.ContraintGravity 		= false --Changed internally
	self.Engine.CustomEngine.ContraintSysEnabled 	= self.CustomEngine.ContraintSystem
	self.Engine.CustomEngine.StopAfter				= self.NoPilotStopEngineTime
	self.Engine.CustomEngine.KillAfter				= self.NoPilotKillEngineTime


	self.Engine.Contraints_LinkedEntities			= {}
	
	self.Engine.Phys.Submerged				= true
	self.Engine.Phys.WaterDepth				= 0
	
	self.Engine.RotorWash = {}
	self.Engine.RotorWash.Ent = nil
	self.Engine.RotorWash.Enabled = true
	self.Engine.RotorWash.CanCreate = self.CustomEngine.RotorWash
	self.Engine.RotorWash.Altitude = self.CustomEngine.RotorWashAltitude
	
	/*
	--Please put this in the initialize function of the child entities if you want PhysicsSimulate  to be called.
	--It must go before the physics is waked.
	if (!self.EngineUseCustom) then
		self:StartMotionController()
	end
	*/
	
end

------ A few function I added to make stuff easier, lol @ Warkanum
function ENT:EngineOn()
	if self:FuelisEmpty() then return false end
	self.Engine.Active = true
	self.Entity:SetNetworkedBool("Engine_Active", self.Engine.Active)
	--A little fix for a problem I had.
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	return true
end

function ENT:EngineOff()
	self.Engine.Active = false
	self.Entity:SetNetworkedBool("Engine_Active", self.Engine.Active)
	return true
end

function ENT:EngineIsActive()
	return self.Engine.Active 
end

----------------------Add Rotor Wash effect entity @ Warkanum
function ENT:EngineAddRotorWash()
	if(not self.Engine.RotorWash.CanCreate) then return end
	if(not self.Engine.RotorWash.Enabled) then return end
	self:EngineRemoveRotorWash()
	local e = ents.Create("env_rotorwash_emitter")
	e:SetPos(self.Entity:GetPos())
	e:SetKeyValue("altitude",self.Engine.RotorWash.Altitude)
	e:Spawn()
	e:Activate()
	e:SetParent(self.Entity)
	self.Engine.RotorWash.Ent = e
end

----------------------Remove Rotor Wash effect entity @ Warkanum
function ENT:EngineRemoveRotorWash()
	if IsValid(self.Engine.RotorWash.Ent) then
		self.Engine.RotorWash.Ent:Remove()
		self.Engine.RotorWash.Ent = nil
	end
end

--Call it through PhysicsSimulate. It returns the ShadowControl Params @ Warkanum
function ENT:EnginePhysicsSimulate( phys, deltatime )
	if self.AIControlledEngine then
		return self:EnginePhysicsSimulateAI( phys, deltatime)
	end
	if (self.Engine.Active) and (deltatime > 0.01) then
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
		
		--Turbo Checking
		local fwdacc = self.Engine.Simulated.fwdaccspeed
		local fwdspeed = self.Engine.Phys.Speed

		if (self.Engine.Phys.TurboSpeed > 1) then
			fwdacc = self.Engine.Simulated.trbaccspeed
			fwdspeed = self.Engine.Phys.Speed + self.Engine.Phys.TurboSpeed
		end
		--Approaches on moving directions
		self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,fwdspeed,fwdacc)
		self.Engine.Simulated.side = math.Approach(self.Engine.Simulated.side,self.Engine.Phys.StrafeSpeed,self.Engine.Simulated.sideaccspeed)
		self.Engine.Simulated.ud = math.Approach(self.Engine.Simulated.ud,self.Engine.Phys.UpDownSpeed,self.Engine.Simulated.udaccspeed)
		
		--Slow down very fast, like breaks.
		if (self.Engine.Phys.Speed < 0) and (self.Engine.Simulated.fwd > 0) then 
			self.Engine.Simulated.fwd = math.Approach(self.Engine.Simulated.fwd,0,(fwdacc*math.abs(self.Engine.Phys.Speed))/2)
		end
		
		--Mouse and control angles
		if self.Engine.MouseSteer then
			if (self:GetClientThirdPersonView(self.Passengers[0]) == 2) then --Locked FP
				if IsValid(self.Passengers[0]) then
					--self.Passengers[0]:SetEyeAngles(arot)
					local mouseX = 0
					local mouseY = 0
					-- self.Passengers[0]:GetCurrentCommand():MouseX() --Bombs garrysmod and lately returns an error. I use a workaround.
					if AVehicles.Vehicle.PlayersMouseData and AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]] then
						mouseX = AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MouseX or 0
						mouseY = AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MouseY or 0
					end
					local ExtraRoll = math.Clamp(mouseX*-1,-1*self.Engine.Simulated.autorollmaxdeg,self.Engine.Simulated.autorollmaxdeg) --Got this from F302 code, thanks
					local mul = math.Clamp((vvel:Length()/self.Engine.Simulated.autorollspeedmax),0,1)
					
					self.Engine.Simulated.ang.y = (arot.y + math.Clamp(mouseX*-1,-100,100))
					self.Engine.Simulated.ang.p = (arot.p + math.Clamp(mouseY,-100,100))
					self.Engine.Simulated.ang.r = (math.ApproachAngle(self.Engine.Simulated.ang.r,(ExtraRoll*mul*-1)+self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r))
					--self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
				else
					self.Engine.Simulated.ang = arot --If we don't have a pilot, just stay at that rotation
				end
			elseif (self:GetClientThirdPersonView(self.Passengers[0]) == 0) then --Third Person
				if IsValid(self.Passengers[0]) and !self.Engine.Simulated.mousefreelook then
					local aim = self.Passengers[0]:GetAimVector()
					local ang = Angle(0,0,0)
					if (GetConVarNumber("avehicles_cvar_newmovesystem") >= 1) then
						local pang = (AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MoveAngle  or Angle(0,0,0)) + Angle(0, -90, 0)
						ang = AVehicles.Tools.NormalizeAngles(self:GetAngles() +  pang + Angle(self.AimViewAnjustment * (-1)))
					else
						ang = AVehicles.Tools.NormalizeAngles(aim:Angle() + Angle(self.AimViewAnjustment * (-1)))
					end
					local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(vpos + aim).y)),-1*self.Engine.Simulated.autorollmaxdeg,self.Engine.Simulated.autorollmaxdeg) --Got this from F302 code, thanks
					local mul = math.Clamp((vvel:Length()/self.Engine.Simulated.autorollspeedmax),0,1)
			
					self.Engine.Simulated.ang.y = math.NormalizeAngle(ang.y)
					self.Engine.Simulated.ang.p = math.NormalizeAngle(ang.p)
					self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,(ExtraRoll*mul*-1)+self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
				else
					self.Engine.Simulated.ang = arot --If we don't have a pilot, just stay at that rotation
				end
			else --Free FP and TP
				if IsValid(self.Passengers[0]) and !self.Engine.Simulated.mousefreelook then
					local aim = self.Passengers[0]:GetAimVector()
					local ang = Angle(0,0,0)
					if (GetConVarNumber("avehicles_cvar_newmovesystem") >= 1) then
						local pang = (AVehicles.Vehicle.PlayersMouseData[self.Passengers[0]].MoveAngle  or Angle(0,0,0)) + Angle(0, -90, 0)
						ang = AVehicles.Tools.NormalizeAngles(self:GetAngles() +  pang)
					else
						ang = AVehicles.Tools.NormalizeAngles(aim:Angle())
					end
					
					local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(vpos + aim).y)),-1*self.Engine.Simulated.autorollmaxdeg,self.Engine.Simulated.autorollmaxdeg) --Got this from F302 code, thanks
					local mul = math.Clamp((vvel:Length()/self.Engine.Simulated.autorollspeedmax),0,1)
			
					self.Engine.Simulated.ang.y = math.NormalizeAngle(ang.y)
					self.Engine.Simulated.ang.p = math.NormalizeAngle(ang.p)
					self.Engine.Simulated.ang.r = math.ApproachAngle(self.Engine.Simulated.ang.r,(ExtraRoll*mul*-1)+self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r)
				else
					self.Engine.Simulated.ang = arot --If we don't have a pilot, just stay at that rotation
				end
			end
		else

			self.Engine.Simulated.ang.r = math.NormalizeAngle(math.ApproachAngle(self.Engine.Simulated.ang.r,self.Engine.Phys.Roll,self.Engine.Simulated.angmovespeed.r))
			self.Engine.Simulated.ang.p = math.NormalizeAngle(math.ApproachAngle(self.Engine.Simulated.ang.p,self.Engine.Phys.Pitch,self.Engine.Simulated.angmovespeed.p))
			self.Engine.Simulated.ang.y = math.NormalizeAngle(math.ApproachAngle(self.Engine.Simulated.ang.y,self.Engine.Phys.Yaw,self.Engine.Simulated.angmovespeed.y))
		end
		
	
		local FlightPhys ={
			secondstoarrive	= 1;
			pos = vpos + (fwd*self.Engine.Simulated.fwd) + (side*self.Engine.Simulated.side) + (up*self.Engine.Simulated.ud);
			maxangular		= 8000; --10000
			maxangulardamp	= 8000; --1000
			maxspeed			= 12000; --1000000
			maxspeeddamp		= 8000; --500000
			dampfactor		= 0.9;
			teleportdistance	= 0;--5000
		}
		--Update angel depending on the controller.
		if self.Engine.MouseSteer then
			FlightPhys.angle = AVehicles.Tools.NormalizeAngles(self.Engine.Simulated.ang)
		else
			FlightPhys.angle = self:LocalToWorldAngles(self.Engine.Simulated.ang)
		end
			
		--Check speeds and check if we can hover and if we are in air.
		if !self.Engine.Simulated.hovers then
			if !self:OnGround() then
				if ((self.Engine.Simulated.fwd<self.Engine.Simulated.speedtohover) and (self.Engine.Simulated.fwd>self.Engine.Simulated.speedtohover*-1)) 
				and ((self.Engine.Simulated.side<self.Engine.Simulated.speedtohover) and (self.Engine.Simulated.side>self.Engine.Simulated.speedtohover*-1))
				and ((self.Engine.Simulated.ud<self.Engine.Simulated.speedtohover) and (self.Engine.Simulated.ud>self.Engine.Simulated.speedtohover*-1))	then
					return false --Bail and don't update.
				end
			end
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


--Physics Simulation used for AI engine @ Warkanum
function ENT:EnginePhysicsSimulateAI( phys, deltatime )

end

-------------------Simulate Our custom engine here. This must be called very fast every frame @ Warkanum
function ENT:EngineCustomPhysics(thePhys)
	if self.EngineUseCustom then
		local physics = thePhys or self.Entity:GetPhysicsObject()
		if (self.Engine.Active) then
			local ZAxis = Vector(0,0,1)
			local up, right
			local forward = self.Entity:GetForward() * self.Engine.Phys.Speed
			local drag = physics:GetVelocity() * self.Engine.Phys.DragRate
			local turbo = self.Entity:GetForward() * self.Engine.Phys.TurboSpeed
			local angdrag = physics:GetAngleVelocity() * -self.Engine.Phys.AngleDragRate
			
			if (self.Engine.Phys.FixedZAxis) then
				up = ZAxis * self.Engine.Phys.UpDownSpeed
				right = ( self.Entity:GetForward():Cross(ZAxis):GetNormalized() ) * self.Engine.Phys.StrafeSpeed
			else
				up = self.Entity:GetUp() * self.Engine.Phys.UpDownSpeed
				right = self.Entity:GetRight() * self.Engine.Phys.StrafeSpeed
			end
			physics:SetVelocity(drag + forward + up + right + turbo)
			physics:AddAngleVelocity(angdrag + Angle(self.Engine.Phys.Roll,self.Engine.Phys.Pitch,self.Engine.Phys.Yaw))
			
		else	
			self.Engine.Phys.Roll			= 0
			self.Engine.Phys.Pitch			= 0
			self.Engine.Phys.Yaw			= 0
			self.Engine.Phys.UpDownSpeed	= 0
			self.Engine.Phys.StrafeSpeed	= 0
			self.Engine.Phys.Speed			= 0
			self.Engine.Phys.TurboSpeed		= 0

		end

	end
end

-------------------Check some engine operational stuff here. @ Warkanum
-- Override in child entities if you want to change something.
function ENT:EngineOperationChecks()
	local physics = self.Entity:GetPhysicsObject()
	if physics and physics:IsValid() then
		--Wake physics on engine start!
		if (self.Engine.Active) then
			physics:Wake()
		end
		
		--Check fuel system
		self:FuelUpdateValues() --Workaround for the strange error I got.
		if self.Engine.Active and self.FuelSystem then
			--Condition on engine operations.
			if self.FuelSystem.consumetick < CurTime() then
				self.FuelSystem.consumetick = CurTime() + self.FuelSystem.consumeticktime
				local fuel = self:FuelConsume(self.FuelSystem.usagepertick)
				if !self.Engine.Simulated.hovers or self:OnGround() then
					self.FuelSystem.consumemul = 0 --if we don't hove, don't take fuel on idle
				end
				if (self.Engine.Phys.TurboSpeed >= 0) then
					self.FuelSystem.consumemul = 2 +  (10*(self.Engine.Phys.TurboSpeed / self.CustomEngine.TurboSpeed))
				elseif (self.Engine.Phys.Speed >= 0) then
					self.FuelSystem.consumemul = 2
				elseif (self.Engine.Phys.UpDownSpeed >= 0) or (self.Engine.Phys.StrafeSpeed >= 0) then
					self.FuelSystem.consumemul = 1.5
				end
				if fuel == 0 then
					self:EngineOff()
				elseif fuel == 1 then
					local DIV = 2
					self.Engine.Phys.TurboSpeed = 0
					self.Engine.Phys.UpDownSpeed	= self.Engine.Phys.UpDownSpeed / DIV
					self.Engine.Phys.StrafeSpeed	= self.Engine.Phys.StrafeSpeed / DIV
					self.Engine.Phys.Speed = self.Engine.Phys.Speed / DIV
				elseif fuel == 2 then
					--We have enough fuel, continue operations
				end
				
			end
		end
		
		--Water Check, then hamper mobility.
		self.Engine.Phys.WaterDepth	= self:WaterLevel()
		if self.Engine.Phys.WaterDepth > 0 then
			if self.Engine.Phys.WaterDepth > 2 then
				self.Engine.Phys.TurboSpeed = 0
				--self.Engine.Phys.Speed = (self.Engine.Phys.Speed * 0.85)
				self.Engine.Phys.UpDownSpeed = (self.Engine.Phys.UpDownSpeed * 0.6)
				self.Engine.Phys.StrafeSpeed = (self.Engine.Phys.StrafeSpeed * 0.6)
			end
			if self.Engine.Phys.WaterDepth >= 3 then
				self.Engine.Phys.Submerged= true
			end
		else
			self.Engine.Phys.Submerged		= false
		end
			
		--Engine gagets check and update
		if (self.Engine.Active) then --When Engine is active:
			if not IsValid(self.Engine.RotorWash.Ent) then
				self:EngineAddRotorWash()
			end
			
			if self.EngineUseCustom and self.Engine.CustomEngine.GravitySysEnabled then
				self:EngineCustomGravityPhysics()
			end
		else --When Engine is not active:
			if IsValid(self.Engine.RotorWash.Ent) then
				self:EngineRemoveRotorWash()
			end
			
			if self.EngineUseCustom and self.Engine.CustomEngine.GravitySysEnabled then
				self:EngineCustomGravityPhysics()
			end
		end

	end
end

---------------------Custom Engine -Mouse aim 	 @ Warkanum
---Still have trouble with this, I must find a way to change this whole function to something better. Use pods makes this harder.
--I found an alternative using physics simulate, see above.
--Depircated but will still be use for older type vehicles that uses the custom engine and not the phys simulate engine
function ENT:EngineCustomMouse()  
	if self.Engine.MouseSteer then
		if IsValid(self.Passengers[0]) and not self.Engine.Simulated.mousefreelook then
			local DistA = 0
			local DistB = 0
			local PitchDist = 0
			local YawDist = 0
			local MaxP = self.CustomEngine_MouseSpecial_MaxPitch or 10
			local MinP = self.CustomEngine_MouseSpecial_MinPitch or -10
			local MinY  = self.CustomEngine_MouseSpecial_MinYaw or -10
			local MaxY  = self.CustomEngine_MouseSpecial_MaxYaw or 10
			local CanYaw = self.CustomEngine_MouseSpecial_CanYaw or true
			local CanPitch = self.CustomEngine_MouseSpecial_CanPitch or true
			
			local PlyRel = self.Entity:GetPos() + self.Passengers[0]:GetAimVector() * 300
			local view = self:GetClientThirdPersonView(self.Passengers[0])
			local FirstPersonMul = 1
			local FirstPersonOMul = self.CustomEngine_MouseSpecial_FirstPerson_OMul or 1
			------View Specific Calculations
			if view == 1 then
				FirstPersonMul = 1
			elseif view != 1 then
				FirstPersonMul = self.CustomEngine_MouseSpecial_FirstPerson_Mul or 1
			end
			MaxP = MaxP * FirstPersonOMul
			MinP = MinP * FirstPersonOMul
			MinY = MinY * FirstPersonOMul
			MaxY = MaxY * FirstPersonOMul

			--------------------Pitch Calculations
			if CanPitch then
				DistA = PlyRel:Distance( self.Entity:GetPos() + self.Entity:GetUp() * 300 )
				DistB = PlyRel:Distance( self.Entity:GetPos() + self.Entity:GetUp() * -300 )
				PitchDist = (DistA - DistB)
				--Pitch Clamping
				if PitchDist < MinP then
					self.Engine.Phys.Pitch = (math.Clamp(PitchDist - MinP, -220, 0) * self.CustomEngine_MousePitchRate) * FirstPersonMul
				elseif PitchDist > MaxP then
					self.Engine.Phys.Pitch = (math.Clamp(PitchDist - MaxP, 0, 220) * self.CustomEngine_MousePitchRate) * FirstPersonMul
				end
			end
			--------------------Yaw calculations
			if CanYaw then
				DistA = PlyRel:Distance( self.Entity:GetPos() + self.Entity:GetRight() * 300 )
				DistB = PlyRel:Distance( self.Entity:GetPos() + self.Entity:GetRight() * -300 )
				YawDist = (DistA - DistB) 
				--Yaw Clamping
				if YawDist < MinY then
					self.Engine.Phys.Yaw = (math.Clamp(YawDist - MinY, -200, 0) * self.CustomEngine_MouseYawRate) * FirstPersonMul
				elseif YawDist > MaxY then
					self.Engine.Phys.Yaw = (math.Clamp(YawDist - MaxY, 0, 200) * self.CustomEngine_MouseYawRate) * FirstPersonMul
				end
			end
			
		end
	end
end


--Toggels the custom engines gravity when the engine is on and the gravity system is enabled @ Warkanum
function ENT:EngineCustomGravityPhysics()
	local physics = self.Entity:GetPhysicsObject()
	if self.Engine.Active then
		physics:EnableGravity(false)
		physics:EnableDrag(false)
		self.Engine.CustomEngine.GravityEnabled = false
	else
		physics:EnableGravity(true)
		physics:EnableDrag(true)
		self.Engine.CustomEngine.GravityEnabled = true
	end
end

--I have removed the custom gravity on attached entities. I think that functions was shit. Don't know why I created them in the first place. @ Warkanum

function ENT:EngineOnRemove()

end

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

---------------------------------------------------------------------------ServerSide events---------------------------------------------------------
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:EventsInitialize()
	self.BaseTimers = {}
	self.BaseTimers.EngineTime = 1
	self.BaseTimers.MouseTime = 1
	self.BaseTimers.NextSeat = 1
	self.BaseTimers.SpecialSeatCount = 1
	self.BaseTimers.NextWep = 1
	self.BaseTimers.PreWep = 1

end


function ENT:EventsRun()

	if IsValid(self.Passengers[0]) then
		--Driver only events
		--Toggel engine on and off
		
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"engine") then
			if self.BaseTimers.EngineTime < CurTime() then
				self.BaseTimers.EngineTime = CurTime() + 0.8
				
				if self:EngineIsActive() then 
					self:EngineOff()
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Engines offline!")					
					
				else
					self:EngineOn()
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Engines online!")
				end
				
			end
		end
		
		--Toggel mouse aim control
		if  AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"mouseaim") then
			if self.BaseTimers.MouseTime < CurTime() then
				self.BaseTimers.MouseTime = CurTime() + 0.8
				
				if self.Engine.MouseSteer then 
					self.Engine.MouseSteer = false
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Mouse control off!")
				else
					self.Engine.MouseSteer = true
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Mouse control on!")
				end
			end
		end
		
		--Mouse free look
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "freelook") then
			self.Engine.Simulated.mousefreelook = true
		else
			self.Engine.Simulated.mousefreelook = false
		end
		/*
		Pure sample code:::

		--Engine Key binds
		--Speedup
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "SpeedUp") then
			self.Engine.Phys.Speed = math.Clamp(self.Engine.Phys.Speed + self.CustomEngine.AccelMax, -1*self.CustomEngine.BackwardMaxSpeed, self.CustomEngine.ForwardMaxSpeed)
			self.Engine.Phys.TurboSpeed = 0
		end
		--SpeedDown
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "SpeedDown") then
			if self.Engine.Phys.Speed > 50 then --Make the vehicle stop when reverse pressed, then reverse.
				self.Engine.Phys.Speed = 20
			elseif self.Engine.Phys.Speed > 25 then
				self.Engine.Phys.Speed = 5
			elseif self.Engine.Phys.Speed > 6 then
				self.Engine.Phys.Speed = 0
			elseif self.Engine.Phys.Speed <= 0 then
				self.Engine.Phys.Speed = math.Clamp(self.Engine.Phys.Speed - self.CustomEngine.DecelMax, -self.CustomEngine.BackwardMaxSpeed, self.CustomEngine.ForwardMaxSpeed)	
			end
			self.Engine.Phys.TurboSpeed = 0
		end

		
		--Angles Yaw
		if AVehicles.Keys.Active(self.Passengers[0],self.Keyschema, "YawRight") then
			self.Engine.Phys.Yaw = math.Clamp(self.Engine.Phys.Yaw - self.CustomEngine.AngleAccel, self.CustomEngine.YawSpeed*-1, 0)
			
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "YawLeft") then
			self.Engine.Phys.Yaw = math.Clamp(self.Engine.Phys.Yaw + self.CustomEngine.AngleAccel, 0, self.CustomEngine.YawSpeed)
		else
			self.Engine.Phys.Yaw = 0
		end
			
		--Angles Pitch
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "PitchUp") then
			self.Engine.Phys.Pitch = math.Clamp(self.Engine.Phys.Pitch + self.CustomEngine.AngleAccel, 0, self.CustomEngine.PitchSpeed)
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "PitchDown") then
			self.Engine.Phys.Pitch = math.Clamp(self.Engine.Phys.Pitch - self.CustomEngine.AngleAccel, self.CustomEngine.PitchSpeed*-1, 0)
		else
			self.Engine.Phys.Pitch = 0
		end 
		
		--Angles Roll
		if AVehicles.Keys.Active(self.Passengers[0],self.Keyschema, "RollRight") then
			self.Engine.Phys.Roll = math.Clamp(self.Engine.Phys.Roll + self.CustomEngine.AngleAccel, 0, self.CustomEngine.RollSpeed)
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"RollLeft") then
			self.Engine.Phys.Roll = math.Clamp(self.Engine.Phys.Roll - self.CustomEngine.AngleAccel, self.CustomEngine.RollSpeed*-1, 0)
		else
			self.Engine.Phys.Roll = 0
		end
		
		--Turbo Speed
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"turbo") then
			self.Engine.Phys.TurboSpeed = math.Clamp(self.Engine.Phys.TurboSpeed + self.CustomEngine.TurboAccel, 0, self.CustomEngine.TurboSpeed)
		end

		--Movement Up/Down
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"MoveUp")  then
			self.Engine.Phys.UpDownSpeed = math.Clamp(self.Engine.Phys.UpDownSpeed + self.CustomEngine.MoveAccel, 0, self.CustomEngine.SideUDSpeed)
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"MoveDown")  then
			self.Engine.Phys.UpDownSpeed = math.Clamp(self.Engine.Phys.UpDownSpeed - self.CustomEngine.MoveAccel, self.CustomEngine.SideUDSpeed*-1, 0)
		else
			self.Engine.Phys.UpDownSpeed = 0
		end 
		
		--Movement Left/Right 
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"MoveRight") then
			self.Engine.Phys.StrafeSpeed = math.Clamp(self.Engine.Phys.StrafeSpeed + self.CustomEngine.MoveAccel, 0, self.CustomEngine.SideSpeed)
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"MoveLeft")  then
			self.Engine.Phys.StrafeSpeed = math.Clamp(self.Engine.Phys.StrafeSpeed - self.CustomEngine.MoveAccel, self.CustomEngine.SideSpeed*-1, 0)
		else
			self.Engine.Phys.StrafeSpeed = 0
		end 
		
		
		--Add these events				
		--"Attack", "Attack2"
		*/
	end
	--Event for all players
	for i=0, self.PassengerCount, 1 do
		if self:PlayerCheck(self.Passengers[i]) then
		
		--Eject the players if they press the eject key.
		if self:CheckIfPlyInPod(self.Passengers[i]) then
			timer.Simple(0.3, function() --This timer fixes the problem of eject key it on enter if eject key is bind to e
				if IsValid(self) and IsValid(self.Passengers[i]) then
					if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"eject") then
						self:Eject(self.Passengers[i])
					end
				end
			end)
		end
		
		--ChangeSeat
		if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"changeseat") then
			if self.BaseTimers.NextSeat < CurTime() then
				self.BaseTimers.NextSeat = CurTime() + 0.8
				
				if self.BaseTimers.SpecialSeatCount > 16 then --Dubble tap, means go to pilot.
					self:ChangeToPod(self.Passengers[i], 0) --if there is a driver, you will be ejected.
				else
					self:ChangeToNextPod(self.Passengers[i])
				end
				self.BaseTimers.SpecialSeatCount = 0
			end
			self.BaseTimers.SpecialSeatCount = self.BaseTimers.SpecialSeatCount + 1
		end
		
		--Weapon System
		--Select Next weapon
		if  AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"nextweapon") then
			if self.BaseTimers.NextWep < CurTime() then
				self.BaseTimers.NextWep = CurTime() + 0.3
				self:NextWeapon(i,true)
				self.Passengers[i]:PrintMessage( HUD_PRINTCENTER, string.format("Selected device: %s", self:GetSelectedWeapon(i)))
			end
		end
		
		--Select Prev weapon
		if  AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"prevweapon") then
			if self.BaseTimers.PreWep < CurTime() then
				self.BaseTimers.PreWep = CurTime() + 0.3
				self:NextWeapon(i,false)
				self.Passengers[i]:PrintMessage( HUD_PRINTCENTER, string.format("Selected device: %s", self:GetSelectedWeapon(i)))
			end
		end
		
		--Fire Active Weapons
		if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"fire") then
			self:FireActiveWeapon(i)
		end
		
		--AltFire Active Weapons
		if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"altfire") then
			self:AltFireActiveWeapon(i)
		end
			
		/*
		Pure Sample Code, the old code.
		
		
			--Eject the players if they press the eject key.
			if self:CheckIfPlyInPod(self.Passengers[i]) then
				timer.Simple(0.5, function() --This timer fixes the problem of eject key it on enter if eject key is bind to e
					if IsValid(self) and IsValid(self.Passengers[i]) then
						if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"eject") then
							self:Eject(self.Passengers[i])
						end
					end
				end)
			end
			
			if AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"changeseat") then
				timer.Simple(0.5, function()
					if IsValid(self) and IsValid(self.Passengers[i]) then
						self:ChangeToNextPod(self.Passengers[i])		
					end
				end)
			end
		*/
		end
	end
	
end

function ENT:EventsOnRemove()
	
end



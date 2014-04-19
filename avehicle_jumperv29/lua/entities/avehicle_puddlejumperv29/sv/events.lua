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
	self.BaseClass.EventsInitialize(self)  --Need this to init baseclass events since we are running self.BaseClass.EventsRun(self)
	self.Timers = {}
	self.Timers.Lights = 0
	self.Timers.Pods = 0
	self.Timers.Door = 0
	self.Timers.DHD = 0
end

function ENT:EventsRun()
	self.BaseClass.EventsRun(self) --the defaults is done in the baseclass. Like engine start and mouse etc. But you can ignore this and do your own. @ Warkanum
	
	if IsValid(self.Passengers[0]) then
		--Driver only events
	
		--Engine
		--Forward, Backward
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "SpeedUp") then
			if (self.JumperPods) then
				self.Engine.Phys.Speed = math.Clamp((self.Engine.Phys.Speed + self.CustomEngine.AccelMax*5), -self.CustomEngine.BackwardMaxSpeed, self.CustomEngine.ForwardMaxSpeed)
			else
				self.Engine.Phys.Speed = math.Clamp(self.Engine.Phys.Speed + self.CustomEngine.AccelMax, -self.CustomEngine.BackwardMaxSpeed, self.CustomEngine.ForwardMaxSpeed)
			end	
			if (self.Engine.Phys.Speed >= self.CustomEngine.ForwardMaxSpeed-10) then --Kick in the turbo
				if (self.JumperPods) then
					self.Engine.Phys.TurboSpeed = math.Clamp(self.Engine.Phys.TurboSpeed + (self.CustomEngine.TurboAccel*2), 0, self.CustomEngine.TurboSpeed)
				end
			end
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "SpeedDown") then
			self.Engine.Phys.Speed = math.Clamp(self.Engine.Phys.Speed - self.CustomEngine.DecelMax, -self.CustomEngine.BackwardMaxSpeed, self.CustomEngine.ForwardMaxSpeed)
			self.Engine.Phys.TurboSpeed = 0
		else
			--if (math.abs(self.Engine.Phys.Speed) < 200) then
				self.Engine.Phys.Speed = 0
				self.Engine.Phys.TurboSpeed = 0
			--end
		end
		
		
		--Angles Yaw
		if AVehicles.Keys.Active(self.Passengers[0],self.Keyschema, "YawRight") then
			self.Engine.Phys.Yaw = -self.CustomEngine.YawSpeed
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "YawLeft") then
			self.Engine.Phys.Yaw = self.CustomEngine.YawSpeed
		else
			self.Engine.Phys.Yaw = 0
		end
			
		--Angles Pitch
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "PitchUp") then
			self.Engine.Phys.Pitch = self.CustomEngine.PitchSpeed
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema, "PitchDown") then
			self.Engine.Phys.Pitch = -self.CustomEngine.PitchSpeed
		else
			self.Engine.Phys.Pitch = 0
		end 
		
		--Angles Roll
		if AVehicles.Keys.Active(self.Passengers[0],self.Keyschema, "RollRight") then
			self.Engine.Phys.Roll = self.CustomEngine.RollSpeed
		elseif AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"RollLeft") then
			self.Engine.Phys.Roll = -self.CustomEngine.RollSpeed
		else
			self.Engine.Phys.Roll = 0
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
			
		
		--Toggel  Lights
		if  AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"Lights") then
			if self.Timers.Lights < CurTime() then
				self.Timers.Lights = CurTime() + 0.5
				if not self.Cloaked then
					self:LightsToggel()
				end
			end
		end

		
		--Toggel Pods
		if AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"pods") then
			if self.Timers.Pods < CurTime() then
				self.Timers.Pods = CurTime() + 1.0
				if self.JumperPods then
					self:SetPods(false)
				else
					if self:EngineIsActive() then
						self:SetPods(true)
					end
				end
			end
		end
		
		
		--Toggel  Door
		if  AVehicles.Keys.Active(self.Passengers[0], self.Keyschema,"door") then
			if self.Timers.Door < CurTime() then
				self.Timers.Door = CurTime() + 1.0
				if self.BaseOpen then
					self:SetDoor(false)
				else
					self:SetDoor(true)
				end
			end
		end
		


	end
	--Event for all players
	for i=0, self.PassengerCount, 1 do
		if self:PlayerCheck(self.Passengers[i]) then
		
			--Open DHD
			if  AVehicles.Keys.Active(self.Passengers[i], self.Keyschema,"dhd") then
				if self.Timers.DHD < CurTime() then
					self.Timers.DHD = CurTime() + 0.5
					self:OpenDHD(self.Passengers[i])
				end
			end
			
		end --^
		
	end
	
	
end

function ENT:EventsOnRemove()
	
end


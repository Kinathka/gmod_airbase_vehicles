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
	self.BaseClass.EventsInitialize(self) --Need this to init baseclass events since we are running self.BaseClass.EventsRun(self)
	--Flags used with toggel timers
	self.Timers = {}
	self.Timers.GearTime = 1
	self.Timers.DoorTime = 1
	self.Timers.HovermodeTime = 1
	self.Timers.AutoleveloutTime = 1

end


local Routine = AVehicles.Keys.Active --Quick reference

function ENT:EventsRun()
	self.BaseClass.EventsRun(self) --the defaults is done in the baseclass. Like engine start and mouse etc. But you can ignore this and do your own. @ Warkanum
	if IsValid(self.Passengers[0]) then
		--Driver only events

		
		/*
		if Routine(self.Passengers[0], self.Keyschema,"countermeasure") then
		
			if countermeasuresflag then
				countermeasuresflag = false
				self:FlaresDeploy(3, 10.0)
				timer.Simple(10.0, function() 
				if IsValid(self) then
					countermeasuresflag = true
				end
				end)
			end
		end
		*/
		--Movements
		
		--Up, Down
		if Routine(self.Passengers[0], self.Keyschema, "SpeedUp") then
			self.Engine.Phys.Speed = self.CustomEngine.ForwardMaxSpeed
			self.Engine.Phys.TurboSpeed = 0
		elseif Routine(self.Passengers[0], self.Keyschema, "SpeedDown") then
			self.Engine.Phys.Speed = -1*self.CustomEngine.BackwardMaxSpeed
			self.Engine.Phys.TurboSpeed = 0
		else
			self.Engine.Phys.Speed = 0
			self.Engine.Phys.TurboSpeed = 0
		end

		--Angles Yaw
		if Routine(self.Passengers[0],self.Keyschema, "YawRight") then
			self.Engine.Phys.Yaw = self.CustomEngine.YawSpeed*-1
			
		elseif Routine(self.Passengers[0], self.Keyschema, "YawLeft") then
			self.Engine.Phys.Yaw = self.CustomEngine.YawSpeed
		else
			self.Engine.Phys.Yaw = 0
		end
			
		--Angles Pitch
		if Routine(self.Passengers[0], self.Keyschema, "PitchUp") then
			self.Engine.Phys.Pitch = self.CustomEngine.PitchSpeed 
		elseif Routine(self.Passengers[0], self.Keyschema, "PitchDown") then
			self.Engine.Phys.Pitch = self.CustomEngine.PitchSpeed*-1
		else
			self.Engine.Phys.Pitch = 0
		end 
		
		--Angles Roll
		if Routine(self.Passengers[0],self.Keyschema, "RollRight") then
			self.Engine.Phys.Roll = self.CustomEngine.RollSpeed
		elseif Routine(self.Passengers[0], self.Keyschema,"RollLeft") then
			self.Engine.Phys.Roll = self.CustomEngine.RollSpeed*-1
		else
			self.Engine.Phys.Roll = 0
		end
			
			
		
		--ToggelGear up down
		if  Routine(self.Passengers[0], self.Keyschema,"gear") then
			if self.Timers.GearTime < CurTime() then
				self.Timers.GearTime = CurTime() + 1.0
				if self.geardown then 
					self:SetGear(true)
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Gear is up!")
				else
					self:SetGear(false)
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Gear is down!")
				end
			end
		end

		--Heli Special events/code
		if  Routine(self.Passengers[0], self.Keyschema,"hover") then
			if self.Timers.HovermodeTime < CurTime() then
				self.Timers.HovermodeTime = CurTime() + 2.0
				if self.RotorEngine.hovermode then
					self.RotorEngine.hovermode = false
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Hover mode off!")
				else
					self.RotorEngine.hovermode = true
					self.Flag_autoleveloutflag = true
					self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Hover mode on!")
					
					--Levelout added at flyboy's request. @ Warkanum
					self.RotorEngine.levelout = true
					timer.Simple(2.0, function() 
						if IsValid(self) then
							self.RotorEngine.levelout = false
						end
					end)
				end
				
			end
		end
	
		if Routine(self.Passengers[0], self.Keyschema,"levelout") then
			if self.Timers.AutoleveloutTime < CurTime() then
				self.Timers.AutoleveloutTime = CurTime() + 2.0
				self.RotorEngine.levelout = true
				self.Passengers[0]:PrintMessage( HUD_PRINTCENTER, "Leveling out...")
				
				timer.Simple(2.0, function() 
					if IsValid(self) then
						self.RotorEngine.levelout = false
					end
				end)
				
			end
			
		end
		
	
		
	end
	--Event for all players
	for i=0, self.PassengerCount, 1 do
		if self:PlayerCheck(self.Passengers[i]) then
		 --Heli special code here....
			
		end 
	end
	
end

function ENT:EventsOnRemove()
	
end

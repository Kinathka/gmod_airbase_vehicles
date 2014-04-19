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
----------------------------------------------------Serverside Sound--------------------------------------------------
----------------------------------------------------Doing this serverside is more cpu on the server----------------------
-----------------------Definitions---------------------
ENT.Sounds = ENT.Sounds or {}

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
	if self.Sounds.Enabled  then
		if self.Sound_Flags.EngineSoundPlaying then
			self.Sound_Flags.EngineSoundPlaying = false
			self.Sound_Handlers.EngineLoop:Stop()
		end
	end
end 

function ENT:SoundsEnginePitchCall(active)
	if self.Sounds.Enabled and active  then
		local velocity = self.Entity:GetVelocity()
		local pitch = self.Entity:GetVelocity():Length()
		self.Sound_Handlers.EngineLoop:ChangePitch(math.Clamp(60 + pitch/15,60,180), 0.1)
	end
end 


function ENT:SoundsOnRemove()
	if self.Sound_Handlers and self.Sound_Handlers.EngineLoop then self.Sound_Handlers.EngineLoop:Stop() end
	
end
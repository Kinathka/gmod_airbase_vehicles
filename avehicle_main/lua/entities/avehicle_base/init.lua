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
-------------------------------------------------------------- THE HEADER ----------------------------------------------------------------------------
-----------Include--------
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
--Serverside Component files include
include("sv/damage_system.lua")
include("sv/engine.lua")
include("sv/lib.lua")
include("sv/pod.lua")
include("sv/events.lua")
include("sv/sounds.lua")
include("sv/gadgets.lua")
include("sv/fuel.lua")
include("sv/weapons.lua")
-----------------------Definitions---------------------

ENT.CDSIgnore = true -- CDS 
ENT.hasdamagecase = true -- GCombat

---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
function ENT:Initialize()
	--self.NoDuplicator = true		--Disable the duplicator for now.
	--self.NoToolGun = true --Disable toolcan completly
	--self.NoPhysicsPickup = true --Disable physicsgun pickup for this entity
	--self.OnlySpecialToolGun = true --Disable Toolgun --only allow dev_link, wire and admins
	self.restrictUse = self.Restrict.Use --Disallow use on entity. This does not include use on the seats
	self.BeingDuplicated = false
	self.AVehicle_Creator = nil
	
	/*
	self.Phys = self.Entity:GetPhysicsObject()
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(1000)
	end
	*/
	
	self.Entity:SetUseType(SIMPLE_USE)
	self.AimViewAnjustment = self.ThirdPersonViewAngleAdjust or Angle(0,0,0)
	self.ClientInfoTick = 0
	self.ClientInfoTickTime = 0.5
	self:PodsInitialize()
	self:DamageInitialize()
	self:EngineInitialize()
	self:FuelInitialize()
	self:EventsInitialize()
	self:SoundsInitialize()
	self:GadgetsInitialize()
	--self:WeaponsInitialize() If you want weapons. Run the in your entities ENT:Initialize()
	self:WeaponsInitialize() --setup weapon system

	--Setup some wire stuff.
	self:WireCreateSpecialOutputs(
		{ "ActiveWeapons", "Weapons", "Fires", "PodAims", "FuelLeft", "Health" }, 
		{ "TABLE", "TABLE", "TABLE", "TABLE", "NORMAL", "NORMAL"},
		{ "Output Selected Weapon for pods", "List of Weapons for pods", "On fire for pods", "Aim Vectors for each pod.", "Fuel Left", "Hull Health"}
	)
	
	self:WireCreateSpecialInputs({"Engine"}, {"NORMAL"}, {"Toggel the engine!"})
	
	return true
end


--------------------Need to find out how to make the duplicator not copy my constraints and entities and let me do it.
--if ( Ent.OnEntityCopyTableFinish ) then Ent:OnEntityCopyTableFinish( Tab ) end
--if ( Ent.PostEntityCopy ) then Ent:PostEntityCopy() end
--if ( Ent.PreEntityCopy ) then Ent:PreEntityCopy() end


/*
--Please put this in the child entities, else it won't be called!
function ENT:PhysicsSimulate(phys, deltatime)
	if (!self.EngineUseCustom) then
		if IsValid(self.Entity) then
			if (self.Engine) then --Check if the engine table exists.
				return self:EnginePhysicsSimulate(phys, deltatime)	
			end
		end
	end
end
*/

--Please remember to always call this after spawning this object.
function ENT:PostSpawn()
	self:PodsUpdate() --Update the pods, collisions etc.
	return true
end

function ENT:Think() --The master think function
	if IsValid(self.Entity) then
	    self:EventsRun()
		self:EngineOperationChecks() --Attach effects and check waterlevel etc.
		if (self.EngineUseCustom) then
			self:EngineCustomMouse()
		end
		--if self:PlayerCheck(self.Passengers[0]) then --Check if we have a driver
			--self.Engine.LastPilotSense = CurTime()
	
		--else

		--end
		self:EjectDead() --Eject the Dead players

		for i=0, self.PassengerCount, 1 do	--This function is very important, this checks if a player exited the pod, then runs the eject code for that player.
			--Check what players is in their pods and run the eject command if they are not
			if not self:CheckIfPlyInPod(self.Passengers[i]) then
				self:Eject(self.Passengers[i])
			end	
			
			--Draw lazers if toggled
			if self.Passengers[i] and IsValid(self.Passengers[i]) then
				if self.AvTargetLazersDraw and self.AvTargetLazersDraw[i] then
					self:TargetLazer(i, true, self:CalcAimVectors(self.Passengers[i]))
				end
			else
				if self.AvTargetLazersDraw and self.AvTargetLazersDraw[i] then
					self:TargetLazer(i, false, Vector(0,0,0))
				end
			end
		end
	
		--We don't really need to update info that fast...
		if self.ClientInfoTick < CurTime() then
			self.ClientInfoTick = CurTime() + self.ClientInfoTickTime
			self:SetStatus()
			
			--This normally refresh every minutes or more. Not really time senstive.
			if self.AvWeapons_Loaded and self.AvWeaponsAutoRefreshTick < CurTime() then
				self.AvWeaponsAutoRefreshTick = CurTime() +  self.AvWeaponsAutoRefreshTime
				self:HardpointsClearWeaponStatus()
				self:WeaponsSendNamesToClient()
				self:WeaponsSendSelectedToClient()
			end
			
			--Update view limits for pods. @ Warkanum (2010-08-14)
			for i=0, self.PassengerCount, 1 do
				if self:GetClientThirdPersonView(self.Passengers[i]) == 0 then
					self:PodUpdateViewLimits(i, false)
				else
					self:PodUpdateViewLimits(i, true)
				end
			end
			
		end
	
		--This is the function I talked about. I would prefer you override self:DoThink() instead of think
		--because I don't want you to complain about the timings.
		self:DoThink()
	else
		self.Entity:Remove()
	end
	self.Entity:NextThink( CurTime() + 0.05 ) 
	return true
end


function ENT:PhysicsUpdate(phys)
	if (self.EngineUseCustom) then
		if IsValid(self.Entity) then
			self:EngineCustomPhysics(phys)
		end
	end
	return true
end

function ENT:DoThink()

end

function ENT:SetStatus()
	--Set the healthfor the client
	local health = self.Damage.Hull / self.DamageSystem.HullMax * 100
	local frv = math.Round(self.FuelSystem.resrv / self.FuelSystem.reservemax * 100)
	local fuel = math.Round(self.FuelSystem.fuel / self.FuelSystem.maxfuel * 100)
	self.Entity:SetNetworkedInt("Damage_Hull",math.Round(health))
	self.Entity:SetNetworkedInt("Fuel_Left",fuel)
	self.Entity:SetNetworkedInt("Fuel_Reserves",frv)
	--Set the engine speed etc, This can be used for hud
	self.Entity:SetNetworkedInt("Engine_Speed",math.Round(self.Engine.Phys.Speed))
	self.Entity:SetNetworkedInt("Engine_TurboSpeed",math.Round(self.Engine.Phys.TurboSpeed)) 
	
	--Set some wire outputs
	self:WireTriggerOutput("FuelLeft", fuel)
	self:WireTriggerOutput("Health", health)
	
	--Calculate the AimVectors of the players.
	local wiretbl = {}
	for k,v in pairs(self.Passengers) do
		if self:PlayerCheck(v) then
			wiretbl[k+1] = self:CalcAimVectors(v)
		end
	end
	self:WireTriggerOutput("PodAims", self.EyeHitPos) --Wire aim vectors of all players.
	
	return true
end

--Wire Inputs trigger. Please, if you use this in any child entities, call this baseclass one too... @ Warkanum
function ENT:TriggerInput( name, value )
	if (name == "Engine") then
		if value > 0 then
			if self:EngineIsActive() then
				self:EngineOff()
			else
				self:EngineOn()
			end
		end
	end
end


function ENT:Use(ply, caller)
	if not self.restrictUse then
		if IsValid(ply) then
			self:GetIn(ply)
		end
	end
	return true
end

function ENT:OnRemove()
	if IsValid(self.Entity) then
		self:DamageOnRemove()
		self:EngineOnRemove()
		self:EventsOnRemove()
		self:SoundsOnRemove()
		self:GadgetsOnRemove()
		self:PodsOnRemove()
		self:FuelOnRemove()
		self:WeaponsOnRemove()
		self.Entity:Remove()		
	end
	return true
end

/* Disabled, See engine.lua in sv folder
function ENT:PhysicsSimulate( phys, deltatime )
	local shadow = self:EnginePhysicsSimulate( phys, deltatime )
	phys:Wake() 
	phys:ComputeShadowControl(shadow)
end
*/


function ENT:OnTakeDamage( dmginfo )
	if not self.Damage.HasExpleded then
		self:DoDamage(dmginfo)
	end
	return true
end

function ENT:PhysicsCollide( data, physobj )
	if self.Damage.Collision.Enabled then
		if self.Engine.Active then
			self:CollisionDetection(data, physobj)
		end
	end
	return true
end


function ENT:UpdateTransmitState(ent)
	return TRANSMIT_ALWAYS 
end

--Pre Teleport Called by hook for stargate. @ Warkanum
function ENT:PreStargateTeleport(entEH, tblEnts, blocked)

end

function ENT:OnEntityCopyTableFinish(Tab)
	if Tab then

	end
	self.BeingDuplicated  = false
end

function ENT:PreEntityCopy()
	self.BeingDuplicated  = true
end

function ENT:PostEntityCopy()
	
end

--if ( Ent.OnEntityCopyTableFinish ) then Ent:OnEntityCopyTableFinish( Tab ) end
--if ( Ent.PostEntityCopy ) then Ent:PostEntityCopy() end
--if ( Ent.PreEntityCopy ) then Ent:PreEntityCopy() end


/* Sample of spawn function
function ENT:SpawnFunction( ply, tr ) 
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle()
	ang.p = 0
	ang.r = 0
	local ent = ents.Create(self.EntityName)
	local z = tr.HitPos.z
	tr.HitPos.z = 0
	local pos = ply:GetPos()
	pos.z = 0
	local dir = tr.HitPos - pos
	if(dir:Length() < 250) then
		dir = dir:GetNormalized()*250
	end
	ent:SetPos(pos + dir + Vector(0,0,z + 90))
	ent:SetAngles(ang)
	ent:SetVar("Owner",ply);
	ent:SetVar("AVehicle_Creator", ply);
	ent:Spawn()
	ent:Activate()
	ent:PostSpawn() --This call is very important
	return ent
end
*/

/* A note the the person that wants to modify this code or use it. (For the entities that inherits avehicle_base)
 this code is based on the avehicle_base entity, is inherits from that entity.
So if you create a function like ENT:Initialize(), please add self.BaseClass.Initialize(self) in that function.
Please remeber the ENT:OnRemove() function and call self.BaseClass.OnRemove(self) in it!
The only exception is with the ENT:Think() function, there you can use ENT:DoThink() instead.
You may override function in the baseclass freely. If I update the base class you must update your stuff too though.
The baseclass entity should be avehicle_base
*/
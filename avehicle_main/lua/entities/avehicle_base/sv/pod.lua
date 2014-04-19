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
local AVEHICLE_POD_DRIVER = 1
local AVEHICLE_POD_PASSENGER = 2


function ENT:PodsInitialize()
	self.PodsEnts = {}
	self.Passengers = {}
	self.PassengersIn = 0
	self.PodsEjectStopEngine = self.CustomEngine.StopOnExit
	self.HasWeaponSeats = AVehicles.Thirdparty.isInstalled("weaponseat")
	
	if self.PassengerCount >= 0 then
		for i=0, self.PassengerCount, 1 do
			self.Passengers[i] = nil
			self:PodSpawn(i)
		end
	end
	
end

function ENT:PodSpawn(i)
	if self.BeingDuplicated then return false end
	local podtype = 0
	if (self.PodDesc[i]) then
		if (self.PodDesc[i].Type) then
			podtype = self.PodDesc[i].Type
		end
	end
	
	local e = ents.Create( "avehicle_revseat" )
	e.DefaultModel = self.PodDesc[i].Model
	e:SetModel(self.PodDesc[i].Model) 
	e:SetPos( self:LocalToWorld(self.PodPositions[i].Position) )
	e:SetAngles(self:GetAngles() + self.PodPositions[i].Angles)
	e:SetNoDraw(not self.PodDesc[i].Visable)
	e:SetName("AVehicle Seat")
	e:PhysicsInit(SOLID_VPHYSICS)
	e:SetMoveType(MOVETYPE_VPHYSICS)
	e:SetSolid(SOLID_NONE)
	e:SetVar("Locked","false")
	e:SetVar("AllowWeapons","false")
	if (i <= 0) then
		e:SetVar("AllowWeapons","false")
	elseif (podtype >= 1) then
		e:SetVar("AllowWeapons","true")
	end
	e:SetVar("AVehiclesNonEnter","true")
	e:SetVar("AVehicles_DuplicatorIgnoreCase","true")
	e:SetVar("NoDuplicator","true")
	e:SetVar("CDSIgnore","true")
	e:SetVar("isAvehiclePod","true")
	e:SetVar("hasdamagecase","true")
	e:SetVar("Vehicle",self)
	e:SetVar("AvehiclePodIndex",i)
	e:SetVar("AvehiclePodType",podtype)
	e:SetVar("NoDuplicator",true) --We never want copies of this seat. Vehicle must spawn its own seats.
	e:SetVar("NoPhysicsPickup",true) --We are not allowed to move the vehicle seats when they are directly installed
	
	e.IgnoreView = true			--This is used to make shure we don't view our own entities
	--Gcombat Case
	e.gcbt_breakactions = function(damage, pierce)
		--Do nothing
	end
	e:Spawn()
	e:Activate()
	if (self.PodDesc[i].HidePlayer) then
		e:SetVar("HidePlayerModel",true)
	end
	self.PodsEnts[i] = e
end

--Update the pods to the vehicles and updates some of it's properties. @ Warkanum
function ENT:PodsUpdate()
	local podcount = 0
	for i=0, self.PassengerCount, 1 do	
		--for k,v in pairs(self.PodsEnts) do
		if IsValid(self.PodsEnts[i]) then
			local v = self.PodsEnts[i]
			v:DrawShadow(false) --we don't want damn shadows.
			v.CDSIgnore = true -- CDS 
			v.hasdamagecase = true -- GCombat
			--Set some settings
			local collisions = false
			if self.PodDesc[i] and self.PodDesc[i].Collision then
				collisions = true
			end
			local phys = v:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableDrag(false)
				phys:EnableCollisions(collisions)
				phys:EnableGravity(false)
				phys:SetMass(40)
				--phys:AddGameFlag(FVPHYSICS_NO_SELF_COLLISIONS)
			end
			if collisions then 
				--v:SetCollisionGroup(COLLISION_GROUP_WORLD)
			else
				v:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end
			v:SetPos( self:LocalToWorld(self.PodPositions[i].Position))
			v:SetAngles(self:GetAngles() + self.PodPositions[i].Angles)
			if self.ParentAndWeldPods then
				v:SetParent(self.Entity) --Parent Fucks up the stargate teleporting if also welded!
			else
				constraint.Weld(v, self.Entity, 0, 0, 0, true )
			end
			--Set our pod ents for client to access
			podcount = podcount + 1
			self.Entity:SetNetworkedInt("AVehicle_pod_"..tostring(podcount), v:EntIndex())
			
			if self.AvWeapons_Loaded then
				self:WeaponsSendNamesToClient()
				self:WeaponsSendSelectedToClient()
			end
		end
	end
	self.Entity:SetNetworkedInt("AVehicle_pod_count", podcount)
	
end

--Called very often, to check if they pods must limit their view or not. @ Warkanum
function ENT:PodUpdateViewLimits(podindex, limited)
	if self.PodsEnts[podindex] and IsValid(self.PodsEnts[podindex]) then
		local e = self.PodsEnts[podindex]
		if limited then
			if self.PodDesc[podindex].LimitView and self.PodDesc[podindex].LimitView == 0 then
				e:SetKeyValue("limitview", 0)
			else
				e:SetKeyValue("limitview", 1)
			end
		else
			e:SetKeyValue("limitview", 0)
		end
	end
end

--Make the player go to a certain pod.
function ENT:ChangeToPod(ply, index)
	if self:PlayerCheck(ply) then
		local newpos = math.Clamp(index, 0, self.PassengerCount)
		
		if IsValid(self.PodsEnts[index]) and IsValid(self.PodsEnts[index]:GetDriver())
		 and (self.PodsEnts[index]:GetDriver() == ply) then
			return false
		end
		if self:CheckIfPlyInPod(ply) then
			self:Eject(ply)
		end
		if self:GetInAt(ply, newpos) then
			return true
		end
	end
	return false
end

--Make the player go to the next open pod.
function ENT:ChangeToNextPod(ply)
	if self:PlayerCheck(ply) then	
		ply.AvehicleLastUsedSeat = ply.AvehicleLastUsedSeat or 0
		if (ply.AvehicleLastUsedSeat > self.PassengerCount) then
			ply.AvehicleLastUsedSeat = 0
		end

		local chk = 0
		local gotIn = false
		while (!gotIn and (chk <= self.PassengerCount)) do
			if  IsValid(self.PodsEnts[ply.AvehicleLastUsedSeat]) and 
				IsValid(self.PodsEnts[ply.AvehicleLastUsedSeat]:GetDriver()) then
				chk = chk + 1
				ply.AvehicleLastUsedSeat = ply.AvehicleLastUsedSeat + 1
				if (ply.AvehicleLastUsedSeat > self.PassengerCount) then
					ply.AvehicleLastUsedSeat = 0
				end
			else
				gotIn = self:ChangeToPod(ply, ply.AvehicleLastUsedSeat)
				if gotIn then 
					return true 
				else
					ply.AvehicleLastUsedSeat = ply.AvehicleLastUsedSeat + 1
					chk = chk + 1
					if (ply.AvehicleLastUsedSeat > self.PassengerCount) then
						ply.AvehicleLastUsedSeat = 0
					end
				end
			end
		end
		
	end
	return false
end

--For backward compatibility with older code, get in the first open seat
function ENT:GetIn(ply)
	local chk = 0
	 if IsValid(ply:GetVehicle()) then return end --We can't get in while in a vehicle.
	while (!self:GetInAt(ply, chk) and (chk <= self.PassengerCount)) do
		chk = chk + 1
	end
end

function ENT:GetInAt(ply, index)
	if IsValid(ply:GetVehicle()) then return false end --We can't get in while in a vehicle.
	
	if (not self:PlayerCheck(self.Passengers[index])) and (index == 0) then
		if IsValid(self.PodsEnts[index]) then
			if self:EnterPod(self.PodsEnts[index], ply, index) then
				self.Passengers[index]=ply
				self:SetPhysicsAttacker(ply)
				ply.AVehicle_Role = AVEHICLE_POD_DRIVER  --I am a driver
				ply:PrintMessage( HUD_PRINTCENTER, "You are the pilot off this vehicle.")
				return true
			end
		end
	else
		if not self:PlayerCheck(self.Passengers[index]) then
			if IsValid(self.PodsEnts[index]) then
				if self:EnterPod(self.PodsEnts[index], ply, index) then
					self.Passengers[index]=ply
					ply.AVehicle_Role = AVEHICLE_POD_PASSENGER --I am a passenger
					ply:PrintMessage( HUD_PRINTCENTER, "You are a passenger in seat "..tostring(index).." off this vehicle.")
					return true
				end
			end
		end
	end
	return false
end


function ENT:isPodEmpty(pod)
	local Driver = pod:GetDriver()
	if IsValid(Driver) then
		return false
	end
	return true
end

function ENT:GetNextOpenPod()
	for k,p in pairs(self.PodsEnts) do
		if self:isPodEmpty(p) then
			return k
		end
	end
	return -1
end

function ENT:EnterPod(pod, ply, index)
	if self:PodsAllowEnter(ply) then
		local Driver = pod:GetDriver() --We check if something is in the pod 
		
		if !self:isPodEmpty(pod) then
			Driver:ExitVehicle() --and remove it first.
			return false
		end
		
		if (index == 0) then
			self.Entity:SetOwner(ply)
		end
		
		local podtype = 0
		if pod.AvehiclePodType then
			podtype = pod.AvehiclePodType
		end
		ply.Avehicle_playerWeapons = nil
		--if (podtype == 0) then --Only in normal pods. 
			--Save the players weapons in order to restore them later.
			ply.Avehicle_playerWeapons = {}
			for k, v in pairs(ply:GetWeapons()) do
				if IsValid(v) then
					ply.Avehicle_playerWeapons[k] = v:GetClass()	
				end
			end
			ply:StripWeapons() --strip the all weapons after saving them.
			--ply:ConCommand("AVehicles_SetViewMode 2")
		--end
		
		ply:EnterVehicle(pod)
		self:PodsAIRelationship(ply, false) --Make NPC's see and attack me.
		--ply:GodEnable()
		self.PassengersIn = self.PassengersIn + 1
		self.Entity:SetNetworkedInt("Passengers_InCount",self.PassengersIn)
		--AVehicles.PlayerEnterVehicle(ply, active, pos, vEnt, schema, podtype)
		AVehicles.PlayerEnterVehicle(ply, true, index, self.Entity, self.EntityName, podtype)  --I'm using user messages instead of networked vars
		ply:SetNWEntity("AVehicles_podent", pod)
		ply.AVehicleMustSpawn = true -- this is important while in vehicle
		self:PlayerEntered(ply)
		
		ply:PrintMessage( HUD_PRINTCENTER, "You just entered an Alienate Vehicle.")
		if not ply.AVehicle_First_Entered then
			self:SendInfoHints(ply, self.UseageHint)
			self:SendInfoHints(ply, "Go to the Alienate Vehicles tab for control bindings.")
			ply.AVehicle_First_Entered = true
		end
		
		--ply:SnapEyeAngles(self:GetAngles())
		--ply:SnapEyeAngles(self:GetForward():Angle())
		return true
	end
	return false
end

function ENT:ExitPod(ply)
	--AVehicles.PlayerEnterVehicle(ply, active, pos, vEnt, schema, podtype)
	AVehicles.PlayerEnterVehicle(ply, false, -1, nil, " ", 0)  --I'm using user messages instead of networked vars
	ply:SetNWEntity("AVehicles_podent", nil)
	--ply:GodDisable()
	ply:ExitVehicle()
	--Give us some spawn protection, prevents moving vehicles from killing us etc.
	ply:GodEnable();
	timer.Simple(1.5, function()
		if IsValid(ply) then
			ply:GodDisable();
		end
	end)
	--self:PodsAIRelationship(ply, false) --Still Make NPC's see and attack me.
	
	ply.AVehicle_Role = nil --I am no longer a passenger or driver
	self.PassengersIn = self.PassengersIn - 1
	self.Entity:SetNetworkedInt("Passengers_InCount",self.PassengersIn)
	--Eject & Spawn Location
	if ply and ply.AVehicleMustSpawn then
		local NearEject = self:FindVehiclespawnpoint(self.SpawnPos.SpawnerRange) -- This function is located in lib.lua
		if IsValid(NearEject) then
			NearEject:SpawnCallVehicle(ply, self.Entity) --It must handle everything
		else
			--ply:Spawn()  
			local ejectpos = self.SpawnPos.SpawnOffset
			ejectpos = self.Entity:LocalToWorld(ejectpos)
			
			if not util.IsInWorld(ejectpos) then --Don't eject there if it's not in the world.
				ejectpos = ply:GetPos()
			end
			
			--First, Push other player out the way!
			local plents = ents.FindInSphere(ejectpos, 32)
			for k, v in pairs(plents) do
				if IsValid(v) and v:IsPlayer() and (v != ply) then
					v:ViewPunch( Angle( -15, 50, 0 ) )
					v:SetPos(v:GetPos() + Vector(0,0, 200))
					v:SetVelocity(self:GetVelocity());
				end
			end
			ply:SetPos(ejectpos)
			ply:SetVelocity(self:GetVelocity());
		end
	end
	
	--Give back their weapons!
	if ply.Avehicle_playerWeapons then
		for k, v in pairs(ply.Avehicle_playerWeapons) do
			if (v) and ply:Alive() then
				ply:Give(v)
			end
		end
	end
	
	if IsValid(ply) then
		self:PlayerExited(ply)
		ply:PrintMessage( HUD_PRINTCENTER, "You just ejected from an Alienate Vehicle.")
	end

	
end

function ENT:Eject(ply) --Need to update this for CoDriver and etc.
	if (self:PlayerCheck(self.Passengers[0]) and (self.Passengers[0] == ply))then
		if (IsValid(self.PodsEnts[0])) then
			self:ExitPod(ply)
			self.Passengers[0] = nil
			self.Entity:SetOwner(nil)
			self:SetPhysicsAttacker(self.AVehicle_Creator)
			if self.PodsEjectStopEngine then
				self:PodStopEngines()
			end
			return true
		end
	else
		for i=1, self.PassengerCount, 1 do
			if (IsValid(self.Passengers[i]) and IsValid(ply)) then
				if ply == self.Passengers[i] then
					self:ExitPod(ply)
					self.Passengers[i] = nil
					return true
				end
			end
		end
		
	end
	return false
end

function ENT:PodStopEngines()
	--Usually stop engine here
	local delay = 0.1
	if self.Engine.CustomEngine.StopAfter > 0.1 then
		delay = self.Engine.CustomEngine.StopAfter
	end
	timer.Simple(delay, function()
		if IsValid(self) then
			self.Engine.Phys.Roll			= 0
			self.Engine.Phys.Pitch			= 0
			self.Engine.Phys.Yaw			= 0
			self.Engine.Phys.UpDownSpeed	= 0
			self.Engine.Phys.StrafeSpeed	= 0
			self.Engine.Phys.Speed			= 0
			self.Engine.Phys.TurboSpeed		= 0
		end
	end)
	
	if self.Engine.CustomEngine.KillAfter > 0.1 then
		timer.Simple(self.Engine.CustomEngine.KillAfter, function()
			if IsValid(self) then
				self.Engine.Active = false
			end
		end)
	end

end

function ENT:EjectAll()
	for i=0, self.PassengerCount, 1 do
		self:Eject(self.Passengers[i])
	end
end

function ENT:EjectAndKillAll()
	for i=0, self.PassengerCount, 1 do
		if IsValid(self.Passengers[i]) then
			self:KillPassengers();
			self:Eject(self.Passengers[i])
		end
	end
end

function ENT:KillPassengers()
	local Killer
	if IsValid(self.Damage.Attacker) then Killer = self.Damage.Attacker end
	for i=0, self.PassengerCount, 1 do
		if(IsValid(self.Passengers[i])) then
			self.Passengers[i].AVehicleMustSpawn = false --Set this to make bodies faal out of vehicle on explode
			self.Passengers[i]:GodDisable()
			if(Killer) then
				self.Passengers[i]:SetHealth(1)
				self.Passengers[i]:TakeDamage(50,Killer,self.Entity)
			else
				self.Passengers[i]:Kill()
			end
			self.Passengers[i]:PrintMessage( HUD_PRINTCENTER, "You just died in an Alienate Vehicle accident.")
		end
	end
end

function ENT:EjectDead()
	for i=0, self.PassengerCount, 1 do
		if self:PlayerCheck(self.Passengers[i]) then
			if not self.Passengers[i]:Alive() then
				self:Eject(self.Passengers[i])
			end
		end
	end
end

function ENT:CheckIfPlyInPod(ply)
	if IsValid(ply) then
		local veh = ply:GetVehicle()
		if IsValid(veh) then
			return true
		end
	end
	return false
end

function ENT:PodsOnRemove()
	self:EjectAll()
	if (self.PodsEnts) then
		for k,v in pairs(self.PodsEnts) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
end

----------------This can be used to check that only admins or certain players can enter the vehicle   @   Warkanum
function ENT:PodsAllowEnter(ply)
	return true --Return true to allow player to enter a pod
end

--This needs some work, maybe add function that makes jumper an enemy.
function ENT:PodsAIRelationship(ent, notarget)
	if self:PlayerCheck(ent) then
		ent:SetNoTarget(notarget)
	end
end

--New function for child entities to use. @ Warkanum
function ENT:PlayerEntered(ply)

end

--New function for child entities to use. @ Warkanum
function ENT:PlayerExited(ply)

end

--Send hints to player. @ Warkanum
function ENT:SendInfoHints(ply, msg)
	if IsValid(ply) then
		ply:SendHint(msg,5)
	end
end


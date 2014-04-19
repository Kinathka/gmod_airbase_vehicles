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
AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "cl_init.lua" );
include('shared.lua');

ENT.WireDebugName = "AVehicle Rev Seat"
//Todo:
//Add limitview



function ENT:Initialize()
	self.DefaultModel = self.DefaultModel or "models/Nova/airboat_seat.mdl";
	self.ThirdViewDistance = self.ThirdViewDistance or 300;
	self.AllowWeapons = self.AllowWeapons or false;
	self.PlayerWeaponsTable = {};
	self:SetAVehicleSeat(true);
	self.Entity:SetModel(self.DefaultModel);
	self.Entity:PhysicsInit( SOLID_VPHYSICS );
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	self.Entity:SetColor(Color(20,100,20,255));
	self.Entity:DrawShadow(false);
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self.Entity:PhysWake();
	self.Occupant = nil;
	self.NextCurTime = 0;
	self.NextTickTime = 0;
	self.OccupantSetSpawnLocation = true;
	self.Locked = false;
	self.AVehiclesNonEnter = false;
	self.AVehiclesNonExit = false;
	self.limitview = false
	self:SetUseType(SIMPLE_USE);
	if self.HasWire then
		self.WireCreateSpecialOutputs(self, { "AimVector", "AimPos", "Forward", "Back", "Left", "Right", "Speed", "Walk", "Jump", "Reload", "ATTACK1", "ATTACK2", "IsOccupied"},
			{"VECTOR","VECTOR", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL" , "NORMAL" ,"NORMAL" ,"NORMAL","NORMAL", "NORMAL","NORMAL"});
		self.WireCreateInputs(self, "Lock", "Eject", "CanUseWeapons");
	end
	
	self.HidePlayerModel = self.HidePlayerModel or false;
end

function ENT:TriggerInput(k,v)
	if (k == "Lock") then
		self.Locked = (tonumber(v) >= 1);
	elseif (k == "Eject") then
		if (tonumber(v) >= 1) then
			self:ExitSeat(nil);
		end
	elseif (k == "CanUseWeapons") then
		self.AllowWeapons = (tonumber(v) >= 1);
	elseif (k == "limitview") then
		self.limitview = (tonumber(v) >= 1);
	end
end

function ENT:SetupModel()
	self.Entity:SetModel(self.DefaultModel);
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	if not ply:CheckLimit("avehicle_revseat") then return false end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,10);
	local ent = ents.Create( "avehicle_revseat" );
	ent:SetPos( SpawnPos );
	ent:Spawn();
	ent:Initialize();
	ent:Activate();
	ent:SetVar("Owner",ply);
	ply:AddCount("avehicle_revseat", ent);
	ply:AddCleanup( "avehicle_revseat", ent);
	return ent;
end
 
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo);
	if IsValid(self.Occupant) then
		if dmginfo:GetAttacker() == self.Occupant then return end
		self.Occupant:TakeDamageInfo(dmginfo);
	end
end 

function ENT:Use(activator, caller)
	if self.Locked or (self.AVehiclesNonEnter) then return end;
	if IsValid(self.Vehicle) and (self.AvehiclePodType == 0) then self:Avehicle_Use(activator, caller) end
	
	if (CurTime() > self.NextCurTime) then
		self.NextCurTime = CurTime() + 0.5; //Next time we may enter the seat
		
		if not self.Occupied and IsValid(activator) and (not (activator.AVehicleSeatOccupied)) then
			self:EnterSeat(activator);
			
		end
	end
end

--Special use called by Avehicles
function ENT:Avehicle_Use(p, e)
	if IsValid(e) and IsValid(e.Vehicle) then
		if (e.Vehicle.IsAVehicle) then
			if e.Vehicle:PlayerCheck(p) then
				e.Vehicle:GetInAt(p, e.AvehiclePodIndex);
			end
		end
	end
end

function ENT:Think()
	if (self.NextTickTime < CurTime()) then
		self.NextTickTime = CurTime() + 0.1;
		if self.HasWire then
			if (self.Occupied) and IsValid(self.Occupant) then
				self.WireTriggerOutput(self, "IsOccupied", 1);
				self.WireTriggerOutput(self, "AimVector", self.Occupant:GetAimVector());
				local pos = self.Occupant:GetEyeTrace().HitPos
				self.WireTriggerOutput(self, "AimPos", pos);
				if self.Occupant:KeyDown(IN_FORWARD) then self.WireTriggerOutput(self, "Forward", 1); else self.WireTriggerOutput(self, "Forward", 0); end
				if self.Occupant:KeyDown(IN_BACK) then self.WireTriggerOutput(self, "Back", 1); else self.WireTriggerOutput(self, "Back", 0); end
				if self.Occupant:KeyDown(IN_MOVELEFT) then self.WireTriggerOutput(self, "Left", 1); else self.WireTriggerOutput(self, "Left", 0); end
				if self.Occupant:KeyDown(IN_MOVERIGHT) then self.WireTriggerOutput(self, "Right", 1); else self.WireTriggerOutput(self, "Right", 0); end
				if self.Occupant:KeyDown(IN_SPEED) then self.WireTriggerOutput(self, "Speed", 1); else self.WireTriggerOutput(self, "Speed", 0); end
				if self.Occupant:KeyDown(IN_WALK) then self.WireTriggerOutput(self, "Walk", 1); else self.WireTriggerOutput(self, "Walk", 0); end
				if self.Occupant:KeyDown(IN_JUMP) then self.WireTriggerOutput(self, "Jump", 1); else self.WireTriggerOutput(self, "Jump", 0); end
				if self.Occupant:KeyDown(IN_RELOAD) then self.WireTriggerOutput(self, "Reload", 1); else self.WireTriggerOutput(self, "Reload", 0); end
				if self.Occupant:KeyDown(IN_ATTACK) then self.WireTriggerOutput(self, "ATTACK1", 1); else self.WireTriggerOutput(self, "ATTACK1", 0); end
				if self.Occupant:KeyDown(IN_ATTACK2) then self.WireTriggerOutput(self, "ATTACK2", 1); else self.WireTriggerOutput(self, "ATTACK2", 0); end
			else
				self.WireTriggerOutput(self, "IsOccupied", 0);
			end
		end
	end
end

function ENT:EnterSeat(ply)
	if not IsValid(ply) then return false end;
	if gamemode.Call("CanPlayerEnterVehicle", ply, self, 0) then
		if not (self.Occupied) then 
			local posang = self:GetAttachment(self:LookupAttachment("vehicle_feet_passenger0"));
			self.Occupant = ply;
			self.Occupied = true;
			ply:SetMoveType(MOVETYPE_NOCLIP);
			ply:SetPos(posang.Pos+posang.Ang:Up()*45-Vector(0,0,72));
			local oldang = ply:GetAngles()
			ply:SetAngles(Angle(oldang.p, oldang.y, 0))
			ply:SetAngles(posang.Ang);
			ply:SetNWBool("AVehicleSeatOccupied", true);
			ply:SetNWEntity("AVehicleSeatEntity", self);
			ply:SetNotSolid(true);
			--ply:SetAllowFullRotation(true)
			ply:SetParent(self);
			ply:SetNWBool("avehicle_seat_hideplayermodel", self.HidePlayerModel);
			if self.HidePlayerModel then
				ply:SetNoDraw(true)
				ply:DrawViewModel(false)
				ply:DrawWorldModel(false)
			end
			
			ply.AVehicleSeatOccupied = true;
			
			if not (self.AllowWeapons) then
				for k, gun in pairs(ply:GetWeapons()) do
					self.PlayerWeaponsTable[k] = gun:GetClass();
				end
				ply:StripWeapons();
				if (IsValid(self.Vehicle) and self.Vehicle.IsAVehicle) then
					timer.Simple(1.0, function()
						if IsValid(ply) then
							ply:CrosshairDisable();
						end
					end)
				else
					ply:CrosshairDisable();
				end
				
			end	
			--Inform the game that we entered a vehicle
			hook.Call("PlayerEnteredVehicle", gmod.GetGamemode(), ply, self, 1) 
			
			net.Start("AVehicle-Seats-Entered");
			net.WriteEntity(ply);
			net.WriteEntity(self);
			net.Send(ply);
		else
			self:ExitSeat(ply);
		end
	end
end


function ENT:ExitSeat(ply)
	if not IsValid(self.Occupant) then 
		self.Occupied = false ;
		return false;
	end
	
	self.Occupant:SetParent();
	self.Occupant:SetMoveType(MOVETYPE_WALK);
	self.Occupant:SetNWBool("AVehicleSeatOccupied", false);
	self.Occupant:SetNWEntity("AVehicleSeatEntity", NULL);
	self.Occupant:SetNotSolid(false);
	--self.Occupant:SetAllowFullRotation(false)
	self.Occupant:SetNWBool("avehicle_seat_hideplayermodel", false);	
	if self.HidePlayerModel then
		self.Occupant:SetNoDraw(false)
		self.Occupant:DrawViewModel(true)
		self.Occupant:DrawWorldModel(true)
	end
	
	if (self.OccupantSetSpawnLocation) then
		if (self.Occupant:GetEyeTrace().Entity == self) then
			self.Occupant:SetPos(self:GetPos() + (self:GetForward() * -70) + Vector(0,0,5));
		else
			self.Occupant:SetPos(self:GetPos() + Vector(0,0,80) + (self.Occupant:GetAimVector() * 70));
		end
	end
	self.Occupant:SetVelocity(self:GetVelocity());
	self.Occupant.AVehicleSeatOccupied = true;
	
	--We leave the vehicle
	hook.Call("PlayerLeaveVehicle", gmod.GetGamemode(), self.Occupant, self);	
	
		//timer.Simple(0.5, function()
		//Now give back the weapons this individual had.
		local thePlayer = self.Occupant;
		if not (self.AllowWeapons) and (self.PlayerWeaponsTable) then
			for k, gun in pairs(self.PlayerWeaponsTable) do
				thePlayer:Give(gun);
			end
			self.Occupant:CrosshairEnable();
		end
	//end);
	
	timer.Simple(0.1, function()
		if IsValid(self) then 
			self.Occupied = false;
			if IsValid(self.Occupant) then
				self.Occupant.AVehicleSeatOccupied = false;
			end
			self.Occupant = nil;
		end
	end)
	
	return true;
end

function ENT:OnRemove()
	self:ExitSeat(nil);
end

function ENT:PreEntityCopy()
	if IsValid(self) and IsValid(self.Vehicle) and (self.Vehicle.IsAVehicle) then return false end
	duplicator.StoreEntityModifier(self, "avehicle_revseat", 
		{defaultmodel = self.DefaultModel, thirdviewdistance = self.ThirdViewDistance});
end
/*
local function MakeRevSeat( pl, Pos, Ang, description, entityout, frozen )
	local eSeat = ents.Create("avehicle_revseat")
	if (!eSeat:IsValid()) then return false end
	eSeat:SetPos(Pos)
	eSeat:SetAngles(Ang)
	eSeat:Spawn()
	eSeat:Activate()
	
	if eSeat:GetPhysicsObject():IsValid() then
		local Phys = eSeat:GetPhysicsObject()
		Phys:EnableMotion(!frozen)
	end

	eSeat:PostSpawn() --This call is very important
	eSeat.Owner = pl
	pl:AddCleanup(eSeat.CleanupCategoryName,eSeat)

	return eSeat
end
duplicator.RegisterEntityClass("avehicle_revseat", MakeRevSeat, "Pos", "Ang", "description", "entityout", "frozen" )
*/

duplicator.RegisterEntityModifier( "avehicle_revseat", function(ply, ent, data)
	ent.ThirdViewDistance = data.thirdviewdistance;
	ent.DefaultModel = data.defaultmodel;
	ent:SetModel(ent.DefaultModel);
	ent:PhysicsInit(SOLID_VPHYSICS);
end)


function ENT:PhysicsSimulate()
	/*if IsValid(self.Occupant)  and self.Occupied then
		local posang = self:GetAttachment(self:LookupAttachment("vehicle_feet_passenger0"));
		self.Occupant:SetVelocity(self:GetVelocity());
		self.Occupant:SetPos(posang.Pos+posang.Ang:Up()*25); ---Vector(0,0,64)
		self.Occupant:SetAngles(self:GetAngles());
	end
	*/
end
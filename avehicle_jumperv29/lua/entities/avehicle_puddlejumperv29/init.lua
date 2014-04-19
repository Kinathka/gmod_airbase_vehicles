if not AVehicles then 
	Msg("\nAJumper:AVehicle Base not installed! Please install it for this addon to work!\n")
end 

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
include("sv/events.lua")

util.PrecacheModel(ENT.Models.Base)

/* A note the the person that wants to modify this code or use it.
 this code is based on the avehicle_base entity, is inherits from that entity.
So if you create a function like ENT:Initialize(), please add self.BaseClass.Initialize(self) in that function.
Please remeber the ENT:OnRemove() function and call self.BaseClass.OnRemove(self) in it!
The only exception is with the ENT:Think() function, there you can use ENT:DoThink() instead.
You may override function in the baseclass freely. If I update the base class you must update your stuff too though.
The baseclass entity should be avehicle_base
*/
if StarGate then
	local function AvehicleJumperV29SGTeleport(e,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
		-- Move a players view
		if IsValid(e) then
			local Passengers = e:GetPassengers()
			for k,p in pairs(Passengers) do
				if IsValid(p) then
					p:SetEyeAngles(p:GetAimVector():Angle() + Angle(0,ang_delta.y+180,0) )
				end
			end
		end
		--if(IsValid(e) and e.IsAVehicle and e.Passengers and IsValid(e.Passengers[0])) then
		---	e.Passengers[0]:SetEyeAngles(e.Passengers[0]:GetAimVector():Angle() + Angle(0,ang_delta.y+180,0));
		--end
	end
	StarGate.Teleport:Add("avehicle_puddlejumperv29",AvehicleJumperV29SGTeleport);
end

function ENT:Initialize()
	self.BaseClass.Initialize(self) --This is very important!
	
	self:CreateDoor()
	self.Entity:SetModel(self.Models.Base) 
	self.Entity:SetName(self.PrintName)
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.BaseOpen = true
	self.BaseWings = false

	--Please put this in the initialize function of the child entities if you want PhysicsSimulate to be called
	if (!self.EngineUseCustom) then
		self:StartMotionController()
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(6000)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	
	local size = self.Entity:OBBMins():Distance(self.Entity:OBBMaxs());
	self.VehicleBodyMaxLenght = size
	
	if StarGate then
		if StarGate.Installed then
			self.StargateAddon = true
		else
			self.StargateAddon = false
		end
	end
	self.JumperPods = false
	self.Cloaked = false
	self.Stick = 0
	self.NearValidStargate = false
	self.OnboardDrones = true
	
	 --Drones, Drones, cloak!!! Wow!
	self.Drones = {}
	self.DroneCount = 0
	self.MaxDrones = (6)
	self.CloakEnabled = false
	self.Cloak = nil
	self.TrackTime = 1000000
	self.Target = Vector(0,0,0)
	self.DroneMaxSpeed = 2000
	self.AllowAutoTrack = true
	self.AllowEyeTrack = false
	self.Track = false
	self.Launched = false
	self.IsShooting = false
	self.DHDisActive = false
	self.CloakisActive = false
	self.Door = false
	self.Sequence = nil
	self.isAnimating = false
	self.DronesContinueTrack = false
	
	self.HasToggelShield = true
	self.CanShield = true
	
	self.ImmuneOwner = true
	--Install some gagets
	self:LightsInstall(2, {Vector(160,42,-40),Vector(160,-42,-40)}, {Vector(1,0.2,0),Vector(1,-0.2,0)} )
	self:BullseyeInstall(Vector(130,0,0)) --Still testing
	--Wire
	self.WireCreateInputs(self, "X", "Y", "Z")
	self.WireCreateOutputs(self, "Health", "Drones", "Cloak")


	self.Entity:SetNetworkedEntity("Avehicle_gadget_jumperdoor", self.DoorEnt) --use for view filter
	
	--Add some built in weapons. We can handle fire functions in events.lua if not here. ("Drones", "Cloak")
	

	if StarGate and StarGate.Installed and scripted_ents.Get( "avehicle_sg_shield_generator" ) then
		self:WeaponPostAdd(0,"Drones",function() self:WepFireDrones() end,function() self:WepAltFireDrones() end) --Drones for driver
		self:WeaponPostAdd(0,"Cloak",function() self:WepToggelCloak() end,nil) --Cloak for driver
	
		
		self:SpawnShieldGen();
		self:WeaponPostAdd(0,"Shield",function() self:ShieldToggel() end,nil) --Cloak for driver
	end
	
end

function ENT:WepFireDrones()
	if self.OnboardDrones and not self.IsShooting and self.JumperPods then
		self.IsShooting = true
		if (self.DroneCount < 6) then
			self.Track = true --Overide!
			self.DronesContinueTrack = true;
			self:ShootDrone()
			self.Launched = true
		end
		timer.Simple(0.3,function()
			if IsValid(self) then
				self.IsShooting = false
			end
		end) 
	end
end

function ENT:WepAltFireDrones()
	if self.OnboardDrones and not self.IsShooting  and self.JumperPods then
		self.IsShooting = true
		if (self.DroneCount < 4) then
			self.Track = true --Overide!
			self:ShootDrone()
			self.Launched = true
			self.DronesContinueTrack = false;
			if (self.Passengers[0]) then
				--local traceRes = util.QuickTrace((self:GetPos()+self:GetForward()*1000), 
				--	self:GetForward()*100000, {self.Entity, self.Passengers[0]});
				--self.LastDroneLockPos = traceRes.HitPos 
				self.LastDroneLockPos = self:CalcAimVectors(self.Passengers[0]);
			end
		end
		timer.Simple(0.05,function()
			if IsValid(self) then
				self.IsShooting = false
			end
		end) 
	end
end

local CloakFlag = true
function ENT:WepToggelCloak()
	if CloakFlag and not self.JumperPods then
		CloakFlag = false
		if self.CloakisActive then
			self.CloakisActive = false
			self:CloakStatus(false)
		else
			self.CloakisActive = true
			self:CloakStatus(true, true)
		end
		timer.Simple(0.5, function() 
			if IsValid(self) then
				CloakFlag = true
			end
		end)
	end
end

function ENT:PhysicsSimulate(phys, deltatime)
	if (!self.EngineUseCustom) then
		if IsValid(self.Entity) then
			if (self.Engine) then --Check if the engine table exists.
				return self:EnginePhysicsSimulate(phys, deltatime)	
			end
		end
	end
end

function ENT:Use(ply, caller)
	if self.BaseOpen then
		self:SetDoor(false)
	else
		self:SetDoor(true)
	end
	return true
end

function ENT:SetStatus()
	self.BaseClass.SetStatus(self)
	if IsValid(self.ShipShield) and self.ShipShield.Strength then
		if self.Shielded then
			self:SetNWInt("avehicle_sg_shield_strength", self.ShipShield.Strength)
		else
			self:SetNWInt("avehicle_sg_shield_strength", 0)
		end
	end
end

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
	if (dir and IsValid(dir)) then
		if(dir:Length() < 250) then
			dir = dir:GetNormalized()*250
		end
	else
		dir = Vector(0,0,0);
	end
	ent:SetPos(pos + dir + Vector(0,0,z + 90))
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	--ent:SetOwner(ply)
	ent:SetPhysicsAttacker(ply)
	ent:SetVar("AVehicle_Creator",ply);
	ent:SetVar("Owner",ply);
	ent:PostSpawn() --This call is very important
	ply:AddCleanup(ent.CleanupCategoryName,ent)
	return ent
end

function ENT:PostSpawn()
	self:PodsUpdate() --Update the pods, collisions etc.
	self:SetDoor(true)
end


function ENT:SetPods(open)
	if self.isAnimating then return false end
	if open and self:EngineIsActive() then
		if self.Engine.Phys.Submerged then return false end --Don't even try to open under water.
		if self.Cloaked then return false end
		if self.BaseOpen then
			self:SetDoor(false)
			timer.Simple(2.5, function() 
				if IsValid(self) then
					self:SetPods(open)
				end
			end)
			return false --We don't want to continue. First close the door.
		end
		self:EmitSound(self.Sounds.Jumper.EnginePodOpen, 100, 100 )
		self.Entity:SetNWBool("AVehicle_Jumper_Wings", true)
		self:SetAnimWings(true)
		self.JumperPods = true
	else
		self:EmitSound(self.Sounds.Jumper.EnginePodClose, 100, 100 )
		self.Entity:SetNWBool("AVehicle_Jumper_Wings", false)
		self:SetAnimWings(false)
		self.JumperPods = false
		self.Engine.Phys.TurboSpeed = 0 --No turbo for you!
	end
end

function ENT:SetAnimWings(wings, open)
	self.isAnimating = true
	if wings then
		self.BaseWings = true
		self.Sequence =  self.Entity:LookupSequence("open")
	else
		self.BaseWings = false
		self.Sequence =  self.Entity:LookupSequence("close")
	end
	self.Entity:ResetSequence(self.Sequence)
	self.Entity:SetPlaybackRate(5)
	timer.Simple(5, function()
		if IsValid(self) then
			self.isAnimating = false
		end
	end)
end


function ENT:SetDoor(open)
	if self.isAnimating then return false end
	if self.JumperPods then return false end
	self.isAnimating = true
	if open then
		self.Sequence = self.Entity:LookupSequence("door_o")
		self.BaseOpen = true
		self.Door = true
		if IsValid(self.DoorEnt) then
			self.DoorEnt:SetSolid(SOLID_NONE)
		end
	else
		self.Sequence = self.Entity:LookupSequence("door_c")
		self.BaseOpen = false
		self.Door  = true
		if IsValid(self.DoorEnt) then
			self.DoorEnt:SetSolid(SOLID_VPHYSICS)
		end
	end
	self:EmitSound(self.Sounds.Jumper.Door, 100, 100 )
	self.Entity:ResetSequence(self.Sequence)
	self.Entity:SetPlaybackRate(10)
	timer.Simple(2, function()
		if IsValid(self) then
			self.isAnimating = false
		end
	end)
end

function ENT:DoThink() --Called by the parent think, do not make your own think, else add the exact time and call self.BaseClass.Think(self) 
	--Update drones aimvectors
	if self.Passengers[0] then
		if (self.DronesContinueTrack) then
			self.Target = self:CalcAimVectors(self.Passengers[0])
			self.LastDroneLockPos = self:CalcAimVectors(self.Passengers[0]);
		else
			self.Target = self.LastDroneLockPos;
		end
	end

	if (self.JumperPods and (not self:EngineIsActive())) then
		self:SetPods(false)
	end

	if (self.HasRD3) and not self.BaseOpen then
		self:ProvideLifeSupport()
	end
	
	--If there is no pilot, close pods and open the door
	if not IsValid(self.Passengers[0]) then
		if self.JumperPods then
			self:SetPods(false)
		end
		--if not self.BaseOpen then
		--	self:SetDoor(true)
		--end
	end

	self.WireSet(self, "Health", math.Round(self.Damage.Hull / self.DamageSystem.HullMax * 100) )
	self.WireSet(self, "Drones", (self.MaxDrones - self.DroneCount))
end



-------------------Check some engine operational stuff here. @ Warkanum
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
			if self.JumperPods then
				self:SetPods(false)
			end
			self.Engine.Phys.Submerged		= true
			if self.Engine.Phys.WaterDepth > 2 then
				self.Engine.Phys.TurboSpeed = 0
				--self.Engine.Phys.Speed = (self.Engine.Phys.Speed * 0.85)
				self.Engine.Phys.UpDownSpeed = (self.Engine.Phys.UpDownSpeed * 0.6)
				self.Engine.Phys.StrafeSpeed = (self.Engine.Phys.StrafeSpeed * 0.6)
			end
		else
			self.Engine.Phys.Submerged		= false
		end
			
		--Engine gagets check and update
		if (self.Engine.Active and self.JumperPods) then --When Engine is active:
			if not IsValid(self.Engine.RotorWash.Ent) then
				self:EngineAddRotorWash()
			end
		else --When Engine is not active:
			if IsValid(self.Engine.RotorWash.Ent) then
				self:EngineRemoveRotorWash()
			end
		end

	end
end

----Overridden from base class to provide sounds. Remember to call baseclass function though. @ Warkanum
function ENT:EngineOn()
	if self.BaseClass.EngineOn(self) then
		self:EmitSound(self.Sounds.Jumper.Startup, 100, 100)
		return true
	end
	return false
end

function ENT:EngineOff()
	if self.BaseClass.EngineOff(self) then
		self:EmitSound(self.Sounds.Jumper.Shutdown,100,100)
	end
end

function ENT:CreateDoor()

	local door = ents.Create("prop_physics");
	door:SetModel("models/Votekick/jumper/gibs/gib3.mdl");
	door:SetPos (self:GetPos());
	door:SetAngles(self:GetAngles());
	door:SetParent(self);
	door:DrawShadow(false)
	door:SetSolid(SOLID_VPHYSICS);
	door:SetMoveType(MOVETYPE_VPHYSICS);
	door:PhysicsInit(SOLID_VPHYSICS);
	door:SetColor(Color(255,255,255,255));
	door:Spawn();
	door:Activate();
	door.IsAVehicleObject = true
	self.DoorEnt = door;
	self.Entity:SetNetworkedEntity("Avehicle_gadget_jumperdoor", self.DoorEnt)
	constraint.Weld( self.DoorEnt, self, 0, 0, 0, true );

end

function ENT:CreateGibs()
	local gibs = {}
	local i = 0
	local TimeToLive = 10
	local velocity = self:GetVelocity()
	for _,v in pairs(self.Models.Gibs) do
		i = i + 1
		local model = v
		local e = ents.Create("prop_physics")
		e:SetPos(self.Entity:GetPos())
		e:SetAngles(self.Entity:GetAngles())
		e:SetModel(model)
		e:PhysicsInit(SOLID_VPHYSICS)
		e:SetMoveType(MOVETYPE_VPHYSICS)
		e:SetSolid(SOLID_VPHYSICS)
		e:SetCollisionGroup(COLLISION_GROUP_WORLD)
		e:Activate()
		e:Spawn()
		e:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000)
		e:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000)
		e:Ignite(10,70)
		table.insert(gibs,e)
	end
		
	timer.Simple(TimeToLive, function()
		if gibs then
			for k,v in pairs(gibs) do
				if IsValid(v) then
					v:Extinguish()
					v:Remove()
				end
			end
		end
	end)

end

---------------------------------------Easy fix, fast workaround @ warkanum
local DroneSide = false
function ENT:ShootDrone()
	if self.StargateAddon then
		if not self.Cloaked then
			if DroneSide then
				DroneSide = false
				self:FireDrone(self.Entity:GetRight()*100)
				--self.Entity:EmitSound("Weapon_Mortar.Single")
			else
				DroneSide = true
				self:FireDrone(self.Entity:GetRight()*-100)
				--self.Entity:EmitSound("Weapon_Mortar.Single")
			end
		end
	end
end



function ENT:SpawnShieldGen()
	if IsValid(self) then
		if scripted_ents.Get( "avehicle_sg_shield_generator" ) then
			local shieldSize = (self.VehicleBodyMaxLenght / 2)
			local e = ents.Create("avehicle_sg_shield_generator")
			local centerpos = self.Entity:LocalToWorld(self.Entity:OBBCenter())
			e:SetPos(centerpos)
			e:SetAngles(self:GetAngles())
			e:SetVar("Owner", self)
			e:SetVar("Size",shieldSize)
			e:SetParent(self)
			e:Spawn()
			e:Activate()
			e:SetSolid(SOLID_NONE)
			e:SetColor(Color(255,255,255,0))
			self.ShipShield=e
			e.Size = shieldSize
			e.DrawBubble = true
			e.PassingDraw= true
			e.StrengthMultiplier={2,2,2}
			e:SetShieldColor(0.1,0.1,0.94)
		end
	end
end

function ENT:SetShield(on)
	if(IsValid(self) and IsValid(self.ShipShield)) then
		if (on) and (self.CanShield) and (not self.Shielded) then
			if(not(self.ShipShield:Enabled())) then
				self.ShipShield:Status(true)
				self.Shielded=true
				self.CanCloak=false
			end
		else
			if(self.ShipShield:Enabled()) then
				self.ShipShield:Status(false)
				self.Shielded=false
				self.CanCloak=true
			end
		end
	end
end

function ENT:ShieldToggel()
	if IsValid(self) then
		if (self.HasToggelShield) then
			if self.Shielded then
				self:SetShield(false);
			else
				self:SetShield(true);
			end
		end
		self.HasToggelShield = false
		timer.Simple(0.75, function()
			if IsValid(self) then
				self.HasToggelShield = true
			end
		end)
	end
end

/*
function ENT:PrepareStargateTravel(active)
	local check = false
	if active then check = true else check = false end
	if self.EngineActive then check = true else check = false end
	if check then
		--I need an idea to let the jumper go through world. Sometimes get stuck when going through stargate.
		--I think the best will be to wait for Avon to add clipping to his stargates.
	else

	end
end
*/

function ENT:StargateCheck() --Check if we are near a dialing stargate.
	local gate = self:FindGate(800)
	self.NearValidStargate = false
	if IsValid(gate) then
		if gate.IsStargate then
			if gate.Outbound then
				self.NearValidStargate = true
			end
		end
	end
end

local function MakeJumper( pl, Pos, Ang, description, entityout, frozen )

	local eJumper = ents.Create("avehicle_puddlejumperv29")
	if (!eJumper:IsValid()) then return false end

	eJumper:SetPos(Pos)
	eJumper:SetAngles(Ang)
	eJumper:Spawn()
	eJumper:Activate()
	
	
	if eJumper:GetPhysicsObject():IsValid() then
		local Phys = eJumper:GetPhysicsObject()
		Phys:EnableMotion(!frozen)
	end

	eJumper:PostSpawn() --This call is very important
	eJumper.Owner = pl
	pl:AddCleanup(eJumper.CleanupCategoryName,eJumper)
	

	return eJumper
end

duplicator.RegisterEntityClass("avehicle_puddlejumperv29", MakeJumper, "Pos", "Ang", "description", "entityout", "frozen" )

--Stargate pre Teleport @ Warkanum  (Note: Add code to make all attached ents also no-collide. Ex. attached weapons)
function ENT:PreStargateTeleport(entEH, tblEnts, blocked)
	--Free look, so we keep our entry angle and exit angle.
	self.Engine.Simulated.mousefreelook = true;
	timer.Simple(0.5, function()
		self.Engine.Simulated.mousefreelook = false;
		--Fixes the getting stuck in wall behind problems. I HATE THAT
		local stargate = entEH.TargetGate;
		if IsValid(stargate) then
			local fixedpos = (stargate:LocalToWorld(stargate:OBBCenter()))+ stargate:GetForward() * self.VehicleBodyMaxLenght ;
			local physObj = self:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:SetPos(fixedpos);
			end
			--Msg(string.format("StargatePre Teleport : %s , %s - %s ", tostring(entEH), tostring(stargate),  tostring(tblEnts)));
		end
	end)
	
end


--Avon Stargate support 
 --(Below this, is edited code. Credits go to LightDemon+Votekick+Avon)  @ Warkanum, Lifecell
function ENT:FireDrone(offset) --thanks Avon
	if self.StargateAddon then
		if (not self.Cloaked) then	
			local pos = self.Entity:GetPos();
			local phys = self.Entity:GetPhysicsObject() --Aah, a fix with drones flying to fast.
			local vel = Vector(0,0,0)
			if (phys:IsValid()) then
				vel = phys:GetVelocity()
			end
			local nvel = Vector(0,0,0)
			
			--A little check to see if we are moving very vast. Else we get errors on e:SetVelocity(vel); if vel:Length > 1300-2000
			if (vel:Length() <= 0) or (vel:Length() > 1300) then
				nvel =  self.Entity:GetForward()*1200 + self.Entity:GetUp()*-300 --Since we are fast, make drone go down.
			else
				nvel = vel
			end
			--calculate the drone's position offset. Otherwise it might collide with the launcher
			local e = ents.Create("drone");
			e.Parent = self.Entity;
			e:SetPos(pos+offset);
			e:SetAngles(self.Entity:GetForward():Angle()+Angle(math.random(-2,2),math.random(-2,2),math.random(-2,2)));
			e:SetOwner(self.Entity); -- Don't collide with this thing here please
			e.Owner = self.Entity.Owner;
			e:Spawn();
			e:SetVelocity(nvel);
			self.DroneCount = self.DroneCount + 1;
			self.Drones[e] = true;
			-- This is necessary to make the drone not collide and explode with the cannon when it's moving
			e.CurrentVelocity = math.Clamp(nvel:Length(),0,self.DroneMaxSpeed-500)+501;
			e.CannonVeloctiy = nvel;
		end
	end
end


function ENT:OpenDHD(p) --thank you avon
	if(not IsValid(p)) then return end;
	local e = self:FindGate(3000);
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	umsg.Start("StarGate.OpenDialMenuDHD",p);
	umsg.Entity(e);
	umsg.End();
end


function ENT:FindGate(dist)
	local gate;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end


function ENT:CloakStatus(b,nosound) --thank you avon
	if self.StargateAddon then
	if(b) then
		if IsValid(self.Engine.RotorWash.Ent) then --Rotor wash fix for the cloak.
			self.Engine.RotorWash.Enabled = false
			self:EngineRemoveRotorWash()
		end
		self.WireSet(self, "Cloak", 1)
		self:LightsDeativate()
		if self.JumperPods then self:SetPods(false) end
		self.Cloaked = true
		self.Entity:SetNWBool("AVehicle_Jumper_Cloaked", true)
		
		if not(self.Cloak and self.Cloak:IsValid()) then
				local e = ents.Create("cloaking");
				e.Size = 200;
				e:SetPos(self.Entity:GetPos());
				e:SetAngles(self.Entity:GetAngles());
				e:SetParent(self.Entity);
				e:Spawn();
				if(not nosound) then
					self:EmitSound(self.Sounds.Jumper.Cloak,80,math.random(80,100));
				end
				if(e and e:IsValid() and not e.Disable) then -- When our new cloak mentioned, that there is already a cloak
					self.Cloak = e;
					
					return;
				end
			
		end
	else
		self.Cloaked = false
		self.Entity:SetNWBool("AVehicle_Jumper_Cloaked", false)
		self.WireSet(self, "Cloak", 0)
		if self.Cloak and self.Cloak:IsValid() then
			self.Cloak:Remove();
			self.Cloak = nil;
			-- Give back the energy, we took when it was enagaged
			if(not nosound) then
				self:EmitSound(self.Sounds.Jumper.Uncloak,80,math.random(90,110));
			end
		end
		if not IsValid(self.Engine.RotorWash.Ent) then
			self.Engine.RotorWash.Enabled = true
			self:EngineAddRotorWash()
		end
		return;
	end
	-- Fail animation
	end
end

function ENT:ShowOutput() 

end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self) --I can't even tell you how important this is! Because it is! 
end

function ENT:TriggerInput(k,v)
	if(k == "X") then
		self.Target.x = v
	elseif(k == "Y") then
		self.Target.y = v
	elseif(k == "Z") then
		self.Target.z = v;
	end
end


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

-----------------------Definitions---------------------
ENT.DamageEnabled = true
---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------

function ENT:DamageInitialize()
	self.Damage = self.Damage or {}
	self.Damage.HasExpleded = false --internal use
	self.Damage.repaircount = 0 -- used for wear
	self.Damage.HitMassMul	= 0.5 -- Object mass / Mas Hull * this = Damage Done on hit of object.
	self.Damage.maxrepaircount = self.DamageSystem.repairlimit --repairing more times than this will make it explode
	self.Damage.Hull = self.DamageSystem.HullMax
	self.Damage.ExplodeRadius = self.DamageSystem.ExplodeRadius
	self.Damage.ExplodeDamage = self.DamageSystem.ExplodeDamage
	self.Damage.Attacker		= nil
	self.Damage.Shield			= 1	--If you have a shield entity or something, change this value. This is 1 = 100%  and 0.1 = 10% damage
	self.Damage.Collision = {}
	self.Damage.Collision.Enabled = self.DamageSystem.Collisions
	self.Damage.Collision.Hard = self.DamageSystem.CollisionHard
	self.Damage.Collision.Soft = self.DamageSystem.CollisionSoft
	self.Damage.Collision.HitDamageMul = self.DamageSystem.HitDamageMul  
	self.Damage.Collision.StopOnHit = self.DamageSystem.StopOnHit
	self.Damage.ShakeOnHit = self.DamageSystem.ShakeOnHit or true
	self.Damage.LastShakeTime = 0
end

//Provides the vehicle with lifesupport
function ENT:ProvideLifeSupport() 
	if IsValid(self) and self.HasRD3 then
		--Do not allow lifesupport if fuel is very low
		if (self.FuelSystem.fuel < 1) and (self.FuelSystem.resrv < (self.FuelSystem.reservemax * 0.3)) then --30% reserves
			return false 
		end
		--Do not allow if to much damage
		if (self.Damage.Hull < (self.DamageSystem.HullMax * 0.08)) then --8% damage
			return false 
		end

		local ent_pos = self:GetPos()
		for _,p in pairs(player.GetAll()) do 
			if IsValid(p) and p:IsPlayer() then
				local pos = (p:GetPos()-ent_pos):Length() 
				if(pos<400) and (p.suit) then
					p.suit.air=200
					p.suit.coolant=200
					p.suit.energy=200
				end
			end
		end
	end
end

--Used by sents to repair, there is a limit though!! @ warkanum
function ENT:RepairDamage()
	if (self.Damage.repaircount >= self.Damage.maxrepaircount) then
		--self.DamageSystem.HullMax = self.DamageSystem.HullMax / 4
		--self.Damage.repaircount = 1
		--Do something here!
		return false
	end
	self.Damage.repaircount	 = self.Damage.repaircount + 1
	self.Damage.Hull = self.DamageSystem.HullMax
end

--Used by sents @ warkanum
function ENT:DamageSetShield(percent)
	self.Damage.Shield = 1 / math.Clamp(percent,1,100)
end

--Used by sents @ warkanum
function ENT:DamageGetShield()
	return (1-self.Damage.Shield) * 100
end

function ENT:DoDamage(dmginfo)
	if IsValid(self) then
		if (self.DamageEnabled) then
			local dmg = dmginfo:GetDamage()
			local attacker = dmginfo:GetAttacker()
			local inclictor = dmginfo:GetInflictor()
			if(IsValid(attacker) and attacker ~= self.Entity) then
				self.Damage.Attacker = attacker
			elseif(IsValid(inclictor) and inclictor ~= self.Entity) then
				self.Damage.Attacker = inclictor
			end
			if dmginfo:IsExplosionDamage() then
				self:DamageHurt(dmg*4, tostring(dmginfo:GetDamageType()))
			elseif dmginfo:IsBulletDamage() then
				self:DamageHurt(dmg*0.5, tostring(dmginfo:GetDamageType()))
			else
				self:DamageHurt(dmg, tostring(dmginfo:GetDamageType()))
			end
			self:DoDamageKick(dmginfo)
		end
		
	end
end

--Check for type of damage done here. Have to rewrite. @ warkanum
function ENT:DamageHurt(dmg, dmgtype)
	self.Damage.Hull = self.Damage.Hull - (dmg * self.Damage.Shield)
	if self.Damage.Hull < 1 then
		self:DoExplode()
	end
end

function ENT:DoExplode()
		--Effect
	if not self.Damage.HasExpleded then
		self.Damage.HasExpleded = true
		
		--self:EjectAll()
		self:EjectAndKillAll()
		
		if math.random(2) == 1 then
			local effect = EffectData( )
			effect:SetScale( 1 )
			effect:SetMagnitude( 1 )
			effect:SetOrigin( self:GetPos( ) )
			util.Effect("effect_avehicle_dustexplosion", effect)
		else
			local effect = EffectData( )
			effect:SetScale( 1 )
			effect:SetMagnitude( 1 )
			effect:SetOrigin( self:GetPos( ) )
			util.Effect("effect_avehicle_dustexplosion2", effect)
		end

		
		--Explosion shockwave
		local e = ents.Create("info_particle_system")
		e:SetPos(self.Entity:GetPos())
		e:SetAngles(self.Entity:GetAngles())
		e:SetKeyValue("effect_name","citadel_shockwave_06")
		e:SetKeyValue("start_active",1)
		e:Spawn()
		e:Activate()
		e:Fire("Stop","",0.9)
		e:Fire("kill","",1)
		
		
		/*
		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(), self.Damage.ExplodeRadius)) do
			if IsValid(v) then
				local dist = (self.Entity:GetPos() - v:GetPos()):Length()
				if v:IsPlayer() then
					v:ViewPunch(Angle( -20, -20, 0 ))
					v:TakeDamage(math.Clamp(self.Damage.ExplodeDamage - (dist), 0, 200), driver, self.Entity )
				else
					v:TakeDamage(math.Clamp(self.Damage.ExplodeDamage - (dist), 0, 200), driver, self.Entity )
					v:Ignite(5, 0)
				end
			end
		end
		*/
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), self.Damage.ExplodeRadius, self.Damage.ExplodeDamage)  --I get a tack overflow error, why?
		
		self:CreateGibs()
		self.Entity:Remove()
	end
end


function ENT:CreateGibs()
	-- Gibs
	if self.GibModels then
		local gibs = {}
		local i = 0
		local TimeToLive = 13
		local velocity = self:GetVelocity()
		for _,v in pairs(self.GibModels) do
			if v and (type(v) == "string") then
				i = i + 1
				local e = ents.Create("prop_physics")
				e:SetPos(self.Entity:GetPos())
				e:SetAngles(self.Entity:GetAngles())
				e:SetModel(v)
				e:PhysicsInit(SOLID_VPHYSICS)
				e:SetMoveType(MOVETYPE_VPHYSICS)
				e:SetSolid(SOLID_VPHYSICS)
				e:SetCollisionGroup(COLLISION_GROUP_WORLD)
				e:Activate()
				e:Spawn()
				e:GetPhysicsObject():SetVelocity(velocity*200 + Vector(math.random(1, 1000),math.random(1, 1000),math.random(1, 1000)))
				e:GetPhysicsObject():ApplyForceCenter(velocity*200 + Vector(math.random(1, 1000),math.random(1, 1000),math.random(1, 1000)))
				e:Ignite(10,70)
				table.insert(gibs,e)
			end
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
end

--Personal note: Rewrite this to take material type into account. @ warkanum
function ENT:CollisionDetection(CollisionData, physobj)
	if (CollisionData.Speed > 200 && CollisionData.DeltaTime > 0.3 ) and (GetConVarNumber("avehicles_cvar_vehicle_collisioneffects") >= 1) then
		if IsValid(CollisionData.HitObject) then
			if IsValid(CollisionData.HitEntity) then
				local mass = 1
				if not (CollisionData.HitEntity:IsPlayer() or CollisionData.HitEntity:IsNPC()) then
					local phys = CollisionData.HitEntity:GetPhysicsObject()
					if phys:IsValid() then
						mass = phys:GetMass() or 1
					end
					if (CollisionData.HitEntity:GetClass() == "worldspawn") then
						mass = 1000
					end
					local CanMove = CollisionData.HitObject:IsMoveable()
					self:DoCollisionEffects(CollisionData.HitPos, CollisionData.Speed, CanMove, mass)
				else --Now for players and npc
					--No actaul collision.
				end
			else
				self:DoCollisionEffects(CollisionData.HitPos, CollisionData.Speed, false, 10)
			end
		end	
	end
end

function ENT:DoCollisionEffects(HitPos, Speed, CanMove, mass)
	if Speed > self.Damage.Collision.Hard then
		--Hard Collision
		local sounds = {"MetalVehicle.ImpactHard", "SolidMetal.ImpactHard"}
		self:EmitSound(sounds[math.random(1,2)])
	elseif Speed > self.Damage.Collision.Soft then
		--Soft Collision
		local sounds = {"MetalVehicle.ImpactSoft", "SolidMetal.ImpactSoft"}
		self:EmitSound(sounds[math.random(1,2)])
	end
				
	local effectdata = EffectData()
	effectdata:SetStart( HitPos) 
	effectdata:SetOrigin( HitPos)
	effectdata:SetScale( 2 )
	util.Effect( "cball_explode", effectdata ) 
	
	local speed = self.Entity:GetPhysicsObject():GetVelocity():Length()
	if not CanMove then
		self:DamageHurt(speed*self.Damage.Collision.HitDamageMul, "collision")
		if self.Damage.Collision.StopOnHit then
			self:DamageStopMotion()
		end
	else
		self:DamageHurt((mass/self.DamageSystem.HullMax*self.Damage.HitMassMul)+((speed/2)*self.Damage.Collision.HitDamageMul), "movecollision")
	end	
end

function ENT:DoDamageKick(dmg) --Takes damageinfo and makes a kick
	local phys = nil
	if self.DamageSystem.DamageKickMul and self.DamageSystem.DamageKickMul > 0 then
		if self.Phys and self.Phys:IsValid() then
			phys = self.Phys
		else
			phys = self.Entity:GetPhysicsObject()
		end
		if(phys and phys:IsValid()) then
			local mul = self.DamageSystem.DamageKickMul * 0.1
			if(self.Engine.Active) then mul = self.DamageSystem.DamageKickMul end
			if (IsValid(dmg) and dmg:GetDamage() > 0
				and IsValid(dmg:GetDamageForce()) and dmg:GetDamageForce():Length() > 0) then
				local force = (dmg:GetDamageForce():GetNormalized())*10000*math.Clamp(dmg:GetDamage()*50,2000,40000)*mul;
				phys:ApplyForceOffset(force,dmg:GetDamagePosition())
			end
		end
	end
	if (self.Damage.ShakeOnHit) and dmg then
		local damagefactor = math.Clamp(dmg:GetDamage(), 1, 2000) / 1000
		if (self.Damage.LastShakeTime < CurTime()) and (GetConVarNumber("avehicles_cvar_vehicle_damageshake") >= 1) then
			self.Damage.LastShakeTime = CurTime() + 1
			--local size = self.Entity:OBBMins():Distance(self.Entity:OBBMaxs());
			--util.ScreenShake(self:GetPos(), math.Clamp((math.random(1, 4)*damagefactor), 0, 800) , 0.1, 2, size/2)
			for k,v in pairs(self:GetPassengers()) do
				if IsValid(v) then
					local mul = GetConVarNumber("avehicles_cvar_vehicle_damageshake")
					v:ViewPunch(Angle(math.random(-100, 100)*damagefactor*mul,math.random(-100, 100)*damagefactor*mul, math.random(-50, 50)*damagefactor*mul))
				end
			end
		end
	end
end

function ENT:DamageStopMotion()
	--Usually stop engine here
	if (self.Engine) and (self.Engine.Simulated) then
		self.Engine.Simulated.emergencystop = true --Stop our simulated engine. I hate when you drive then slide against the walls.
	end
	self.Engine.Phys.TurboSpeed		= 0
	self.Engine.Phys.Speed 			= 0
	self.Engine.Phys.UpDownSpeed 	= 0
	self.Engine.Phys.StrafeSpeed	= 0
	self.Engine.Phys.Roll			= 0
	self.Engine.Phys.Pitch			= 0
	self.Engine.Phys.Yaw			= 0
end

	
function ENT:DamageOnRemove()
	
end

function ENT:gcbt_breakactions(damage, pierce) 

end
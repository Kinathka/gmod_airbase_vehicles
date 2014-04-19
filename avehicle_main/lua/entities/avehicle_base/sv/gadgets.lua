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
------------------------------------------------------------gadgets---------------------------------------------------------

---------------------------------------------------------------The Body, Code----------------------------------------------------------------------------
----------------------Initialize Engine System Variables @ Warkanum
function ENT:GadgetsInitialize()
	self.Gadgets_Loaded = true
	self.Gagets = {}
	self.Gagets.Bullseyes = {}
	self.Gagets.Lights = {}
	--self.HasHardPoints 
end

------------------------------------Lights
function ENT:LightsInstall(count, positions, DirOffset)  
	if count then
		
		-------------------Code From Avon's Jumper--------------------
		local LightPos = positions or {Vector(165,42,-45),Vector(165,-42,-45)}
		local LightDir = DirOffset or {Vector(1,0.2,0),Vector(1,-0.2,0)}
		for i=1,count do
			local e = ents.Create("avehicle_gadget_light")
			e:SetPos(self.Entity:LocalToWorld(LightPos[i]))
			e:SetAngles((self.Entity:LocalToWorld(LightDir[i]) - self.Entity:GetPos()):Angle())
			e:SetParent(self)
			e.IgnoreView = true			--This is used to make shure we don't view our own entities
			e:Spawn()
			table.insert(self.Gagets.Lights,e)
		end
		return true
	end
	return false
end

function ENT:LightsToggel()  
	if (self.Gagets.Lights) then
		for k,v in pairs(self.Gagets.Lights) do
			self.Gagets.Lights[k]:Toggle()
		end
	end
end

function ENT:LightsDeativate()
	if self.Gagets.Lights then
		for k,v in pairs(self.Gagets.Lights) do
			if(v:GetNWBool("On",false)) then
				v:Toggle()
			end
		end
	end
end

function ENT:BullseyeInstall(posOffset)  
	local e = ents.Create("npc_bullseye")
	if IsValid(e) then
		e:SetPos(self.Entity:LocalToWorld(posOffset))
		e:SetAngles(self.Entity:GetAngles())
		e:SetParent(self.Entity)
		e:SetMaxHealth(10000)
		e:SetHealth(10000)
		e:SetSolid(SOLID_NONE)
		e.IgnoreView = true			--This is used to make shure we don't view our own entities
		e:Spawn()
		if e:IsNPC() then
			--e:AddEntityRelationship(player.GetByID(1), D_LI, 99 )
			--set some stuff here
			/*
			print("Bullseye is npc: ", e)
			local npcs = ents.FindByClass("npc_*")
			for k,v in pairs(npcs) do
				if IsValid(v) and v:IsNPC() and not (v:GetClass() == "npc_bullseye") then
					e:AddEntityRelationship(v, D_HT, 99 )
					v:AddEntityRelationship(e, D_HT, 99 )
					print("Bullseye is hated by npc: ", v)
				end
			end
			*/
		end
		table.insert(self.Gagets.Bullseyes,e)
		return e
	end
	return nil
end

function ENT:SetNPCRelations(disposition, class, priority)
	local npcs = ents.FindByClass("npc_"..class) or {}
	for _,v in pairs(npcs) do
		if v and v:IsNPC() then
			for _,b in pairs(self.Gagets.Bullseyes) do
				if b and b:IsNPC() then
					v:AddEntityRelationship(b, disposition, priority)
				end
			end
		end
	end
end

function ENT:GetBullseyes(posOffset)  
	if self.Gagets.Bullseyes then
		return self.Gagets.Bullseyes
	end
	return {}
end

function ENT:GadgetsOnRemove()
	--Remove the lights
	if self.Gagets.Lights then
		for k,v in pairs(self.Gagets.Lights) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
	--Remove the bullseyes
	if self.Gagets.Bullseyes then
		for k,v in pairs(self.Gagets.Bullseyes) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
	self.Gadgets_Loaded = false
end


/*
--Deploy a parachute for the player or entity. @ Warkanum
function ENT:DeployParachute(e)
	if !IsValid(ent) then return false end
	local ropelength = 100
	local ply = nil
	local isPlayer = false
	local ent = nil
	if e:IsPlayer() then
		isPlayer = true
		ply = e
		ent = ents.Create("prop_physics")
		ent:SetModel("models/props_c17/oildrum001.mdl")
		--ent:SetNoDraw(true)
		ent:SetPos(ply:GetPos())
		ent:SetAngles(ply:GetAngles())
		ent:Spawn()
		ent:SetOwner(ply)
		ent.ply = ply
		ply:SetParent(ent)
	else
		ent = e
	end
	
	local chute = ents.Create("avehicle_parachute_dep")
	chute:Spawn()
	chute:SetPos(ent:GetPos() + ent:GetUp() * 100)
	chute:SetAngles(ent:GetAngles())
	chute:SetRenderMode( RENDERMODE_TRANSALPHA )

	local ephys = ent:GetPhysicsObject()
	if ephys and ephys:IsValid() then
		chute:SetCounterForce(ephys:GetMass() *0.98)
	end
	
	local spawnervec = (ent:GetPos()-chute:GetPos()):GetNormalized()*250
	local trace = util.QuickTrace(chute:GetPos(),spawnervec,chute)
	
	local LPos1 = chute:WorldToLocal((ent:GetPos()+(ent:GetUp()*25)) + Vector(0,0,-10))
	local LPos2 = trace.Entity:WorldToLocal(trace.HitPos)
	
	
	local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone)
	if phys and phys:IsValid() then
		LPos2 = phys:WorldToLocal(trace.HitPos)
	end
	
	local constraint, rope = constraint.Rope(chute,trace.Entity,0,trace.PhysicsBone,LPos1,LPos2,0,ropelength,0,1.0,"cable/rope",nil)
	
	chute:DeleteOnRemove(constraint)
	chute:DeleteOnRemove(rope)
	ent:DeleteOnRemove(chute)
	ent.AVehicle_parachute = chute
	
	timer.Simple(10.0, function() 
		if IsValid(chute) then
			chute:Remove()
			if isPlayer and IsValid(ent) and IsValid(ent.ply) then
				ent.ply:SetParent(nil)
				ent:Remove()
			end
		end
	end)
end
*/

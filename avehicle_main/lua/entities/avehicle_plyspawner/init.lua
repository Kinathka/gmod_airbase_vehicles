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
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Is_aVehiclespawn = true

ENT.CDSIgnore = true; -- CDS 
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true;


function ENT:Initialize()

	self.Entity:SetModel( "models/props_c17/streetsign004e.mdl" ) 
	self.Entity:SetName("AVehicle Spawn Point/Beacon")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetColor(Color(20,100,20,255))
	self.Entity:DrawShadow(false)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.PhysObj = self.Entity:GetPhysicsObject()
	
	self.AddPosition = Vector(0,0,5)
	self.EjectPos = self.Entity:GetPos()+self.AddPosition
	
	self.NearVehicle = nil
	
	
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,10)
	
	local ent = ents.Create( "avehicle_plyspawner" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Initialize()
	ent:Activate()
	
	return ent
	
end


function ENT:SpawnCallVehicle(ply, vEnt) --Is called when player spawns here with Alienate Vehicle Function
	ply:Spawn()
	ply:SetPos(self.Entity:GetPos()+Vector(0,0,5))
	ply:SetVelocity(ply:GetUp()*10)
	if IsValid(vEnt) then
		ply:PrintMessage( HUD_PRINTTALK, "You just ejected from a AVehicle spawn beacon! - " .. vEnt:GetName())
	else
		ply:PrintMessage( HUD_PRINTTALK, "You just ejected from a AVehicle that no longer exist!" )
	end
end


function ENT:Think()
	self.EjectPos = self.Entity:GetPos()+self.AddPosition
end


function ENT:Touch( ent )

end

function ENT:Use( ply )
	if  IsValid(ply) then
		local lastdist = self.AVehicleEnterRange * 2
		local nearestEnt = nil
		for k,v in pairs(ents.FindInSphere(self:GetPos(), self.AVehicleEnterRange)) do
			if IsValid(v) and (v.IsAVehicle) then
				local dist = v:GetPos():Distance(self:GetPos())
				if (dist < lastdist) then 
					lastdist = dist 
					nearestEnt = v
				end
			end
		end
		if IsValid(nearestEnt) and nearestEnt.IsAVehicle then
			nearestEnt:GetIn(ply)
		end
	end
end
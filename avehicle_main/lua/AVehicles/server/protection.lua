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
---------------------------------------------------------------Definitions--------------------------------------------
AVehicles.Protection = {}
AVehicles.RegisteredVehicles = {}

---------------------------------------------------------------The Body, Code----------------------------------------

---------------------------------------------------Disable Physiscsgun, add e.NoPhysicsPickup = true to your ent @ Warkanum
function AVehicles.Hooks.PhysgunPickup(p,e)
	if(IsValid(e) and e.NoPhysicsPickup and not AVehicles.debugger) then
		return false
	end
end
hook.Add("GravGunPunt","AVehicles.Hooks.PhysgunPickup",AVehicles.Hooks.PhysgunPickup)
hook.Add("GravGunPickupAllowed","AVehicles.Hooks.PhysgunPickup",AVehicles.Hooks.PhysgunPickup)
hook.Add("PhysgunPickup","AVehicles.Hooks.PhysgunPickup",AVehicles.Hooks.PhysgunPickup)
hook.Add("CanPlayerUnfreeze","AVehicles.Hooks.PhysgunPickup",AVehicles.Hooks.PhysgunPickup)

---------------------------------------------------Disable Tooler add e.NoToolGun = true or e.OnlySpecialToolGun = true  to your ent @ Warkanum
function AVehicles.Hooks.CanTool(p,t,k)
	local e = t.Entity
	if(IsValid(e) and not AVehicles.debugger) then
		local k = k or ""
		if e.NoToolGun then return false end
		if e.OnlySpecialToolGun then 
			if(k:find("dev_link") or k:find("wire") or  ( p:IsAdmin() or p:IsSuperAdmin() ) ) then return end
			return false
		end
		if e.NoDuplicator then	--This is for both the gmod duplicator and adv duplicator
			if (k:find("duplicator")) then
				return false
			end
		end
	end
end
hook.Add("CanTool","AVehicles.Hooks.CanTool",AVehicles.Hooks.CanTool)


--Check if this entity can be used and call custom use function if it can. @ Warkanum
--OMG, Somehow entity and player got switched
function AVehicles.Hooks.PlayerUse(p, e)
	if IsValid(p) and IsValid(e) then
		if (e.isAvehiclePod)  then
			if not IsValid(p:GetVehicle()) then
				e:Avehicle_Use(p, e) --Call custom defined pod function.
			end
			
			--return false
		elseif (e.IsAVehicle) then
			if (e.restrictUse) then
				return false
			end
			if e:CheckIfPlyInPod(p) then --Workaround for weapon seats. So we can't use on ourselfs.
				return false
			end
			--entity:Avehicle_Use(p, e)
		elseif (e.IsAVehicleGadget) then --Check for gagets we can toggle.
			e:Avehicle_Use(p, e)
		end
		
	end
	return true
end
hook.Add( "PlayerUse", "AVehicles.Hooks.PlayerUse", AVehicles.Hooks.PlayerUse)



function AVehicles.Hooks.RegisterVehicle(class)
	return  AVehicles.Hooks.RegisterVehicle(class, 8)
end

--Registers a vehicle for limit checking. @ Warkanum
function AVehicles.Hooks.RegisterVehicle(class, limit)
	if AVehicles.RegisteredVehicles then
		AVehicles.RegisteredVehicles[class] = 0
		CreateConVar("avehicles_max_"..class, (limit or 4), {FCVAR_REPLICATED,FCVAR_NOTIFY, FCVAR_ARCHIVE})
	end
end

function AVehicles.Hooks.PreSpawn(ply, sent_type)
	for k,v in pairs(AVehicles.RegisteredVehicles) do
		if k == sent_type then
			if ConVarExists("avehicles_max_"..sent_type) then
				local max = GetConVar("avehicles_max_"..sent_type):GetInt()
				if (v >= max) and not game.SinglePlayer() then
					ply:PrintMessage(HUD_PRINTCENTER,"You have reached the server limit for this vehicle. ("..sent_type..")")
					MsgN("Max vehicles: "..sent_type.. " Limit: "..tostring(max))
					return false
				end
				return true
			end
			return false
		end
	end
	return
end
hook.Add( "PlayerSpawnSENT", "AVehicles.Hooks.PlayerSpawnSENT", AVehicles.Hooks.PreSpawn)

function AVehicles.Hooks.OnEntityCreated(ent)
	if ent and ent.IsAVehicle then
		--local class = ent:GetClass() --Fucking broken hook, if I getclass here, it returns sent_anim
		local class = ent.EntityName --So now I work around it this way.
		if AVehicles.RegisteredVehicles[class] then
			AVehicles.RegisteredVehicles[class] = AVehicles.RegisteredVehicles[class] + 1
		end
	end
end
hook.Add( "OnEntityCreated", "AVehicles.Hooks.OnEntityCreated", AVehicles.Hooks.OnEntityCreated)

function AVehicles.Hooks.OnRemove(ent)
	if ent and ent.IsAVehicle then
		local class = ent:GetClass()
		if AVehicles.RegisteredVehicles[class] then
			AVehicles.RegisteredVehicles[class] = AVehicles.RegisteredVehicles[class] - 1
		end
	end
end
hook.Add("EntityRemoved", "AVehicles.Hooks.OnRemove", AVehicles.Hooks.OnRemove)

--Check if the player is in a vehicle, then ignore damage.
function AVehicles.Hooks.PlayerShouldTakeDamage(victim, attacker)
	if IsValid(victim) and IsValid(victim:GetVehicle()) 
		and (victim:GetVehicle().isAvehiclePod) and IsValid(victim:GetVehicle().Vehicle) then
			if GetConVarNumber("avehicles_cvar_vehicle_playerdamage") >= 1 then
				return false
			else
				return true
			end
	end
end
hook.Add("PlayerShouldTakeDamage", "AVehicles.Hooks.PlayerShouldTakeDamage", AVehicles.Hooks.PlayerShouldTakeDamage)

/* Must still fix this
-------------------This function is called when the player tries to clip throug a noclip protected object. If the noclip function is registered with the object @ Warkanum
-------------------For noclip protection on you entity, you must add e.CantNoClip = true.
function AVehicles.Hooks.OnNoClip(p,e)
	if e and e.CantNoClip then
		if e.NoClipList then
			for k,p in pairs(e.NoClipList) do
				if p == tEnt then
					return true
				end
			end
		end
		p:SetVelocity( ply:GetVelocity():GetNormal() * -2000 )
		return false
	end
end
hook.Add("AVehicles.Protection.OnNoClip","AVehicles.Hooks.OnNoClip",AVehicles.Hooks.OnNoClip)

-------------------------------------Registers a entity for noclip protection @ Warkanum
-----------The entity Must be registered with this function 
function AVehicles.Protection.RegisterNoClip(e)
	if IsValid(e) and not AVehicles.debugger then
		Msg("Register Noclip! \n")
		e.StartTouch = function(tEnt)
			Msg("NoClipEnvent! \n")
			if ( tEnt and tEnt:IsPlayer() and tEnt:GetMoveType() == MOVETYPE_NOCLIP ) then	
			Msg("NoClipEnvent! ValidPlayer \n")
				hook.Call("AVehicles.Protection.OnNoClip", GAMEMODE, tEnt, e)
			end	
		end --End of the function
	end	
end
*/


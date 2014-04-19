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

function ENT:WeaponsInitialize()
	self.AvWeapons_Loaded = true
	self.AvTargetLazers = {}
	self.AvTargetLazersDraw = {}
	self.HardPointsInstalled = {}
	self.AvWeapons = {}
	self.AvWeaponsAutoRefreshTime = 10
	self.AvWeaponsAutoRefreshTick = 0
	--Setup weapons systems and lazers for pods.
	for i=0, self.PassengerCount, 1 do
		self.AvTargetLazers[i] = nil
		self.AvTargetLazersDraw[i] = false
		self.AvWeapons[i] = {}
		self.AvWeapons[i].Selected = 1
		self.AvWeapons[i].Installed = {}
	end
	self:WeaponsSendNamesToClient()
	self:WeaponsSendSelectedToClient()
end


--Draw's a aim lazer for the given hitpos. @ Warkanum
--To enable self draw, change to: self.AvTargetLazersDraw[i] = true. Or just call this function.
function ENT:TargetLazer(index, show, hitpos)
	if self.UseSightLazer and self.AvTargetLazers then
		if not self.AvTargetLazers[index] and show then
			self.AvTargetLazers[index] = ents.Create("env_sprite");
			self.AvTargetLazers[index]:SetPos( hitpos );
			self.AvTargetLazers[index]:SetKeyValue( "renderfx", "14" )
			self.AvTargetLazers[index]:SetKeyValue( "model", "sprites/glow1.vmt")
			self.AvTargetLazers[index]:SetKeyValue( "scale","0.5")
			self.AvTargetLazers[index]:SetKeyValue( "spawnflags","1")
			self.AvTargetLazers[index]:SetKeyValue( "angles","0 0 0")
			self.AvTargetLazers[index]:SetKeyValue( "rendermode","9")
			self.AvTargetLazers[index]:SetKeyValue( "renderamt","255")
			self.AvTargetLazers[index]:SetKeyValue( "rendercolor", "255 0 0" )				
			self.AvTargetLazers[index]:Spawn()
					
		elseif self.AvTargetLazers[index] and IsValid(self.AvTargetLazers[index]) and show then
			self.AvTargetLazers[index]:SetPos(hitpos)			
		elseif not show and self.AvTargetLazers[index] and IsValid(self.AvTargetLazers[index]) then
			self.AvTargetLazers[index]:Remove()		
			self.AvTargetLazers[index] = nil			
		end
	end
end

--Install a weapon.@ Warkanum
--podindex(Pod Pos. Driver = 0.) wepname(The name. Obvious.) firefunc (Function for pri fire. may be nil) altfirefunc (Function for alt fire. may be nil)
--Return the index of the newly added weapon. 
function ENT:WeaponPostAdd(podindex,wepname,firefunc, altfirefunct)
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons and self.AvWeapons[podindex] then
		self.AvWeapons[podindex].Installed = self.AvWeapons[podindex].Installed or {}
		self.AvWeapons[podindex].fire = self.AvWeapons[podindex].fire or {}
		self.AvWeapons[podindex].altfire = self.AvWeapons[podindex].altfire or {}
		self.AvWeapons[podindex].Selected = self.AvWeapons[podindex].Selected or 1
		
		local index = table.getn(self.AvWeapons[podindex].Installed) + 1
		local firstopen = index
		for k,v in pairs(self.AvWeapons[podindex].Installed) do
			if not v or (v and v == "") then
				firstopen = k
				break
			end
		end
		index = firstopen
		self.AvWeapons[podindex].Installed[index] = wepname
		self.AvWeapons[podindex].fire[index] = firefunc
		self.AvWeapons[podindex].altfire[index] = altfirefunct

		self:WeaponsSendNamesToClient()
		self:WeaponsSendSelectedToClient()
		return index
	end
	return nil
end

--e wep. @ Warkanum
function ENT:WeaponSetHardpoint(podindex,wepindex,hardpointid)
	if self.AvWeapons and wepindex and self.AvWeapons[podindex] and self.AvWeapons[podindex].Installed then
		self.AvWeapons[podindex].hardpoints = self.AvWeapons[podindex].hardpoints or {}
		self.AvWeapons[podindex].hardpoints[wepindex] = hardpointid
	end
end


function ENT:WeaponPostRemove(podindex,wepname)
	if not self.AvWeapons_Loaded then return false end
	if self.AvWeapons and self.AvWeapons[podindex] then
		if self.AvWeapons[podindex].Installed then
			for k,v in pairs(self.AvWeapons[podindex].Installed) do
				if tostring(v) == tostring(wepname) then
					self.AvWeapons[podindex].Installed[k] = ""
					--table.remove(self.AvWeapons[podindex].Installed, tonumber(k))
					self:WeaponsSendNamesToClient()
					return true
				end
			end
		end
	end
end

function ENT:FireActiveWeapon(plypos)
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons and self.AvWeapons[plypos] then
		local sel = self.AvWeapons[plypos].Selected or 0
		local wiretbl = {}
		wiretbl.podindex = plypos
		wiretbl.prifire = false
		wiretbl.secfire = true
		if self.AvWeapons[plypos].fire and self.AvWeapons[plypos].fire[sel] then
			self.AvWeapons[plypos].fire[sel]()
			wiretbl.fire = true
		else
			wiretbl.fire = false
		end
		self:WireTriggerOutput("Fires", wiretbl)
	end
end


function ENT:AltFireActiveWeapon(plypos)
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons and self.AvWeapons[plypos] then
		local sel = self.AvWeapons[plypos].Selected or 0
		local wiretbl = {}
		wiretbl.prifire = false
		wiretbl.secfire = true
		wiretbl.podindex = plypos
		if self.AvWeapons[plypos].altfire and self.AvWeapons[plypos].altfire[sel] then
			self.AvWeapons[plypos].altfire[sel]()	
			wiretbl.fire = true
		else
			wiretbl.fire = false
		end
		self:WireTriggerOutput("Fires", wiretbl)
	end
end

function ENT:WeaponsSendSelectedToClient()
	if not self.AvWeapons_Loaded then return end
	local wiretbl = {}
	if self.AvWeapons then
		local wepStr = ""
		for k=0, self.PassengerCount, 1 do
			if self.AvWeapons[k] and (self.AvWeapons[k].Selected >= 0) then
				wepStr = wepStr ..""..tostring(k).."="..tostring(self.AvWeapons[k].Selected)..","
				wiretbl[k] = self.AvWeapons[k].Selected
			end
		end
	self.Entity:SetNetworkedString("AVehicle_Weapons_selected", wepStr)
	self:WireTriggerOutput("ActiveWeapons", wiretbl)
	end
end

/*
function ENT:WeaponsSendHardpointsToClient()
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons then
		local wepStr = ""
		for k=0, self.PassengerCount, 1 do
			if self.AvWeapons[k] and self.AvWeapons[k].hardpoints then
				wepStr = wepStr..tostring(k).."|"
				for kk,v in pairs(self.AvWeapons[k].hardpoints) do
					if v and (type(v) != "table") then
						wepStr = wepStr..tostring(kk).."@"..tostring(v)..","
					end
				end
				wepStr = wepStr..";"
			end
		end
		self.Entity:SetNetworkedString("AVehicle_Weapons_hardpointents", wepStr)
		MsgN("hardpoints str: "..wepStr)
		PrintTable(self.AvWeapons)
	end
end
*/

function ENT:WeaponsSendNamesToClient()
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons then
		local wepStr = ""
		local wiretbl = {}
		for k=0, self.PassengerCount, 1 do
			if self.AvWeapons[k] and self.AvWeapons[k].Installed then
				wiretbl[k] = wiretbl[k] or {}
				wepStr = wepStr..tostring(k).."|"
				for kk,v in pairs(self.AvWeapons[k].Installed) do
					if v and (type(v) != "table") then
						wepStr = wepStr..tostring(v)..","
						wiretbl[k][kk] = v
					else
						wepStr = wepStr.." "..","
						wiretbl[k][kk] = nil
					end
				end
				wepStr = wepStr..";"
			end
		end
		self.Entity:SetNetworkedString("AVehicle_Weapons_names", wepStr)
		self:WireTriggerOutput("Weapons", wiretbl)
	end
	self.Entity:SetNetworkedBool("AVehicle_Weapons_isUpdating", true)
	timer.Simple(2.0, function() 
		if IsValid(self) then
			self.Entity:SetNetworkedBool("AVehicle_Weapons_isUpdating", false)
		end
	end)
end


function ENT:NextWeapon(PlyPos, forward)
	if not self.AvWeapons_Loaded then return end
	if self.AvWeapons and self.AvWeapons[PlyPos] then
		if self.AvWeapons[PlyPos].Installed then
			if forward then
				self.AvWeapons[PlyPos].Selected = self.AvWeapons[PlyPos].Selected + 1
			else
				self.AvWeapons[PlyPos].Selected = self.AvWeapons[PlyPos].Selected - 1
			end
			
			if (self.AvWeapons[PlyPos].Selected > table.Count(self.AvWeapons[PlyPos].Installed)) then
				self.AvWeapons[PlyPos].Selected = 1
			elseif (self.AvWeapons[PlyPos].Selected <= 0) then
				self.AvWeapons[PlyPos].Selected = table.Count(self.AvWeapons[PlyPos].Installed)
			end
			
		end
		self:WeaponsSendSelectedToClient() -- send the selected weapons to clientside
	end
end

function ENT:GetSelectedWeapon(PlyPos)
	if not self.AvWeapons_Loaded then return "" end
	if self.AvWeapons and self.AvWeapons[PlyPos] then
		if self.AvWeapons[PlyPos].Installed then
			if self.AvWeapons[PlyPos].Installed[self.AvWeapons[PlyPos].Selected] then
				return self.AvWeapons[PlyPos].Installed[self.AvWeapons[PlyPos].Selected]
			end
		end
	end
	return ""
end

--Helper to se if a weapon is selected. Not case sensitive. @ Warkanum
function ENT:isSelectedWeapon(PlyPos,name)
	if not self.AvWeapons_Loaded then return false end
	if string.lower(self:GetSelectedWeapon(PlyPos)) == string.lower(name) then
		return true
	end
	return false
end


function ENT:WeaponsOnRemove()
	self.AvWeapons_Loaded = false
end


------------------Built in weapons @ Warkanum--------------------

--Flares @ Warkanum
function ENT:FlaresDeploy(count, ttl)
	local velmul = 8.0
	for i=1, count, 1 do
		local flr = ents.Create( "avehicle_wep_flare" )
		local fwd = self.Entity:GetForward()
		local up = self.Entity:GetUp()
		local right = self.Entity:GetRight()
		flr:SetPos( self.Entity:GetPos() + (up*i*50) + (fwd * -200*i) + (right*-100) + (right*10*i) ) 
		flr:SetAngles(self.Entity:GetAngles())
		flr.TimeToLive = ttl
		flr:Spawn()
		flr:Activate() 
		local speed = self.Entity:GetVelocity():Length()
		local phys = flr:GetPhysicsObject() or nil
		if phys and phys:IsValid() then
			phys:SetVelocity((math.Rand(0.1,1.5)*0.5*speed*fwd*velmul) + (math.Rand(0.1,1.5)*speed*2.0*up*velmul*i) + (math.Rand(0.1,1.5)*0.5*speed*right*velmul*i) )
		end
	end
end


/*Hardpints ===========================================================*/


function ENT:GetHardpoint(id, kind)
	if not self.AvWeapons_Loaded then return nil end
	if not self.HasHardPoints then return nil end
	for k = 1, #self.AVHardPoints do
		if self.AVHardPoints[k] and (self.AVHardPoints[k].id == id) and (self.AVHardPoints[k].kind == kind) then
			return self.AVHardPoints[k]
		end
	end
	return nil
end

function ENT:GetHardpoints(kind)
	if not self.AvWeapons_Loaded then return {} end
	if not self.HasHardPoints then return {} end
	local hps = {}
	for k = 1, #self.AVHardPoints do
		if self.AVHardPoints[k] and  AVehicles.Types.HardPointMatchLogic(kind, self.AVHardPoints[k].kind) then
			table.insert(hps, self.AVHardPoints[k])		
		end
	end
	return hps
end

--Check if this hardpoint has been used (false) or not (true). @ Warkanum
function ENT:HardpointIsAvailable(hp)
	if not self.AvWeapons_Loaded then return false end
	if not self.HasHardPoints then return false end
	if hp and self.HardPointsInstalled and hp.id then
		if self.HardPointsInstalled[hp.id] and self.HardPointsInstalled[hp.id].Installed and IsValid(self.HardPointsInstalled[hp.id].ent) then
			return false
		end
	end
	return true
end

--Install a hardpoint entity to the vehicle. @ warkanum
function ENT:HardpointInstall(hardpoint, pod, ent, weld, ballsoc, parent, nocollide)
	if not self.AvWeapons_Loaded then return false end
	if not self.HasHardPoints then return false end
	if hardpoint and pod and ent then
		--register the hardpoint
		if self.HardPointsInstalled and self.HardPointsInstalled[hardpoint.id] and 
		self.HardPointsInstalled[hardpoint.id].Installed and IsValid(self.HardPointsInstalled[hardpoint.id].ent) then
			print("Hardpoint object already exist in that slot id!")
			return false
		end
			
		self.HardPointsInstalled[hardpoint.id] = {}
		self.HardPointsInstalled[hardpoint.id].kind = hardpoint.kind
		self.HardPointsInstalled[hardpoint.id].Installed = true
		self.HardPointsInstalled[hardpoint.id].ipod = pod
		--Add the ettached entity to list
		self.HardPointsInstalled[hardpoint.id].ent = ent
		--Set position and weld it.
		ent:SetPos(self.Entity:LocalToWorld(hardpoint.pos))
		ent:SetAngles(self.Entity:LocalToWorldAngles(hardpoint.ang))
		if ent.HardPointAngleAdd then
			ent:SetAngles(self.Entity:LocalToWorldAngles(hardpoint.ang + ent.HardPointAngleAdd))
		end
		
		
		--Do we parent it?
		if parent or ent.AVehicleHardpointParent then
			ent:SetParent(self.Entity)
			--ent:SetPos(self.Entity:LocalToWorld(hardpoint.pos))
			--ent:SetAngles(self.Entity:LocalToWorldAngles(hardpoint.ang))
		end
	
		--Do we weld it?
		if weld or ent.AVehicleHardpointWeld then
			local wEnt, const = constraint.Weld(self.Entity,ent,0,0,0,true)
			self.HardPointsInstalled[hardpoint.id].weldonstraint = const
			self.HardPointsInstalled[hardpoint.id].weldent = wEnt
			ent:DeleteOnRemove(wEnt)
		end
		
		if not (weld or ent.AVehicleHardpointWeld) and ballsoc then
			local wEnt = constraint.Ballsocket(ent,self.Entity,0,0,hardpoint.pos,0,0,1)
			self.HardPointsInstalled[hardpoint.id].weldent = wEnt
			ent:DeleteOnRemove(wEnt)
		end
		
		--this is crap, always allow collisions.
		--Can we collide with anything after connected?
		--local col = not 
		--if ent.AVehicleHardpointPostNocollide then
		--	col = false
		--elseif nocollide and not ent.AVehicleHardpointPostNocollide then
		--
		--end
		--local phys = ent:GetPhysicsObject()
		--if not col and phys and phys:IsValid() then
		--	phys:EnableCollisions(false)
		--end
		
		self:HardpointsSendToClient()
		
		--register the weapon function if we are a weapon.
		if ent.IsAVehicleWeaponHP then
			local wepname = ent.AVehicleWepName or "Error_NoName"
			wepname = tostring(hardpoint.id).."-"..wepname
			local wepindex = self:WeaponPostAdd(pod, wepname, function()
				if IsValid(ent) and ent.IsAVehicleAttachable then
					ent:DoFire()
				end
			end,function()
				if IsValid(ent) and ent.IsAVehicleAttachable then
					ent:DoAltFire()
				end
			end)
			--Set additional weapon info
			self:WeaponSetHardpoint(pod,wepindex,hardpoint.id)
		end
		--register the call on remove function.
		ent:CallOnRemove("AVHardPointRemove", function() 
			if IsValid(self) and self.WeaponsSendNamesToClient then
					self:WeaponPostRemove(pod,wepname)
					--MsgN("Updating weapon list...")
			end
		end)
		
		
		
		return true --true if we have been attached.
	end
	return false
end

function ENT:HardpointsSendToClient()
	if not self.AvWeapons_Loaded then return end
	if self.HardPointsInstalled then
		local idStr = ""
		for k,v in pairs(self.HardPointsInstalled) do
			if v and v.ent  then
				idStr = idStr ..""..tostring(k).."="..tostring(v.ent:EntIndex())..";"
			end
		end
	self.Entity:SetNetworkedString("AVehicle_Hardpoints_IdAndEntsId", idStr)
	end
end

--Release the hardpoint entity. We want to use it elsewhere or shoot it. @ Warkanum
function ENT:HardpointRelease(id)
	if not self.AvWeapons_Loaded then return false end
	if not self.HasHardPoints then return false end
	if id then
		if self.HardPointsInstalled and self.HardPointsInstalled[id] then
			if IsValid(self.HardPointsInstalled[id].weldent) then
				self.HardPointsInstalled[id].weldent:Remove()
			end
			if IsValid(self.HardPointsInstalled[id].ent) then
				self:WeaponPostRemove(self.HardPointsInstalled[id].ent.ipod,self.HardPointsInstalled[id].ent.AVehicleWepName)
				self.HardPointsInstalled[id].ent:SetParent(nil)
				self.HardPointsInstalled[id].ent = nil
				self.HardPointsInstalled[id].Installed = false
				return true
			end
		end
		self:HardpointsSendToClient()
	end
	return false
end

--Remove the hardpoint entity. We actaully delete it here. @ Warkanum
function ENT:HardpointRemove(id)
	if not self.AvWeapons_Loaded then return false end
	if not self.HasHardPoints then return false end
	if id then
		if self.HardPointsInstalled and self.HardPointsInstalled[id] then
			if self.HardPointsInstalled[id].ent then
				self:WeaponPostRemove(self.HardPointsInstalled[id].ent.ipod,self.HardPointsInstalled[id].ent.AVehicleWepName)
				self.HardPointsInstalled[id].ent:Remove()
				self.HardPointsInstalled[hardpoint.id].Installed = false
				return true
			end
			self:HardpointsSendToClient()
		end
	end
	return false
end

--Clear weapons status for invalid hardpoints @ Warkanum
function ENT:HardpointsClearWeaponStatus()
	if not self.AvWeapons_Loaded then return false end
	if not self.HasHardPoints then return false end
	if self.HardPointsInstalled then
		for k,v in pairs(self.HardPointsInstalled) do
			for tk,tv in pairs(self.AvWeapons) do
				if tv.hardpoints then
					for wk,wv in pairs(tv.hardpoints) do
						if wv == k then
							if not v.ent or not IsValid(v.ent) then
								self:WeaponPostRemove(tk, self.AvWeapons[tk].Installed[wk])
							end
						end
					end
				end
			end
		end
	end
	return false
end
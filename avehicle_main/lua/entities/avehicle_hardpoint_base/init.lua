
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.CDSIgnore = true -- CDS 
ENT.hasdamagecase = true -- GCombat

util.AddNetworkString( "AVehicles_HardPoint_Menu" );

function ENT:Initialize()
	self.HardPointInstalled = false
	self.HardPointIsValidating = false
	self.AVehicle_ent = nil
	self.AVehicle_hpid = -1
	self.AVehicle_InstallOptions = {}
	self.AVehicle_podpos = -1
	self.AVehicle_Creator = nil
	self.AVehicle_ControllingPlayer = nil
	self.AVehicle_HardPointKind = 0 --What slot type have we been installed?
	self.WireCreateInputs(self, "fire", "altfire")
	self.PrimaryActive = false
	self.SecondaryActive = false
	--ENT.HardPointKind is for the slot we support. We may support a slot but we also work on a universal slot.
end

function ENT:gcbt_breakactions(damage, pierce) 

end

/*
function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16 + Vector(0,0,50)
	
	local ent = ents.Create( "avehicle_searchlight" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	ent.AVehicle_Creator = ply --This is important for all my vehicles and all my entities. Please put that in.
	
	return ent
	
end
*/

function ENT:Think()
	if self.PrimaryActive then
		self:DoFire()
	end
	if self.SecondaryActive then
		self:DoAltFire()
	end
	self:NextThink( CurTime() + 0.001 )
	return true
end
	
function ENT:TriggerInput(k,v)
	if(k == "fire") then
		if v and (tonumber(v) >= 1) then
			self:StartFiring()
		else
			self:StopFiring()
		end
	elseif(k == "altfire")  then
		if v and (tonumber(v) >= 1) then
			self:StartAltFiring()
		else
			self:StopAltFiring()
		end
	end
end


function ENT:GetVehicleInstalledPod()
	return self.AVehicle_podpos
end

function ENT:GetAVehicle()
	if IsValid(self.AVehicle_ent) then
		return self.AVehicle_ent
	end
	return nil
end

function ENT:GetVehicleAim(pod)
	if self.AVehicle_ent and IsValid(self.AVehicle_ent) then
		if self.AVehicle_ent.Passengers and self.AVehicle_ent.Passengers[pod] then
			local vc = self.AVehicle_ent:CalcAimVectors(self.AVehicle_ent.Passengers[pod])
			return vc
		else
			return (self.AVehicle_ent:GetForward() * 90000)
		end
	end
	return Vector(0,0,0)
end

function ENT:ValidCreator()
	if self.AVehicle_Creator and IsValid(self.AVehicle_Creator) and self.AVehicle_Creator:IsPlayer() then
		return true
	end
	return false
end

function ENT:DoFire()
	--print("Base Hardpoint Firing! (If you see this, you need to override the ENT:DoFire() function.)")
end

function ENT:DoAltFire()
	--print("Base Hardpoint Alt Firing! (Developer: If you see this, you need to override the ENT:DoAltFire() function.)")
end

function ENT:StartFiring()
	self.PrimaryActive = true
end

function ENT:StopFiring()
	self.PrimaryActive = false
end

function ENT:StartAltFiring()
	self.SecondaryActive = true
end

function ENT:StopAltFiring()
	self.SecondaryActive = false
end


--When we touch we want to get the vehicle we touched and install ourself to it. @ Warkanum
function ENT:Touch(ent)
	if not self.HardPointInstalled and IsValid(ent) then
		if not self.HardPointIsValidating then
			self:InstallHardPoint(ent)
		end
	end
end

--Start to install hardpoint, check if there are any available etc. @ Warkanum
function ENT:InstallHardPoint(veh)
	if not self.HardPointInstalled and veh and veh.IsAVehicle and self:ValidCreator() then
		local validhps = ""
		local first = true
		for _,v in pairs(veh:GetHardpoints(self.HardPointKind)) do
			if veh:HardpointIsAvailable(v) then
				if first then
					first = false
					validhps = validhps..""..tostring(v.id)
				else
					validhps = validhps..","..tostring(v.id)
				end
			end
		end
		self:OpenClientWindow(self.AVehicle_Creator,veh, validhps)
		return true
	end
	return false
end

--Open client settings window @ warkanum
function ENT:OpenClientWindow(ply, ent, validhps)
	if (not IsValid(ent)) or (not IsValid(ply)) then return false end
	self.HardPointIsValidating = true
	net.Start("AVehicles_HardPoint_Menu");
	net.WriteInt(tonumber(ent:EntIndex()), 32);
	net.WriteInt(tonumber(self:EntIndex()), 32);
	net.WriteInt(tonumber(ent.PassengerCount), 8);
	net.WriteString(validhps);
	net.Send(ply);
	return true
end

--After we have the hardpoint settings, we finally install it to both the vehicle and entity. @ Warkanum
function ENT:FinaliseHardPoint(veh,ply,hpid,pod, weld, parent, nocollide)
	if not self.HardPointInstalled and not self.HardPointReturned and veh.IsAVehicle then
		for _,v in pairs(veh:GetHardpoints(self.HardPointKind)) do
			if veh:HardpointIsAvailable(v) and v.id == hpid then
				self.HardPointInstalled = true
				self.HardPointIsValidating = false
				--Just inform the player that pod position will be overridden. This is usefull for certain hardpoints like sideguns.
				if v.pod and v.pod >= 0 and ply and IsValid(ply) then
					ply:ChatPrint("Pod position overridden by code rules. From "..tostring(pod).." to "..tostring(v.pod))
					pod = v.pod
				end
				self.AVehicle_hpid = hpid
				self.AVehicle_HardPointKind = v.kind
				self.AVehicle_ent = veh
				self.AVehicle_podpos = pod
				local ballsoc = false
				if self.AVDebug then
					print("\nHardpoint Should weld: ", weld)
					print("\nHardpoint Should parent: ", parent)
					print("\nHardpoint Should nocollide: ", nocollide)
				end
				--Overrides for installing type.
				if weld and self.AVehicleHardpointPostBallSockInsteadOfWeld and (self.AVehicle_HardPointKind == AVehicles.Types.HARDPOINT_AIMABLE) then
					weld = false
					ballsoc = true
					parent = false
				elseif weld and (self.AVehicle_HardPointKind == AVehicles.Types.HARDPOINT_AIMABLE) then
					weld = false
					ballsoc = false
					parent = true
				end
				self.AVehicle_InstallOptions.weld = weld
				self.AVehicle_InstallOptions.ballsoc = ballsoc
				self.AVehicle_InstallOptions.parent = parent
				self:SetOwner(veh)
				local rval = veh:HardpointInstall(v, pod, self, weld, ballsoc, parent, nocollide)
				if rval then self:FinishedInstall(veh) end
				return rval
			end
		end
	end
	return false
end

--Use this in child entites. It's called after install of hardpoint. @ Warkanum
function ENT:FinishedInstall(veh)

end

--Hook for hardpoints callback. To get and set settings for hardpoints.
function AVehicles.HardPointCallback( ply, cmd, args)
    if ply and IsValid(ply) and args[1] and args[2] and args[3] and args[4] and args[5] and args[6] then
		
		local veh = ents.GetByIndex(tonumber(args[1]))
		local ett = ents.GetByIndex(tonumber(args[2]))
		local hpid = tonumber(args[6])
		local pod = tonumber(args[3])
		local weld = false
		if tonumber(args[4])  > 0 then weld = true end
		local parent = true
		if veh and ett and IsValid(veh) and IsValid(ett) and ett.IsAVehicleAttachable then
			if weld then
				parent = false
			else
				parent = true
			end
			local nocollide = tobool(args[5]) or true
			if tonumber(args[5]) > 0 then nocollide = true end
			ett:FinaliseHardPoint(veh,ply,hpid,pod,weld,parent,nocollide)
		end
	end
end
concommand.Add( "AVehicles_HardPoint_setting", AVehicles.HardPointCallback)
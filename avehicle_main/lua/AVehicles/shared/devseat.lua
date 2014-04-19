if (SERVER) then
	util.AddNetworkString( "AVehicle-Seats-Entered" );
	
	hook.Add("KeyPress", "Weapon:Seats:KeyPress", function(ply, key)
		if not IsValid(ply) then return end
		local seat = ply:GetNWEntity("AVehicleSeatEntity");
		if ply:GetNWBool("AVehicleSeatOccupied") and key == IN_USE and not ply:KeyDown(IN_WALK) and IsValid(seat) 
			and not (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK)) then
			if not seat.Locked and not seat.AVehiclesNonExit then 
				seat:ExitSeat(ply);
			end
		end
	end)

	hook.Add("PlayerDeath", "Weapon:Seats:PlayerDeath", function(ply)
		if not IsValid(ply) then return end
		local seat = ply:GetNWEntity("AVehicleSeatEntity");
		if ply:GetNWBool("AVehicleSeatOccupied") and IsValid(seat) then
			seat:ExitSeat(ply);
		end
	end)

	hook.Add("CanPlayerEnterVehicle", "Weapon:Seats:CanPlayerEnterVehicle", function(ply, vehicle)
		if ply:GetNWBool("AVehicleSeatOccupied") then
			return false;
		end
	end)

end

if (CLIENT) then
	hook.Add("ShouldDrawLocalPlayer", "AVehicle:Seat:ShouldDrawLocalPlayer", function()
		if IsValid(LocalPlayer()) 
			and GetConVar("gmod_vehicle_viewmode")
			and GetConVar("gmod_vehicle_viewmode"):GetBool() 
			and LocalPlayer():GetNWBool("AVehicleSeatOccupied") then 
			--if LocalPlayer():GetNWBool("avehicle_seat_hideplayermodel") then return false end
			return true;
		end
	end);
	
	/*
	Now updating in the UpdateAnimation hook, much fucking better....
	hook.Add("RenderScene", "AVehicle:Seat:RenderScene", function()
		for key, ply in pairs(player.GetAll()) do
			local seat = ply:GetNWEntity("AVehicleSeatEntity");
			if IsValid(seat) and IsValid(ply) and ply:GetNWBool("AVehicleSeatOccupied") then
				local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
				local angles = seat:GetAngles();
				angles:RotateAroundAxis(seat:GetUp(), 90);
				ply:SetNoDraw(true);
				ply:SetAngles(angles);
				ply:SetRenderAngles(angles);
				ply:SetPos(posang.Pos);
				ply:SetRenderOrigin(posang.Pos);
				ply:SetNoDraw(false);
				local angle = AVehicles.Tools.NormalizeAngle(ply:EyeAngles().y-90)/180;
				ply:SetPoseParameter("body_yaw", angle*29.7);
				ply:SetPoseParameter("spine_yaw", angle*30.7);
				ply:SetPoseParameter("aim_yaw", angle*52.5);
				ply:SetPoseParameter("head_yaw", angle*30.7);
			end
		end
	end);
	*/
	
	hook.Add("CalcView", "AVehicle_Seat_CalcView2", function(ply,origin,angles,fov,nearZ,farZ)
		local seat = ply:GetVehicle();
		if IsValid(ply) and ply:GetNWBool("AVehicleSeatOccupied") and IsValid(seat) and seat.isAVehicleSeat and not (seat.isAvehiclePod) then
			if (gmod_vehicle_viewmode and gmod_vehicle_viewmode:GetInt() == 1) then
				-- and (ply:ShouldDrawLocalPlayer() or ply:GetNWBool("avehicle_seat_hideplayermodel")) then
				local view = {};
				local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
				local tracedata = {}
				tracedata.start = posang.Pos + (posang.Ang:Up() * 25)
				tracedata.endpos = posang.Pos +  (posang.Ang:Up() * 25) 
							+ (angles:Forward() * (-1*seat.ThirdViewDistance)) ;
				tracedata.filter = {seat, ply};
				tracedata.mins = Vector(-5,-5,-5);
				tracedata.maxs = Vector(5,5,5);
				tracedata.mask =  MASK_SOLID_BRUSHONLY + MASK_PLAYERSOLID_BRUSHONLY + CONTENTS_SOLID;
				--local trace =  util.TraceHull(tracedata);
				local trace =  util.TraceHull(tracedata);
				view.angles = angles;
				view.origin = trace.HitPos + (posang.Ang:Up() * 25);
				view.fov = fov;	
				if (AVehicles) and (AVehicles.Vehicle) and (AVehicles.Vehicle.IsIn) then
					return GAMEMODE:CalcView(ply, view.origin, view.angles, fov);
				else
					return view;
				end
				
			else
				local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
				return GAMEMODE:CalcView(ply,posang.Pos + posang.Ang:Up() * 25,angles,fov)
			end
		end
		return GAMEMODE:CalcView(ply,origin,angles,fov,nearZ,farZ)
	end);
	
	if game.SinglePlayer() then
		local x = 0
		local y = 0
		hook.Add("CreateMove", "AVehicle:Seat:CreateMove", function(ucmd)
			if LocalPlayer():GetNWBool("AVehicleSeatOccupied") then
				if LocalPlayer():KeyDown(IN_USE) and LocalPlayer():KeyDown(IN_ATTACK) 
					and (IsValid(LocalPlayer():GetActiveWeapon()) 
					and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun") then return end
				
				local sensitivity = 50
				x = x + (ucmd:GetMouseX() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_yaw") < 0 and -sensitivity or sensitivity))
				y = y + (ucmd:GetMouseY() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_pitch") < 0 and -sensitivity or sensitivity))
				y = math.Clamp(y,-89,89)
				ucmd:SetViewAngles(Angle(y,-x,0))
				return true
			end
		end);
	end

	net.Receive("AVehicle-Seats-Entered", 
		function( length, client )
			local ply = net.ReadEntity();
			local vehicle = net.ReadEntity();
			hook.Call("PlayerEnteredVehicle", gmod.GetGamemode(), ply, vehicle, 1);
		end
	)
	
end

hook.Add( "Move", "Weapon:Seats:Move", function( ply, data )
	if not IsValid(ply) then return end
	local seat = ply:GetNWEntity("AVehicleSeatEntity");
	if ply:GetNWBool("AVehicleSeatOccupied") and IsValid(seat) then
		local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
		data:SetVelocity(seat:GetVelocity());
		ply:SetAngles(seat:GetAngles());
		return true;
	end
end)

hook.Add("SetupMove", "Weapon:Seats:SetupMove", function(ply, data)
	if not IsValid(ply) then return end
	local seat = ply:GetNWEntity("AVehicleSeatEntity");
	if ply:GetNWBool("AVehicleSeatOccupied") and IsValid(seat) then
		local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
		data:SetVelocity(seat:GetVelocity());
		data:SetOrigin(posang.Pos+posang.Ang:Up()*25);
		return true;
	end
end)


local translated_sit = {
	pistol = "sit_pistol",
	smg = "sit_smg1",
	grenade = "sit_grenade",
	ar2 = "sit_ar2",
	shotgun = "sit_shotgun",
	rpg = "sit_rpg",
	physgun = "sit_gravgun",
	crossbow = "sit_crossbow",
	melee = "sit_melee",
	slam = "sit_slam",
	normal = "sit_rollercoaster",
}

local function TranslateStandToSit(weapon)
	if not IsValid(weapon) then return "sit_rollercoaster" end
	return translated_sit[weapon:GetHoldType()] or "sit_rollercoaster";
end

/*
hook.Add("UpdateAnimation", "WeaponSeats:UpdateAnimation", function(ply)
	if IsValid(ply) and ply:GetNWBool("AVehicleSeatOccupied") and IsValid(ply:GetNWEntity("AVehicleSeatEntity")) then
		if IsValid(ply:GetActiveWeapon()) then
			ply:SetSequence(TranslateStandToSit(ply:GetActiveWeapon()));
		end
		local seat = ply:GetNWEntity("AVehicleSeatEntity");
		if (CLIENT) and IsValid(seat) then
			local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"));
			local angles = seat:GetAngles();
			angles:RotateAroundAxis(seat:GetUp(), 90);
			--ply:SetNoDraw(true);
			ply:SetAngles(angles);
			ply:SetRenderAngles(angles);
			ply:SetPos(posang.Pos);
			ply:SetRenderOrigin(posang.Pos);
			--ply:SetNoDraw(false);
			local angle = AVehicles.Tools.NormalizeAngle(ply:EyeAngles().y-90)/180;
			ply:SetPoseParameter("body_yaw", angle*29.7);
			ply:SetPoseParameter("spine_yaw", angle*30.7);
			ply:SetPoseParameter("aim_yaw", angle*52.5);
			ply:SetPoseParameter("head_yaw", angle*30.7);
		end
		return true;
	end
end)
*/
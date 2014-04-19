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
SWEP.Category 			= "AVehicles"
SWEP.PrintName			= "Remote for Puddle Jumper V29 "	
SWEP.Author             = "Warkanum"
SWEP.Contact            = "we.alienate@gmail.com"
SWEP.Purpose            = "Remote control for Puddle Jumper v29"
SWEP.Instructions       = "Turn on/off the jumper engine. Cloak it. Open door."
SWEP.Slot = 1
SWEP.SlotPos = 5
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false

if CLIENT then
	-- Inventory Icon
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/jumper29remote_inventory")
	language.Add("jumper29_remote","Jumper V2.9 Remote")
	language.Add("avehicle_puddlejumperv29","Jumper V2.9")
end


//Function Details
SWEP.FindRange = 2048

// Weapon Details
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

// Sound
local ShootSound = Sound ("buttons/blip2.wav")
local SelectSound = Sound ("buttons/button18.wav")
local SearchSound = Sound ("weapons/physgun_off.wav")
local EquipSound = Sound ("buttons/button11.wav")

// Functions
local FUNCTION_MAX = 3
local FUNCTION_MIN = 1
local functionIndex = 1
local functions = {}
functions[1] = "Toggel Door"
functions[2] = "Toggel Cloak"
functions[3] = "Toggel Engine"


function SWEP:Initialize()
	self.Jumper = nil
	self.lastFound = true
	self:SetWeaponHoldType( self.HoldType )
end

--Helper to keep the selected functions in bounds. @ Warkanum
local function FunctionNext(forward)
	if forward then
		functionIndex = functionIndex + 1
	else
		functionIndex = functionIndex - 1
	end
	
	if functionIndex > FUNCTION_MAX then
		functionIndex = FUNCTION_MIN
	elseif functionIndex < FUNCTION_MIN then
		functionIndex = FUNCTION_MAX
	end
end
 
-- Find all jumpers near this position and in this radius @ Warkanum
local function FindNearJumpers(pos,radius)
	if not SERVER then return {} end
	local allents = ents.FindInSphere(pos,radius)
	local jumpers = {}
	for _,v in pairs(allents) do
		if v and v.IsAVehicle then
			if v:GetClass() == "avehicle_puddlejumperv29" then
				table.insert(jumpers, v)
			end
		end
	end
	return jumpers
end

--Filter the jumpers to only the one that is nearest to the position. @ Warkanum
local function FilterToNearest(pos,dist,jumpers)
	if not SERVER then return nil end
	local jumper = nil
	if jumpers then
		for _,v in pairs(jumpers) do
			local j_dist = (pos - v:GetPos()):Length()
			if(dist >= j_dist) then
				dist = j_dist
				jumper = v
			end
		end	
	end
	return jumper
end

--Toggel the jumpers door. @ Warkanum
local function JumperToggelDoor(jumper)
	if jumper and jumper.Passengers then
		if jumper.BaseOpen then
			jumper:SetDoor(false)
		else
			jumper:SetDoor(true)
		end
	end
end

--Toggel the jumpers cloak only if not driver is in. @ Warkanum
local function JumperToggelCloak(jumper)
	if jumper and jumper.Passengers then
		if jumper.Passengers[0] and IsValid(jumper.Passengers[0]) then
			--Ignore the cloak if there is a driver in.
		else
			if jumper.CloakisActive then
				jumper.CloakisActive = false
				jumper:CloakStatus(false)
			else
				jumper.CloakisActive = true
				jumper:CloakStatus(true, true)
			end
		end
	end
end

--Toggel the jumpers engine only if not driver is in. @ Warkanum
local function JumperToggelEngine(jumper)
	if jumper and jumper.Passengers then
		if jumper.Passengers[0] and IsValid(jumper.Passengers[0]) then
			--Ignore the engine if there is a driver in.
		else
			if jumper:EngineIsActive() then
				jumper:EngineOff()
			else
				jumper:EngineOn()
			end
		end
	end
end

--Set Swep clientinfo, for hud. @ Warkanum
local function SetJumperClientInfo(swep,jumper)
	if jumper and swep then
		if jumper:EngineIsActive() then 
			swep:SetNWBool("avehicles_jumper29_engine", true) 
		else
			swep:SetNWBool("avehicles_jumper29_engine", false) 
		end
		if jumper.CloakisActive then
			swep:SetNWBool("avehicles_jumper29_cloak", true) 
		else
			swep:SetNWBool("avehicles_jumper29_cloak", false) 
		end
		if jumper.BaseOpen then
			swep:SetNWBool("avehicles_jumper29_door", true) 
		else
			swep:SetNWBool("avehicles_jumper29_door", false) 
		end
	end
end

--Search for nearby puddle jumpers @ Warkanum
function SWEP:Reload()
	if CLIENT then self:EmitSound(SearchSound, 50, 180) end
	if not SERVER then return end--Server Code
	
	if self.lastFound then --We don't want client calling this too fast and too much.
		self.lastFound = false
		
		local jumpers = FindNearJumpers(self:GetPos(),self.FindRange)
		self.Jumper = FilterToNearest(self:GetPos(), self.FindRange, jumpers)
		self.Owner.AvJumper29 = self.Jumper --Save the jumper to owner for later use.
		
		if IsValid(self.Jumper) then
			self:SetNWBool("avehicles_jumper29_found", true)
			SetJumperClientInfo(self,self.Jumper)
		else
			self:SetNWBool("avehicles_jumper29_found", false)
		end
		timer.Simple(1.0, function()
			if IsValid(self) then
				self.lastFound = true
			end
		end)
	end

end


function SWEP:Think()
 
end

--We check if the remote still has a jumper configured in it and update the status. @ Warkanum
function SWEP:OwnerChanged()
	if self.Owner and  self.Owner.AvJumper29 then
		self.Jumper = self.Owner.AvJumper29
	end
	if self.Jumper and IsValid(self.Jumper) then
		SetJumperClientInfo(self,self.Jumper)
		self:SetNWBool("avehicles_jumper29_found", true)
	else
		self:SetNWBool("avehicles_jumper29_found", false)
	end
end

--We check if the remote still has a jumper configured in it and update the status. @ Warkanum
function SWEP:Equip(NewOwner)
	if CLIENT then self:EmitSound(EquipSound, 30, 220) end
	if NewOwner and NewOwner.AvJumper29 then
		self.Jumper = NewOwner.AvJumper29
	end
	if self.Jumper and IsValid(self.Jumper) then
		SetJumperClientInfo(self,self.Jumper)
		self:SetNWBool("avehicles_jumper29_found", true)
	else
		self:SetNWBool("avehicles_jumper29_found", false)
	end
end

--Toggel Selected function @ Warkanum
function SWEP:PrimaryAttack()
	if CLIENT then self:EmitSound(ShootSound, 50, 200) end
	
	if not SERVER then return end--Server Code
	
	if self.Jumper and IsValid(self.Jumper) then
		if functionIndex == 1 then -- The Door
			JumperToggelDoor(self.Jumper)
		elseif functionIndex == 2 then -- The Cloak
			JumperToggelCloak(self.Jumper)
		elseif functionIndex == 3 then -- The Engine
			JumperToggelEngine(self.Jumper)
		end
		SetJumperClientInfo(self,self.Jumper)
		self:SetNWBool("avehicles_jumper29_found", true) --Just a fix for if you died. @ Warkanum
	else
		self.Jumper = nil
		self:SetNWBool("avehicles_jumper29_found", false)
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+1)
end

--Select next function @ Warkanum
function SWEP:SecondaryAttack()
	FunctionNext(true)
	self:SetNWInt("avehicle_puddlejumper29_functionIndex", functionIndex)
	if CLIENT then  self:EmitSound(SelectSound, 50, 150) end
	self.Weapon:SetNextSecondaryFire(CurTime()+0.5)
end


--Draw additional information @ Warkanum
function SWEP:DrawHUD()
	local font = "Default"
	if self:GetNWBool("avehicles_jumper29_found") then
		local sw = ScrW() - 192
		local sh = 92
		local icon=surface.GetTextureID("weapons/jumper29remote_inventory")
		surface.SetTexture(icon)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(sw, 0 , 128, 64)
			
		if self:GetNWBool("avehicles_jumper29_engine") then
			draw.WordBox(8,sw,sh,"Engine: On" ,font,Color(0,0,0,80),Color(20,255,20,255))
		else
			draw.WordBox(8,sw,sh,"Engine: Off" ,font,Color(0,0,0,80),Color(20,255,20,255))
		end
		if self:GetNWBool("avehicles_jumper29_cloak") then
			draw.WordBox(8,sw,sh+30,"Cloak: On" ,font,Color(0,0,0,80),Color(20,255,20,255))
		else
			draw.WordBox(8,sw,sh+30,"Cloak: Off" ,font,Color(0,0,0,80),Color(20,255,20,255))
		end
		if self:GetNWBool("avehicles_jumper29_door") then
			draw.WordBox(8,sw,sh+60,"Door: Open" ,font,Color(0,0,0,80),Color(20,255,20,255))
		else
			draw.WordBox(8,sw,sh+60,"Door: Closed" ,font,Color(0,0,0,80),Color(20,255,20,255))
		end
	end

	local w = 20
	local h = 3
	draw.WordBox(4,w,h,"Reload(R): To find jumper. Primary: Toggel Selected function. Secondary: Next function.",font,Color(0,0,0,80),Color(255,20,20,255))
	local index = self:GetNWInt("avehicle_puddlejumper29_functionIndex") or FUNCTION_MIN
	local selected = ""
	if (functions[index]) then
		selected = functions[index]
	end
	draw.WordBox(4,w,h+30,"Selected: ["..selected.."]",font,Color(0,0,0,80),Color(255,0,0,255))
	--
end
include("shared.lua")

function ENT:Initialize()
	
end

function ENT:GetAvailable()
	return 100
end

function ENT:GetMaxAvailable()
	return 150
end

function ENT:Draw()
	self.Entity:DrawModel()
end

/* HARDPOINT HUD */
CreateClientConVar("AVehicles_HardPoint_selseat", 0, false, false)
CreateClientConVar("AVehicles_HardPoint_selweld", 1, false, false)
CreateClientConVar("AVehicles_HardPoint_selcol", 0, false, false)
local function ShowHardPointMenu(len, ply)
	local vehid = net.ReadInt(32);
	local entid = net.ReadInt(32);
	local passenger_cnt = net.ReadInt(8);
	local tvhp = string.Explode(",", net.ReadString())
	local vehicle = ents.GetByIndex(vehid)
	local hpent = ents.GetByIndex(entid)
	local podpos = 0


	local pHS = vgui.Create('DFrame')
	pHS:SetSize(300, 300)
	pHS:SetPos(ScrW()*0.3, ScrH()*0.3)
	pHS:SetTitle("AVehicle Hardpoint settings")
	pHS:SetSizable(true)
	pHS:SetDraggable( true )
	pHS:SetDeleteOnClose(true)
	
	local podl = vgui.Create( "DNumSlider", pHS)
	--podl:SetParent(pHS)
	podl:SetWide( 250 )
	podl:SetText("Controlling Seat (0 is driver)")
	podl:SetMin( 0 )
	podl:SetMax(passenger_cnt)
	podl:SetDecimals( 0 )
	podl:SetPos( 10, 30 )
	podl:SetConVar( "AVehicles_HardPoint_selseat" )
	
	local cmbHP = vgui.Create( "DComboBox", pHS)
	cmbHP:SetText("Hardpoint:")
	cmbHP:SetPos( 10, 90 )
	cmbHP:SetSize(250, 100)
	--cmbHP:SetSize( 150, 40 )
	--cmbHP:SetMultiple( false )
	
	

	local validHardpoints = {}
	if vehicle and vehicle.AVHardPoints then
		for k,v in pairs(vehicle.AVHardPoints) do
			for l,a in pairs(tvhp) do
				if tonumber(a) == tonumber(v.id) and AVehicles.Types.HardPointMatchLogic(hpent.HardPointKind, v.kind) then
					if v and v.desc then
						validHardpoints[tonumber(v.id)] = v.desc
					else
						validHardpoints[tonumber(v.id)] = ""
					end
				end
			end
		end
	end

	for k,v in pairs(validHardpoints) do
		cmbHP:AddChoice(tostring(k).." | "..tostring(v))
	end
	
	local chkwp = vgui.Create( "DCheckBoxLabel", pHS)
	chkwp:SetPos( 10,200 )
	chkwp:SetText( "Weld rather than parent?" )
	chkwp:SetConVar( "AVehicles_HardPoint_selweld" )
	chkwp:SetValue( 1 )
	chkwp:SizeToContents()
	
	local chkp = vgui.Create( "DCheckBoxLabel", pHS)
	chkp:SetPos( 10,225 )
	chkp:SetText( "No Collisions?" )
	chkp:SetConVar( "AVehicles_HardPoint_selcol" )
	chkp:SetValue( 1 )
	chkp:SizeToContents()

	local DermaButton = vgui.Create( "DButton", pHS )
	--DermaButton:SetParent(pHS) -- Set parent to our "DermaPanel"
	DermaButton:SetText( "Apply" )
	DermaButton:SetPos(10, 245)
	DermaButton:SetSize(250, 40)
	
	cmbHP.user_selected = 0;
	cmbHP.OnSelect = function(panel,index,value,data)
		cmbHP.user_selected = value;
	end
	
	DermaButton.DoClick = function ()
		local sel =  GetConVar("AVehicles_HardPoint_selseat") or nil
		local weld = GetConVar("AVehicles_HardPoint_selweld") or nil
		local col = GetConVar("AVehicles_HardPoint_selcol") or nil
		if cmbHP.user_selected and cmbHP.user_selected != 0 then
			local hpid = cmbHP.user_selected
			local hpidd = string.Explode("|",hpid)
			
			if hpidd and hpidd[1] and hpidd[2] then
				hpid = hpidd[1]
			else
				hpid = hpid
			end
			
			if sel and weld and col then
				RunConsoleCommand( "AVehicles_HardPoint_setting", vehid, entid, sel:GetString(), weld:GetString(), col:GetString(), tostring(hpid))
				pHS:Close()
			end
		end
	end
	
	pHS:MakePopup()
	
end

net.Receive("AVehicles_HardPoint_Menu", ShowHardPointMenu);
//usermessage.Hook("AVehicles_HardPoint_Menu", ShowHardPointMenu)
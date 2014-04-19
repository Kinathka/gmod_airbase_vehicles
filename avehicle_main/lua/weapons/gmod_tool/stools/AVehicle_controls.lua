if SERVER then
	AddCSLuaFile( "weapons/gmod_tool/stools/avehicle_controls.lua" )
end


// Remove this to add it to the menu
--TOOL.AddToMenu		= true
TOOL.Tab			= "AVehicles"

TOOL.Category		= "General"			// Name of the category
TOOL.Name			= "Controls"		// Name to display
TOOL.Command		= nil				// Command on click (nil for default)
TOOL.ConfigName		= nil				// Config file name (nil for default)
--TOOL.Mode			= "avehicles"


if CLIENT then
	language.Add( "Tool_avehicles_tool", "AVehicles Tool" )
	language.Add( "undone_avehicles", "Undone" )
end


function TOOL:LeftClick( trace )
	
end

function TOOL:RightClick( trace )
	
end

function TOOL:Reload( trace )

end

function TOOL:Think()

end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "Controls", Description = "Air Vehicle Control bindings" })
	panel:AddControl("Button", {
		Label = "Show Controls",
		Command = "AVehicles_vgui_keys"
	})
	panel:AddControl("Slider", {
		Label = "Locked FP Mouse Sensitivity",
		Type = "Float",
		Description = "Set the mouse sensitivity of LFP",
		Min = "0.1",
		Max = "50",
		Command = "AVehicles_MouseLFPSensitivity"
	})
end
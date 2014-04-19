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
AVehicles.Keys.Schemes =  {}
AVehicles.Keys.Keys = {}
AVehicles.Keys.Routine =  {} --Why did I call it routine? Because I can, lol.
-------------------------------------------------------------------------------------------
--------------------------Key enumerations from Avons code, thanks
-------------------------------------------------------------------------------------------
-- Mouse -- input.IsMouseDown() must be used on those
AVehicles.Keys.Keys[""] 							= -1
AVehicles.Keys.Keys["MOUSE1"] 						= MOUSE_LEFT
AVehicles.Keys.Keys["MOUSE2"] 						= MOUSE_RIGHT
AVehicles.Keys.Keys["MOUSE3"] 						= MOUSE_MIDDLE
AVehicles.Keys.Keys["MOUSE4"] 						= MOUSE_4
AVehicles.Keys.Keys["MOUSE5"] 						= MOUSE_5
-- These two do not work with input.IsMouseDown. We "hack" into them, with BindPressed and "invnext" and "invprev"
AVehicles.Keys.Keys["MWHEELDOWN"] 					= MOUSE_WHEEL_DOWN
AVehicles.Keys.Keys["MWHEELUP"] 					= MOUSE_WHEEL_UP
-- Keyboard -- input.IsKeyDown() must be used on those
AVehicles.Keys.Keys["KEY_NONE"] 					= KEY_NONE
AVehicles.Keys.Keys["0"] 							= KEY_0
AVehicles.Keys.Keys["1"] 							= KEY_1
AVehicles.Keys.Keys["2"] 							= KEY_2
AVehicles.Keys.Keys["3"] 							= KEY_3
AVehicles.Keys.Keys["4"] 							= KEY_4
AVehicles.Keys.Keys["5"] 							= KEY_5
AVehicles.Keys.Keys["6"] 							= KEY_6
AVehicles.Keys.Keys["7"] 							= KEY_7
AVehicles.Keys.Keys["8"] 							= KEY_8
AVehicles.Keys.Keys["9"] 							= KEY_9
AVehicles.Keys.Keys["A"] 							= KEY_A
AVehicles.Keys.Keys["B"] 							= KEY_B
AVehicles.Keys.Keys["C"] 							= KEY_C
AVehicles.Keys.Keys["D"] 							= KEY_D
AVehicles.Keys.Keys["E"] 							= KEY_E
AVehicles.Keys.Keys["F"] 							= KEY_F
AVehicles.Keys.Keys["G"] 							= KEY_G
AVehicles.Keys.Keys["H"] 							= KEY_H
AVehicles.Keys.Keys["I"]							= KEY_I
AVehicles.Keys.Keys["J"]							= KEY_J
AVehicles.Keys.Keys["K"] 							= KEY_K
AVehicles.Keys.Keys["L"] 							= KEY_L
AVehicles.Keys.Keys["M"] 							= KEY_M
AVehicles.Keys.Keys["N"] 							= KEY_N
AVehicles.Keys.Keys["O"] 							= KEY_O
AVehicles.Keys.Keys["P"] 							= KEY_P
AVehicles.Keys.Keys["Q"] 							= KEY_Q
AVehicles.Keys.Keys["R"] 							= KEY_R
AVehicles.Keys.Keys["S"] 							= KEY_S
AVehicles.Keys.Keys["T"] 							= KEY_T
AVehicles.Keys.Keys["U"] 							= KEY_U
AVehicles.Keys.Keys["V"] 							= KEY_V
AVehicles.Keys.Keys["W"] 							= KEY_W
AVehicles.Keys.Keys["X"] 							= KEY_X
AVehicles.Keys.Keys["Y"] 							= KEY_Y
AVehicles.Keys.Keys["Z"] 							= KEY_Z
/*	These is for special gmod commands. I'm going to disable them
AVehicles.Keys.Keys["KP_INS"] 						= KEY_PAD_0
AVehicles.Keys.Keys["KP_END"] 						= KEY_PAD_1
AVehicles.Keys.Keys["KP_DOWNARROW"] 				= KEY_PAD_2
AVehicles.Keys.Keys["KP_PGDN"] 						= KEY_PAD_3
AVehicles.Keys.Keys["KP_LEFTARROW"] 				= KEY_PAD_4
AVehicles.Keys.Keys["KP_5"] 						= KEY_PAD_5
AVehicles.Keys.Keys["KP_RIGHTARROW"] 				= KEY_PAD_6
AVehicles.Keys.Keys["KP_HOME"] 						= KEY_PAD_7
AVehicles.Keys.Keys["KP_UPARROW"] 					= KEY_PAD_8
AVehicles.Keys.Keys["KP_PGUP"] 						= KEY_PAD_9
AVehicles.Keys.Keys["KP_SLASH"] 					= KEY_PAD_DIVIDE
AVehicles.Keys.Keys["KP_MULTIPLY"]					= KEY_PAD_MULTIPLY
AVehicles.Keys.Keys["KP_MINUS"] 					= KEY_PAD_MINUS
AVehicles.Keys.Keys["KP_PLUS"] 						= KEY_PAD_PLUS
AVehicles.Keys.Keys["KP_ENTER"] 					= KEY_PAD_ENTER
AVehicles.Keys.Keys["KP_DEL"] 						= KEY_PAD_DECIMAL
*/
AVehicles.Keys.Keys["["] 							= KEY_LBRACKET
AVehicles.Keys.Keys["]"] 							= KEY_RBRACKET
AVehicles.Keys.Keys[";"] 							= KEY_SEMICOLON
AVehicles.Keys.Keys["\""] 							= KEY_APOSTROPHE
AVehicles.Keys.Keys["`"] 							= KEY_BACKQUOTE   --Console Key
AVehicles.Keys.Keys[","] 							= KEY_COMMA
AVehicles.Keys.Keys["."] 							= KEY_PERIOD
AVehicles.Keys.Keys["/"] 							= KEY_SLASH
AVehicles.Keys.Keys["\\"] 							= KEY_BACKSLASH
AVehicles.Keys.Keys["-"] 							= KEY_MINUS
AVehicles.Keys.Keys["="] 							= KEY_EQUAL
AVehicles.Keys.Keys["ENTER"] 						= KEY_ENTER
AVehicles.Keys.Keys["SPACE"] 						= KEY_SPACE
AVehicles.Keys.Keys["BACKSPACE"] 					= KEY_BACKSPACE
--AVehicles.Keys.Keys["TAB"] 							= KEY_TAB
AVehicles.Keys.Keys["CAPSLOCK"] 					= KEY_CAPSLOCK
AVehicles.Keys.Keys["NUMLOCK"] 						= KEY_NUMLOCK
--AVehicles.Keys.Keys["ESC"] 									= KEY_ESCAPE -- This does not count as valid key to bind! It is used by the engine
AVehicles.Keys.Keys["SCROLLLOCK"] 					= KEY_SCROLLLOCK
AVehicles.Keys.Keys["INS"] 							= KEY_INSERT
AVehicles.Keys.Keys["DEL"] 							= KEY_DELETE
AVehicles.Keys.Keys["HOME"] 						= KEY_HOME
AVehicles.Keys.Keys["END"] 							= KEY_END
AVehicles.Keys.Keys["PGUP"] 						= KEY_PAGEUP
AVehicles.Keys.Keys["PGDOWN"] 						= KEY_PAGEDOWN
AVehicles.Keys.Keys["BREAK"] 						= KEY_BREAK
AVehicles.Keys.Keys["SHIFT"] 						= KEY_LSHIFT 
AVehicles.Keys.Keys["RSHIFT"] 						= KEY_RSHIFT
AVehicles.Keys.Keys["ALT"] 							= KEY_LALT
AVehicles.Keys.Keys["RALT"] 						= KEY_RALT
AVehicles.Keys.Keys["CTRL"] 						= KEY_LCONTROL
AVehicles.Keys.Keys["RCTRL"] 						= KEY_RCONTROL
--AVehicles.Keys.Keys["LWIN"] 					= KEY_LWIN -- This does not count as valid key to bind!
--AVehicles.Keys.Keys["RWIN"] 					= KEY_RWIN -- This does not count as valid key to bind!
--AVehicles.Keys.Keys["APP"] 						= KEY_APP
AVehicles.Keys.Keys["UPARROW"] 					= KEY_UP
AVehicles.Keys.Keys["LEFTARROW"] 				= KEY_LEFT
AVehicles.Keys.Keys["DOWNARROW"] 				= KEY_DOWN
AVehicles.Keys.Keys["RIGHTARROW"] 				= KEY_RIGHT
AVehicles.Keys.Keys["F1"] 						= KEY_F1
AVehicles.Keys.Keys["F2"] 						= KEY_F2
AVehicles.Keys.Keys["F3"] 						= KEY_F3
AVehicles.Keys.Keys["F4"] 						= KEY_F4
AVehicles.Keys.Keys["F5"] 						= KEY_F5
AVehicles.Keys.Keys["F6"] 						= KEY_F6
AVehicles.Keys.Keys["F7"] 						= KEY_F7
AVehicles.Keys.Keys["F8"] 						= KEY_F8
AVehicles.Keys.Keys["F9"] 						= KEY_F9
AVehicles.Keys.Keys["F10"] 						= KEY_F10
AVehicles.Keys.Keys["F11"] 						= KEY_F11
AVehicles.Keys.Keys["F12"] 						= KEY_F12
--AVehicles.Keys.Keys["CAPSLOCK"]				= KEY_CAPSLOCKTOGGLE
--AVehicles.Keys.Keys["NUMLOCK"]			= KEY_NUMLOCKTOGGLE
--AVehicles.Keys.Keys["SCROLLLOCK"]		= KEY_SCROLLLOCKTOGGLE



---------------------------------------------------------------The Body, Code-----------------------------------------

---------------------------------------------------------------------------Setup Keyboard, routines etc @ Warkanum
function AVehicles.Keys.Initialize()
	AVehicles.Keys.Initialized = true
end

-------------------------------------------------------Set the active routines ------------------@ Warkanum
function AVehicles.Keys.SetRoutineActive(ply,schema, name)
	AVehicles.Keys.Routine[ply] = AVehicles.Keys.Routine[ply] or {}
	AVehicles.Keys.Routine[ply][schema] = AVehicles.Keys.Routine[ply][schema] or {}
	AVehicles.Keys.Routine[ply][schema][name] = true
		--RunConsoleCommand("AVehicles_Impulse.TRoutine",name, key)
end

-------------------------------------------------------Set the not active routines ------------------@ Warkanum
function AVehicles.Keys.SetRoutineInActive(ply,schema, name)
	AVehicles.Keys.Routine[ply] = AVehicles.Keys.Routine[ply] or {}
	AVehicles.Keys.Routine[ply][schema] = AVehicles.Keys.Routine[ply][schema] or {}
	AVehicles.Keys.Routine[ply][schema][name] = false
end



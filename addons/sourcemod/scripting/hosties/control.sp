/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <hosties>

// Menus
#define MENU_SIMON			"##simonsays##"
#define MENU_FIRST			"##firstreaction##"
#define MENU_LAST				"##lastreaction##"
#define MENU_JUMP				"##jump##"
#define MENU_CROUCH			"##crouch##"
#define MENU_NONE				"##none##"
#define MENU_FOLLOW			"##followme##"
#define MENU_GOTO				"##goto##"
#define MENU_FREE				"##freeday##"

// Actions IDs
#define ACTION_ID_JUMP		0
#define ACTION_ID_CROUCH	1
#define ACTION_ID_FOLLOW	2
#define ACTION_ID_GOTO		3
#define ACTION_ID_FREE		4

#define ACTION_COUNT			5

// Tasks IDs
#define TASK_ID_SIMON		0
#define TASK_ID_FIRST		1
#define TASK_ID_LAST			2

#define TASK_COUNT			3

bool g_bController[MAXPLAYERS + 1] = false;
bool g_bInControl[MAXPLAYERS + 1] = false;
bool g_bActComplete[MAXPLAYERS + 1] = false;
bool g_bHasController = false;
bool g_bCanControl = false;
bool g_bInSimonSays = false;
bool g_bInAction = false;
bool g_bCanStop = false;
float g_fDelay = 0.0;
int g_iState = 0;
Handle gH_ControllerMenu = null;
char g_sActionSound[ACTION_COUNT][PLATFORM_MAX_PATH] = {"sm_hosties/control/jump.mp3", "sm_hosties/control/crouch.mp3", "sm_hosties/control/follow.mp3", "sm_hosties/control/go.mp3", "sm_hosties/control/freeday.mp3"};
char g_sTaskSound[TASK_COUNT][PLATFORM_MAX_PATH] = {"sm_hosties/control/simon.mp3", "sm_hosties/control/first.mp3", "sm_hosties/control/last.mp3"};

void Control_OnPluginStart()
{
	RegConsoleCmd("sm_control", Command_Control);
	RegConsoleCmd("sm_hostiescontrol", Command_Control);
	RegConsoleCmd("sm_hc", Command_Control);
	HookEvent("player_death", Control_PlayerDeath);
	HookEvent("player_disconnect", Control_PlayerDisconnect);
}

public void Control_Menu(int client)
{
	if(g_bHasController && Control_GetController() == client)
	{
		if(gH_ControllerMenu == null)
		{
			gH_ControllerMenu = CreateMenu(ControllerMenuHandle, view_as<MenuAction>(MENU_ACTIONS_ALL));
			if(g_iState == 0)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Main");
				AddMenuItem(gH_ControllerMenu, MENU_SIMON, "Simon"); // state 1
				AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First"); // state 2
				AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last"); // state 3
				AddMenuItem(gH_ControllerMenu, MENU_NONE, "None"); // state 4
			}
			else if(g_iState == 1)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Simon");
				AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First"); // state 11
				AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last"); // state 12
				AddMenuItem(gH_ControllerMenu, MENU_NONE, "None"); // state 13
			}
			else if(g_iState == 2)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "First");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 3)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "Last");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 4)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control", "None");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
				AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			}
			else if(g_iState == 11)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "First");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 12)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "Last");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			}
			else if(g_iState == 13)
			{
				SetMenuTitle(gH_ControllerMenu, "%t", "Control Action", "Simon", "None");
				AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
				AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
				AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
				AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
				AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			}
			/*
			AddMenuItem(gH_ControllerMenu, MENU_SIMON, "Simon");
			AddMenuItem(gH_ControllerMenu, MENU_FIRST, "First");
			AddMenuItem(gH_ControllerMenu, MENU_LAST, "Last");
			AddMenuItem(gH_ControllerMenu, MENU_JUMP, "Jump");
			AddMenuItem(gH_ControllerMenu, MENU_CROUCH, "Crouch");
			AddMenuItem(gH_ControllerMenu, MENU_FOLLOW, "Follow");
			AddMenuItem(gH_ControllerMenu, MENU_GOTO, "Goto");
			AddMenuItem(gH_ControllerMenu, MENU_FREE, "Freeday");
			AddMenuItem(gH_ControllerMenu, MENU_NONE, "None");*/
			SetMenuExitButton(gH_ControllerMenu, true);
			DisplayMenu(gH_ControllerMenu, client, 0);
		}
	}
}

public int ControllerMenuHandle(Handle menu, MenuAction action, int param1, int param2)
{
	/*if(action == MenuAction_DisplayItem)
	{
		if(GetMenuItemCount(menu) - 1 == param2)
		{
			decl String:selection[64], String:buffer[255];
			GetMenuItem(menu, param2, selection, sizeof(selection));
			if(strcmp(selection, MENU_SIMON, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Simon", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FIRST, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "First", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_LAST, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Last", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_JUMP, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Jump", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_CROUCH, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Crouch", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FOLLOW, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Follow", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_GOTO, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Goto", param1);
				return RedrawMenuItem(buffer);
			}
			else if(strcmp(selection, MENU_FREE, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "Freeday", param1);
				return RedrawMenuItem(buffer);					
			}
			else if(strcmp(selection, MENU_NONE, false) == 0)
			{
				Format(buffer, sizeof(buffer), "%T", "None", param1);
				return RedrawMenuItem(buffer);					
			}
		}
	}*/
	if (action == MenuAction_Select)
	{
		if(GetMenuItemCount(menu) - 1 == param2)
		{
			char selection[64];
			GetMenuItem(menu, param2, selection, sizeof(selection));
			bool ReturnMenu = true;
			if(strcmp(selection, MENU_SIMON, false) == 0)
			{
				g_iState = 1;
			}
			else if(strcmp(selection, MENU_FIRST, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 2;
				}
				else if(g_iState == 1)
				{
					g_iState = 11;
				}
			}
			else if(strcmp(selection, MENU_LAST, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 3;
				}
				else if(g_iState == 1)
				{
					g_iState = 12;
				}
			}
			else if(strcmp(selection, MENU_JUMP, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstJump");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastJump");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Jump");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstJump");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastJump");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonJump");
				}
			}
			else if(strcmp(selection, MENU_CROUCH, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstCrouch");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastCrouch");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Crouch");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstCrouch");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastCrouch");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonCrouch");
				}
			}
			else if(strcmp(selection, MENU_FOLLOW, false) == 0)
			{
				
			}
			else if(strcmp(selection, MENU_GOTO, false) == 0)
			{
				if(g_iState == 2)
				{
					Control_PlayAction("FirstGoto");
				}
				else if(g_iState == 3)
				{
					Control_PlayAction("LastGoto");
				}
				else if(g_iState == 4)
				{
					Control_PlayAction("Goto");
				}
				else if(g_iState == 11)
				{
					Control_PlayAction("SimonFirstGoto");
				}
				else if(g_iState == 12)
				{
					Control_PlayAction("SimonLastGoto");
				}
				else if(g_iState == 13)
				{
					Control_PlayAction("SimonGoto");
				}
			}
			else if(strcmp(selection, MENU_FREE, false) == 0)
			{
				ReturnMenu = false;
				Control_PlayAction("Freeday");
			}
			else if(strcmp(selection, MENU_NONE, false) == 0)
			{
				if(g_iState == 0)
				{
					g_iState = 4;
				}
				else if(g_iState == 1)
				{
					g_iState = 13;
				}
			}
			if(ReturnMenu)
			{
				gH_ControllerMenu = null;
				Control_Menu(param1);
			}
			CloseHandle(menu);
		}
	}
	if (action == MenuAction_Cancel)
	{
		// ToDo: Add Yes/No menu when leaving this menu (no = return to this menu, yes = stop control)
	}
}

public void Control_PlayAction(char[] Act)
{
	if(StrEqual(Act, "Jump"))
	{
		EmitSoundToAllAny(g_sActionSound[ACTION_ID_JUMP]);
	}
}

void Control_OnMapStart()
{
	if (g_Game == Game_CSS)
	{
		BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/lgtning.vmt");
		LaserHalo = PrecacheModel("materials/sprites/plasmahalo.vmt");
	}
	else if (g_Game == Game_CSGO)
	{
		BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		LaserHalo = PrecacheModel("materials/sprites/light_glow02.vmt");
	}
	
	for(int i = 0; i < ACTION_COUNT; i++)
	{
		if(!StrEqual(g_sActionSound[i], "", false))
		{
			PrecacheSoundAny(g_sActionSound[i]);
		}
	}
	
	for(int i = 0; i < TASK_COUNT; i++)
	{
		if(!StrEqual(g_sTaskSound[i], "", false))
		{
			PrecacheSoundAny(g_sTaskSound[i]);
		}
	}
}

public Action Control_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bHasController && g_bController[client] == true)
	{
		Control_Controller(client, false, 0, true);
	}
}

public Action Command_Control(int client, int args)
{
	if (GetClientTeam(client) != 3)
	{
		PrintToChat(client, CHAT_BANNER, "Must Be CT");
		return Plugin_Handled;
	}
	
	if(g_bHasController && Control_GetController() != 0)
	{
		PrintToChat(client, CHAT_BANNER, "Control Already Taken");
	}
	else
	{
		Control_Controller(client, true, -1, true);
		PrintToChat(client, CHAT_BANNER, "Control Taken");
	}
	
	return Plugin_Handled;
}

public int Control_GetController()
{
	if(!g_bHasController)
	{
		return 0;
	}
	
	for(int i = 1; i <= MaxClients ; i++)
	{
		if(g_bController[i] == true)
		{
			if(IsClientInGame(i) || IsPlayerAlive(i) || GetClientTeam(i) == 3)
			{
				return i;
			}
			else
			{
				Control_Controller(i, false, -1, false);
				return 0;
			}
		}
	}
	return 0;
}

public void Control_Controller(int client, bool controller, int reason, bool ann)
{
	if(controller)
	{
		if(!g_bHasController && !g_bController[client] && Control_GetController() == 0)
		{
			g_bController[client] = true;
			g_bHasController = true;
			g_iState = 0;
			Control_Menu(client);
			PrintToChatAll(CHAT_BANNER, "The New Controller");
		}
	}
	else
	{
		if(Control_GetController() == client)
		{
			g_bController[client] = false;
			g_bHasController = false;
			if(ann)
			{
				if(reason == -1)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller", client);
				}
				else if(reason == 0)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Disconncted");
				}
				else if(reason == 1)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Died");
				}
				else if(reason == 2)
				{
					PrintToChatAll(CHAT_BANNER, "No Longer The Controller Reason", client, "Stopped controlling");
				}
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "No Controller");
			}
		}
	}
}

public Action Control_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(g_bHasController && g_bController[client] == true)
	{
		Control_Controller(client, false, 1, true);
	}
}
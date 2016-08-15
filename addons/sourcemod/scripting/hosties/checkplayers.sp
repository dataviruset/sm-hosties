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
#include <cstrike>
#include <hosties>

Handle gH_Cvar_CheckPlayersOn = null;
bool gShadow_CheckPlayersOn;

void CheckPlayers_OnPluginStart()
{
	gH_Cvar_CheckPlayersOn = CreateConVar("sm_hosties_checkplayers_enable", "1", "Enable or disable the !checkplayers command: 0 - disable, 1 - enable", FCVAR_NONE, true, 0.0, true, 1.0);
	gShadow_CheckPlayersOn = true;
	
	RegConsoleCmd("sm_checkplayers", Command_CheckPlayers);
	
	HookConVarChange(gH_Cvar_CheckPlayersOn, CheckPlayers_CvarChanged);
}

void CheckPlayers_OnConfigsExecuted()
{
	gShadow_CheckPlayersOn = GetConVarBool(gH_Cvar_CheckPlayersOn);
}

public void CheckPlayers_CvarChanged(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == gH_Cvar_CheckPlayersOn)
	{
		gShadow_CheckPlayersOn = view_as<bool>(StringToInt(newValue));
	}
}

public Action Command_CheckPlayers(int client, int args)
{
	if (gShadow_CheckPlayersOn)
	{
		if (IsPlayerAlive(client))
		{
			// count number of rebels
			int realrebelscount = 0;
			for (int idx = 1; idx < MaxClients; idx++)
			{
				if (g_bIsARebel[idx] && IsClientInGame(idx))
				{
					realrebelscount++;
				}
			}

			if (realrebelscount < 1)
			{
				PrintToChat(client, CHAT_BANNER, "No Rebels ATM");
			}
			else
			{
				Handle checkplayersmenu = CreateMenu(Handler_DoNothing);
				char rebellingterrorists[32];
				Format(rebellingterrorists, sizeof(rebellingterrorists), "%T", "Rebelling Terrorists", client);
				SetMenuTitle(checkplayersmenu, rebellingterrorists);
				char item[64];
				for(int i; i < MaxClients; i++)
				{
					if (g_bIsARebel[i] && IsClientInGame(i))
					{
						GetClientName(i, item, sizeof(item));
						AddMenuItem(checkplayersmenu, "player", item);
					}
				}
				SetMenuExitButton(checkplayersmenu, true);
				DisplayMenu(checkplayersmenu, client, MENU_TIME_FOREVER);
			}
		}
	}
	else
	{
		ReplyToCommand(client, CHAT_BANNER, "CheckPlayers CMD Disabled");
	}

	return Plugin_Handled;
}

public int Handler_DoNothing(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

#include <sourcemod>
#include <cstrike>
#include <hosties>

new Handle:gH_Cvar_CheckPlayersOn = INVALID_HANDLE;
new bool:gShadow_CheckPlayersOn;

CheckPlayers_OnPluginStart()
{
	gH_Cvar_CheckPlayersOn = CreateConVar("sm_hosties_checkplayers_enable", "1", "Enable or disable the !checkplayers command: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_CheckPlayersOn = true;
	
	RegConsoleCmd("sm_checkplayers", Command_CheckPlayers);
	
	HookConVarChange(gH_Cvar_CheckPlayersOn, CheckPlayers_CvarChanged);
}

public CheckPlayers_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_CheckPlayersOn)
	{
		gShadow_CheckPlayersOn = bool:StringToInt(newValue);
	}
}

public Action:Command_CheckPlayers(client, args)
{
	if (gShadow_CheckPlayersOn)
	{
		if (IsPlayerAlive(client))
		{
			// count number of rebels
			new realrebelscount = 0;
			for (new idx = 1; idx < MaxClients; idx++)
			{
				if (g_bIsARebel[idx])
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
				new Handle:checkplayersmenu = CreateMenu(Handler_DoNothing);
				decl String:rebellingterrorists[32];
				Format(rebellingterrorists, sizeof(rebellingterrorists), "%T", "Rebelling Terrorists", client);
				SetMenuTitle(checkplayersmenu, rebellingterrorists);
				decl String:item[64];
				for(new i; i < MaxClients; i++)
				{
					if (g_bIsARebel[i])
					{
						GetClientName(g_bIsARebel[i], item, sizeof(item));
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
		PrintToChat(client, CHAT_BANNER, "CheckPlayers CMD Disabled");
	}

	return Plugin_Handled;
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

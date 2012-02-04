/*
 * SourceMod Hosties Project
 * by: databomb & dataviruset
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

new Float:g_DeathLocation[MAXPLAYERS+1][3];

Respawn_OnPluginStart()
{
	RegAdminCmd("sm_hrespawn", Command_Respawn, ADMFLAG_SLAY);
	RegAdminCmd("sm_1up", Command_Respawn, ADMFLAG_SLAY);
	HookEvent("player_death", Respawn_PlayerDeath);
}

public Action:Command_Respawn(client, args)
{
	return Plugin_Handled;
}

public Respawn_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	GetClientAbsOrigin(victim, g_DeathLocation[victim]);
}

Respawn_Menus(Handle:h_TopMenu, TopMenuObject:obj_Hosties)
{
	AddToTopMenu(h_TopMenu, "sm_hrespawn", TopMenuObject_Item, AdminMenu_Respawn, obj_Hosties, "sm_hrespawn", ADMFLAG_SLAY);
}

PerformRespawn(client, target)
{
	LogAction(client, target, "\"%L\" respawned \"%L\"", client, target);
	CS_RespawnPlayer(target);
	TeleportEntity(target, g_DeathLocation[target], NULL_VECTOR, NULL_VECTOR);
}

DisplayRespawnMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandler_Respawn);
	
	decl String:title[100];
	Format(title, sizeof(title), "Respawn player:");
	//Format(title, sizeof(title), "%T:", "Slay player", client);
	SetMenuTitle(menu, title);
	SetMenuExitBackButton(menu, true);
	
	//AddTargetsToMenu(menu, client, true, true);
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_DEAD);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public AdminMenu_Respawn(Handle:topmenu, 
					  TopMenuAction:action,
					  TopMenuObject:object_id,
					  param,
					  String:buffer[],
					  maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Respawn player");
		//Format(buffer, maxlength, "%T", "Slay player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayRespawnMenu(param);
	}
}

public MenuHandler_Respawn(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && gH_TopMenu != INVALID_HANDLE)
		{
			DisplayTopMenu(gH_TopMenu, param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new userid, target;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else if (IsPlayerAlive(target))
		{
			ReplyToCommand(param1, "[SM] Player has since respawned.");
			//ReplyToCommand(param1, "[SM] %t", "Player has since died");
		}
		else
		{
			decl String:name[32];
			GetClientName(target, name, sizeof(name));
			PerformRespawn(param1, target);
			ShowActivity2(param1, "[SM] ", "respawned %s", name);
			//ShowActivity2(param1, "[SM] ", "%t", "Slayed target", "_s", name);
		}
		
		DisplayRespawnMenu(param1);
	}
}
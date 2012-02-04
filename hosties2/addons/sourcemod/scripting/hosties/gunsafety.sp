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
#include <cstrike>
#include <sdktools>
#include <hosties>

new Handle:gH_Cvar_Strip_On_Slay = INVALID_HANDLE;
new Handle:gH_Cvar_Strip_On_Kick = INVALID_HANDLE;
new Handle:gH_Cvar_Strip_On_Ban = INVALID_HANDLE;

new bool:gShadow_Strip_On_Slay = false;
new bool:gShadow_Strip_On_Kick = false;
new bool:gShadow_Strip_On_Ban = false;

GunSafety_OnPluginStart()
{
	gH_Cvar_Strip_On_Slay = CreateConVar("sm_hosties_strip_onslay", "1", "Enable or disable the stripping of weapons from anyone who is slain.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Strip_On_Slay = true;
	gH_Cvar_Strip_On_Kick = CreateConVar("sm_hosties_strip_onkick", "1", "Enable or disable the stripping of weapons from anyone who is kicked.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Strip_On_Kick = true;
	gH_Cvar_Strip_On_Ban = CreateConVar("sm_hosties_strip_onban", "1", "Enable or disable the stripping of weapons from anyone who is banned.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Strip_On_Ban = true;
	
	HookConVarChange(gH_Cvar_Strip_On_Slay, GunSafety_CvarChanged);
	HookConVarChange(gH_Cvar_Strip_On_Kick, GunSafety_CvarChanged);
	HookConVarChange(gH_Cvar_Strip_On_Ban, GunSafety_CvarChanged);
	
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_slay");
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_kick");
	AddCommandListener(Strip_Player_Weapons_Intercept, "sm_ban");
}

public Action:Strip_Player_Weapons_Intercept(client, const String:command[], iArgNumber)
{
	// let original command handle return text
	if (iArgNumber < 1)
	{
		return Plugin_Continue;
	}
	
	// check for proper admin permissions and cvars
	if (StrEqual(command, "sm_slay", false))
	{
		if (!gShadow_Strip_On_Slay)
		{
			return Plugin_Continue;
		}
	
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Slay;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
	else if (StrEqual(command, "sm_kick", false))
	{
		if (!gShadow_Strip_On_Kick)
		{
			return Plugin_Continue;
		}
		
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Kick;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
	else if (StrEqual(command, "sm_ban", false))
	{
		if (!gShadow_Strip_On_Ban)
		{
			return Plugin_Continue;
		}
		
		new AdminFlag:flag;
		if (!GetCommandOverride(command, Override_Command, _:flag))
		{
			flag = Admin_Ban;
		}
		
		if (client && !GetAdminFlag(GetUserAdmin(client), flag))
		{
			return Plugin_Continue;
		}
	}
		
	// process the command
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		StripAllWeapons(target_list[i]);
	}
	
	return Plugin_Continue;
}

public GunSafety_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_Strip_On_Slay)
	{
		gShadow_Strip_On_Slay = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Strip_On_Kick)
	{
		gShadow_Strip_On_Kick = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Strip_On_Ban)
	{
		gShadow_Strip_On_Ban = bool:StringToInt(newValue);
	}
}
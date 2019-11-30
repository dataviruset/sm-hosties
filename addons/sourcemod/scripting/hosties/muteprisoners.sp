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
#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <basecomm>
#define REQUIRE_PLUGIN
#include <hosties>

new Handle:gH_Cvar_MuteStatus = INVALID_HANDLE;
new gShadow_MuteStatus;
new Handle:gH_Cvar_MuteLength = INVALID_HANDLE;
new Float:gShadow_MuteLength;
new Handle:gH_Timer_Unmuter = INVALID_HANDLE;
new Handle:gH_Cvar_MuteImmune = INVALID_HANDLE;
new String:gShadow_MuteImmune[37];
new Handle:gH_Cvar_MuteCT = INVALID_HANDLE;
new bool:gShadow_MuteCT = false;
new gAdmFlags_MuteImmunity = 0;

MutePrisoners_OnPluginStart()
{
	gH_Cvar_MuteStatus = CreateConVar("sm_hosties_mute", "1", "Setting for muting terrorists automatically: 0 - disable, 1 - terrorists are muted the first few seconds of a round, 2 - terrorists are muted when they die, 3 - both", FCVAR_NONE, true, 0.0, true, 3.0);
	gShadow_MuteStatus = 0;
	
	gH_Cvar_MuteLength = CreateConVar("sm_hosties_roundstart_mute", "30.0", "The length of time the Terrorist team is muted for after the round begins", FCVAR_NONE, true, 3.0, true, 90.0);
	gShadow_MuteLength = Float:30.0;
	
	gH_Cvar_MuteImmune = CreateConVar("sm_hosties_mute_immune", "z", "Admin flags which are immune from getting muted: 0 - nobody, 1 - all admins, flag values: abcdefghijklmnopqrst", FCVAR_NONE);
	FormatEx(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), "z");
	
	gH_Cvar_MuteCT = CreateConVar("sm_hosties_mute_ct", "0", "Setting for muting counter-terrorists automatically when they die (requires sm_hosties_mute 2 or 3): 0 - disable, 1 - enable", FCVAR_NONE, true, 0.0, true, 1.0);
	gShadow_MuteCT = false;
	
	HookConVarChange(gH_Cvar_MuteStatus, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteLength, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteImmune, MutePrisoners_CvarChanged);
	HookConVarChange(gH_Cvar_MuteCT, MutePrisoners_CvarChanged);
	
	// Why is this here? -ici
	g_Offset_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
}

MutePrisoners_AllPluginsLoaded()
{
	if (DoesContainBaseCommNatives())
	{
		HookEvent("round_start", MutePrisoners_RoundStart);
		HookEvent("round_end", MutePrisoners_RoundEnd);
		HookEvent("player_death", MutePrisoners_PlayerDeath);
		HookEvent("player_spawn", MutePrisoners_PlayerSpawn);
	}
	else
	{
		PrintToServer("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
		LogMessage("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
	}
}

MutePrisoners_OnConfigsExecuted()
{
	gShadow_MuteStatus = GetConVarInt(gH_Cvar_MuteStatus);
	gShadow_MuteLength = GetConVarFloat(gH_Cvar_MuteLength);
	
	GetConVarString(gH_Cvar_MuteImmune, gShadow_MuteImmune, sizeof(gShadow_MuteImmune));
	MutePrisoners_CalcImmunity();
}

MutePrisoners_ClientPostAdminCheck(client)
{
	// Fix - players reconnecting and speaking while dead
	if (gShadow_MuteStatus)
	{
		MutePlayer(client);
	}
}

bool:MutePlayer(client)
{
	// Ignore punished players
	if (BaseComm_IsClientMuted(client))
		return true;
	
	// Ignore immune players
	if (GetUserFlagBits(client) & gAdmFlags_MuteImmunity)
		return false;
	
	SetClientListeningFlags(client, VOICE_MUTED);
	return true;
}

bool:UnmutePlayer(client)
{
	// Ignore punished players
	if (BaseComm_IsClientMuted(client))
		return false;
	
	SetClientListeningFlags(client, VOICE_NORMAL);
	return true;
}

stock MuteTs()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			MutePlayer(i);
		}
	}
}

stock UnmuteTs()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			UnmutePlayer(i);
		}
	}
}

stock UnmuteAll()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			UnmutePlayer(i);
		}
	}
}

stock bool:DoesContainBaseCommNatives()
{
	// 1.3.9 will have Native_IsClientMuted in basecomm.inc 
	if (GetFeatureStatus(FeatureType_Native, "BaseComm_IsClientMuted") == FeatureStatus_Available)
	{
		return true;
	}
	return false;
}

void MutePrisoners_CalcImmunity()
{
	if (StrEqual(gShadow_MuteImmune, "0"))
	{
		gAdmFlags_MuteImmunity = 0;
	}
	else
	{
		if(StrEqual(gShadow_MuteImmune, "1"))
		{
			// include everything but 'a': reservation slot
			FormatEx(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), "bcdefghijklmnopqrstz");
		}
		
		gAdmFlags_MuteImmunity = ReadFlagString(gShadow_MuteImmune);
	}
}

public MutePrisoners_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_MuteStatus)
	{
		gShadow_MuteStatus = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_MuteLength)
	{
		gShadow_MuteLength = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_MuteImmune)
	{
		FormatEx(gShadow_MuteImmune, sizeof(gShadow_MuteImmune), newValue);
		MutePrisoners_CalcImmunity();
	}
	else if (cvar == gH_Cvar_MuteCT)
	{
		gShadow_MuteCT = bool:StringToInt(newValue);
	}
}

public MutePrisoners_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (gShadow_MuteStatus == 1 || gShadow_MuteStatus == 3)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			// if the timer is anything but invalid, we should mute these new spawners
			if (gH_Timer_Unmuter != INVALID_HANDLE)
			{
				MutePlayer(client);
			}
			else
			{
				// Player joined in the middle of the game
				UnmutePlayer(client);
			}
		}
	}
	
	// Unmute CTs fix
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		UnmutePlayer(client);
	}
}

public MutePrisoners_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus <= 1)
	{
		return;
	}
	
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new team = GetClientTeam(victim);
	
	switch (team)
	{
		case CS_TEAM_T:
		{
			CreateTimer(0.1, Timer_Mute, GetClientSerial(victim), TIMER_FLAG_NO_MAPCHANGE);
		}
		case CS_TEAM_CT:
		{
			if (gShadow_MuteCT)
			{
				CreateTimer(0.1, Timer_Mute, GetClientSerial(victim), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:Timer_Mute(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	if (!client)
	{
		// Player is no longer in game.
		return Plugin_Stop;
	}
	
	if (MutePlayer(client))
	{
		PrintToChat(client, CHAT_BANNER, "Now Muted");
	}
	return Plugin_Stop;
}

public MutePrisoners_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus)
	{
		CreateTimer(0.2, Timer_UnmuteAll, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// In case the round ends earlier than gShadow_MuteLength
	if (gH_Timer_Unmuter != INVALID_HANDLE)
	{
		CloseHandle(gH_Timer_Unmuter);
		gH_Timer_Unmuter = INVALID_HANDLE;
	}
}

public MutePrisoners_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_MuteStatus == 1 || gShadow_MuteStatus == 3)
	{
		MuteTs();
		
		// In case the round gets restarted multiple times (mp_restartgame 1)
		if (gH_Timer_Unmuter != INVALID_HANDLE)
		{
			CloseHandle(gH_Timer_Unmuter);
			gH_Timer_Unmuter = INVALID_HANDLE;
		}
		
		// Unmute Timer
		gH_Timer_Unmuter = CreateTimer(gShadow_MuteLength, Timer_UnmutePrisoners, _, TIMER_FLAG_NO_MAPCHANGE);
		
		PrintToChatAll(CHAT_BANNER, "Ts Muted", RoundToNearest(gShadow_MuteLength));
	}
}

public Action:Timer_UnmutePrisoners(Handle:timer)
{
	UnmuteTs();
	
	PrintToChatAll(CHAT_BANNER, "Ts Can Speak Again");
	gH_Timer_Unmuter = INVALID_HANDLE;
	
	return Plugin_Stop;
}

public Action:Timer_UnmuteAll(Handle:timer)
{
	UnmuteAll();
	
	return Plugin_Stop;
}

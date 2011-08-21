#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <hosties>
#include <lastrequest>

Freekillers_OnPluginStart()
{
	gH_Cvar_Freekill_Sound = CreateConVar("sm_hosties_freekill_sound", "sm_hosties/freekill1.mp3", "What sound to play if a non-rebelling T gets 'freekilled', relative to the sound-folder: -1 - disable, path - path to sound file", FCVAR_PLUGIN);
	Format(gShadow_Freekill_Sound, PLATFORM_MAX_PATH, "sm_hosties/freekill1.mp3");
	gH_Cvar_Freekill_Threshold = CreateConVar("sm_hosties_freekill_treshold", "5", "The amount of non-rebelling terrorists a CT is allowed to kill before action is taken: 0 - disabled, >0 - amount of Ts", FCVAR_PLUGIN, true, 0.0, true, 64.0);
	gShadow_Freekill_Threshold = 5;
	gH_Cvar_Freekill_Notify = CreateConVar("sm_hosties_freekill_notify", "0", "Whether to notify CTs who kills a non-rebelling T about how many 'freekills' they have, or not: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Freekill_Notify = false;
	gH_Cvar_Freekill_BanLength = CreateConVar("sm_hosties_freekill_ban_length", "60", "The length of an automated freekill ban (if sm_hosties_freekill_punishment is 2): x - ban length in minutes", _, true, 0.0);
	gShadow_Freekill_BanLength = 60;
	gH_Cvar_Freekill_Punishment = CreateConVar("sm_hosties_freekill_punishment", "0", "The punishment to give to a CT who overrides the treshold: 0 - slay, 1 - kick, 2 - ban", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	gShadow_Freekill_Punishment = FP_Slay;
	gH_Cvar_Freekill_Reset = CreateConVar("sm_hosties_freekill_reset", "0", "When to reset the 'freekill counter' for all CTs: 0 - on round start, 1 - on map end", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Freekill_Reset = 0;
	gH_Cvar_Freekill_Sound_Mode = CreateConVar("sm_hosties_freekill_sound_mode", "1", "When to play the 'freekill sound': 0 - on freeATTACK, 1 - on freeKILL", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Freekill_Sound_Mode = 1;
	
	HookEvent("player_death", Freekillers_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_end", Freekillers_RoundEnd);
	
	HookConVarChange(gH_Cvar_Freekill_Sound, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Threshold, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Notify, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_BanLength, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Punishment, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Reset, Freekillers_CvarChanged);
	HookConVarChange(gH_Cvar_Freekill_Sound_Mode, Freekillers_CvarChanged);
	
	ResetNumFreekills();
}

ResetNumFreekills()
{
	for (new fidx = 1; fidx < MaxClients; fidx++)
	{
		gA_FreekillsOfCT[fidx] = 0;
	}
}

Freekillers_OnMapEnd()
{
	if (gShadow_Freekill_Reset == 1)
	{
		ResetNumFreekills();
	}
}

Freekillers_OnConfigsExecuted()
{
	// check for -1 for backward compatibility
	GetConVarString(gH_Cvar_Freekill_Sound, gShadow_Freekill_Sound, sizeof(gShadow_Freekill_Sound));
	if ((strlen(gShadow_Freekill_Sound) > 0) && !StrEqual(gShadow_Freekill_Sound, "-1"))
	{
		new MediaType:soundfile = type_Sound;
		CacheTheFile(gShadow_Freekill_Sound, soundfile);
	}
	
	gShadow_Freekill_Threshold = GetConVarInt(gH_Cvar_Freekill_Threshold);
	gShadow_Freekill_Notify = GetConVarBool(gH_Cvar_Freekill_Notify);
	gShadow_Freekill_BanLength = GetConVarInt(gH_Cvar_Freekill_BanLength);
	gShadow_Freekill_Punishment = FreekillPunishment:GetConVarInt(gH_Cvar_Freekill_Punishment);
	gShadow_Freekill_Reset = GetConVarInt(gH_Cvar_Freekill_Reset);
	gShadow_Freekill_Sound_Mode = GetConVarInt(gH_Cvar_Freekill_Sound_Mode);
}

public Freekillers_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_Freekill_Sound)
	{
		Format(gShadow_Freekill_Sound, PLATFORM_MAX_PATH, newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Threshold)
	{
		gShadow_Freekill_Threshold = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Notify)
	{
		gShadow_Freekill_Notify = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_BanLength)
	{
		gShadow_Freekill_BanLength = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Punishment)
	{
		gShadow_Freekill_Punishment = FreekillPunishment:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Reset)
	{
		gShadow_Freekill_Reset = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Freekill_Sound_Mode)
	{
		gShadow_Freekill_Sound_Mode = StringToInt(newValue);
	}
}

public Freekillers_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (gShadow_Freekill_Reset == 0)
	{
		ResetNumFreekills();
	}
}

public Freekillers_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	// if attacker was a counter-terrorist and target was a terrorist
	if (attacker && victim && (GetClientTeam(attacker) == CS_TEAM_CT) && \
		(GetClientTeam(victim) == CS_TEAM_T) && !g_bIsARebel[victim])
	{
		new iArraySize = GetArraySize(gH_DArray_LR_Partners);
		if (iArraySize == 0)
		{
			TakeActionOnFreekiller(attacker);
		}
		else
		{
			// check if victim was in an LR and not the attacker pair
			for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
			{
				new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				if (type != LR_Rebel && (victim == LR_Player_Prisoner) && (attacker != LR_Player_Guard))
				{
					TakeActionOnFreekiller(attacker);
				}
			}
		}
	}
}

TakeActionOnFreekiller(attacker)
{
	// FREEEEEKILL... rawr...
	if (gShadow_Freekill_Threshold > 0)
	{
		if (gA_FreekillsOfCT[attacker] >= gShadow_Freekill_Threshold)
		{
			// Take action...
			switch(gShadow_Freekill_Punishment)
			{
				case FP_Slay:
				{
					ForcePlayerSuicide(attacker);
					PrintToChatAll(CHAT_BANNER, "Freekill Slay", attacker);
					gA_FreekillsOfCT[attacker] = 0;
				}
				case FP_Kick:
				{
					KickClient(attacker, "%t", "Freekill Kick Reason");
					PrintToChatAll(CHAT_BANNER, "Freekill Kick", attacker);
					LogMessage("%N was kicked for killing too many non-rebelling terrorists.", attacker);
				}
				case FP_Ban:
				{
					if (g_bSBAvailable)
					{
						SBBanPlayer(0, attacker, gShadow_Freekill_BanLength, "SM_Hosties: Freekilling");
					}
					else
					{
						decl String:ban_message[128];
						Format(ban_message, sizeof(ban_message), "%T", "Freekill Ban Reason", attacker);
						BanClient(attacker, gShadow_Freekill_BanLength, BANFLAG_AUTO, "SM_Hosties: Freekilling", ban_message);
						PrintToChatAll(CHAT_BANNER, "Freekill Ban", attacker);
					}
				}
			}
		}
		else
		{
			// Add 1 freekill to the records...
			gA_FreekillsOfCT[attacker]++;

			// Notify the player if the server owner so desires...
			if (gShadow_Freekill_Notify)
			{
				PrintHintText(attacker, "%t", "Freekill Record Increased", gA_FreekillsOfCT[attacker], gShadow_Freekill_Threshold+1);
			}
		}
		
		// check for -1 for backward compatibility
		if ((strlen(gShadow_Freekill_Sound) > 0) && !StrEqual(gShadow_Freekill_Sound, "-1"))
		{
			EmitSoundToAll(gShadow_Freekill_Sound);
		}
	}
}
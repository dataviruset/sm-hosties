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
#include <sdkhooks>
#include <sourcebans>
#include <hosties>

// Compiler directives
#pragma semicolon 1

// Constants
#define 	PLUGIN_VERSION	 			"2.0.1"
// Change to include your own clan tag but leave the '%t' intact
#define 	CHAT_BANNER		 			"\x03[SM] \x01%t"
#define 	MAX_DISPLAYNAME_SIZE 	32
#define 	MAX_DATAENTRY_SIZE 		5
#define 	NORMAL_VISION 				90
#define 	SERVERTAG		 			"SM_Hosties v2"

// Note: you cannot safely turn these modules on and off yet. Use cvars to disable functionality.

// Add ability to disable collisions for players
#define	MODULE_NOBLOCK				1
// Add the last request system
#define	MODULE_LASTREQUEST		1
// Add a game description override
#define	MODULE_GAMEDESCRIPTION	1
// Add start weapons for both teams
#define	MODULE_STARTWEAPONS		1
// Add round-end team overlays
#define	MODULE_TEAMOVERLAYS		1
// Add !rules command
#define	MODULE_RULES				1
// Add !checkplayers command
#define	MODULE_CHECKPLAYERS		1
// Add muting system
#define	MODULE_MUTE					1
// Add freekill detection and prevention
#define	MODULE_FREEKILL			1

/******************************************************************************
                   !EDIT BELOW THIS COMMENT AT YOUR OWN PERIL!
******************************************************************************/

// Global vars
new bool:g_bSBAvailable = false;

// From freekillers.sp
enum FreekillPunishment
{
	FP_Slay = 0,
	FP_Kick,
	FP_Ban
};

new Handle:gH_Cvar_Freekill_Sound = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_Threshold = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_Notify = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_BanLength = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_Punishment = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_Reset = INVALID_HANDLE;
new Handle:gH_Cvar_Freekill_Sound_Mode = INVALID_HANDLE;
new String:gShadow_Freekill_Sound[PLATFORM_MAX_PATH];
new gShadow_Freekill_Threshold;
new gShadow_Freekill_BanLength;
new gShadow_Freekill_Reset;
new gShadow_Freekill_Sound_Mode;
new FreekillPunishment:gShadow_Freekill_Punishment;
new bool:gShadow_Freekill_Notify;
new gA_FreekillsOfCT[MAXPLAYERS+1];

#if (MODULE_NOBLOCK == 1)
#include "hosties/noblock.sp"
#endif
#if (MODULE_LASTREQUEST == 1)
#include "hosties/lastrequest.sp"
#endif
#if (MODULE_GAMEDESCRIPTION == 1)
#include "hosties/gamedescription.sp"
#endif
#if (MODULE_STARTWEAPONS == 1)
#include "hosties/startweapons.sp"
#endif
#if (MODULE_TEAMOVERLAYS == 1)
#include "hosties/teamoverlays.sp"
#endif
#if (MODULE_RULES == 1)
#include "hosties/rules.sp"
#endif
#if (MODULE_CHECKPLAYERS == 1)
#include "hosties/checkplayers.sp"
#endif
#if (MODULE_MUTE == 1)
#include "hosties/muteprisoners.sp"
#endif
#if (MODULE_FREEKILL == 1)
#include "hosties/freekillers.sp"
#endif

// ConVars
new Handle:gH_Cvar_Add_ServerTag	= INVALID_HANDLE;
new Handle:gH_Cvar_Display_Advert = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM_Hosties v2",
	author = "databomb & dataviruset",
	description = "Hosties/jailbreak plugin for SourceMod",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=108810"
};

public OnPluginStart()
{
	// Load translations
	LoadTranslations("hosties.phrases");

	// Events hooks
	HookEvent("round_start", Event_RoundStart);

	// Create ConVars
	gH_Cvar_Add_ServerTag = CreateConVar("sm_hosties_add_servertag", "1", "Enable or disable automatic adding of SM_Hosties in sv_tags (visible from the server browser in CS:S): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gH_Cvar_Display_Advert = CreateConVar("sm_hosties_display_advert", "1", "Enable or disable the display of the Powered by SM Hosties message at the start of each round.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	CreateConVar("sm_hosties_version", PLUGIN_VERSION, "SM_Hosties plugin version (unchangeable)", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnPluginStart();
	#endif
	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnPluginStart();
	#endif
	#if (MODULE_CHECKPLAYERS == 1)
	CheckPlayers_OnPluginStart();
	#endif
	#if (MODULE_RULES == 1)
	Rules_OnPluginStart();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDescription_OnPluginStart();
	#endif
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnPluginStart();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnPluginStart();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnPluginStart();
	#endif
	#if (MODULE_FREEKILL == 1)
	Freekillers_OnPluginStart();
	#endif
	
	AutoExecConfig(true, "sm_hosties2");
}

public OnMapStart()
{
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDescription_OnMapStart();
	#endif
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnMapStart();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnMapStart();
	#endif
}

public OnMapEnd()
{
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDescription_OnMapEnd();
	#endif
	#if (MODULE_FREEKILL == 1)	
	Freekillers_OnMapEnd();
	#endif
}

public OnAllPluginsLoaded()
{
	if (LibraryExists("sourcebans"))
	{
		g_bSBAvailable = true;
	}
	
	#if (MODULE_MUTE == 1)
	MutePrisoners_AllPluginsLoaded();
	#endif	
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "sourcebans"))
	{
		g_bSBAvailable = true;
	}
}

public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "sourcebans"))
	{
		g_bSBAvailable = false;
	}
}

public OnClientConnected(client)
{
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnClientConnected(client);
	#endif
}

public OnConfigsExecuted()
{
	if (GetConVarInt(gH_Cvar_Add_ServerTag) == 1)
	{
		ServerCommand("sv_tags %s\n", SERVERTAG);
	}
	
	#if (MODULE_FREEKILL == 1)
	Freekillers_OnConfigsExecuted();
	#endif
	#if (MODULE_MUTE == 1)
	MutePrisoners_OnConfigsExecuted();
	#endif
	#if (MODULE_CHECKPLAYERS == 1)
	CheckPlayers_OnConfigsExecuted();
	#endif
	#if (MODULE_GAMEDESCRIPTION == 1)
	GameDesc_OnConfigsExecuted();
	#endif
	#if (MODULE_TEAMOVERLAYS == 1)
	TeamOverlays_OnConfigsExecuted();
	#endif
	#if (MODULE_RULES == 1)
	Rules_OnConfigsExecuted();
	#endif
	#if (MODULE_LASTREQUEST == 1)
	LastRequest_OnConfigsExecuted();
	#endif
	#if (MODULE_NOBLOCK == 1)
	NoBlock_OnConfigsExecuted();
	#endif
	#if (MODULE_STARTWEAPONS == 1)
	StartWeapons_OnConfigsExecuted();
	#endif
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(gH_Cvar_Display_Advert))
	{
		// Print out a messages about SM_Hosties 
		PrintToChatAll(CHAT_BANNER, "Powered By Hosties");
	}
}
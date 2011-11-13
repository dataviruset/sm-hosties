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

// Sample Last Request Plugin: Shotgun Wars!

#include <sourcemod>
#include <sdktools>
// Make certain the lastrequest.inc is last on the list
#include <hosties>
#include <lastrequest>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0.1"

// This global will store the index number for the new Last Request
new g_LREntryNum;

new Handle:gH_Timer_GiveHealth = INVALID_HANDLE;
new Handle:gH_Timer_Countdown = INVALID_HANDLE;

new bool:bAllCountdownsCompleted = false;

enum theColors
{
	color_Red = 0,
	color_Green,
	color_Blue
};

public Plugin:myinfo =
{
	name = "Last Request: Shotgun Wars (sample)",
	author = "databomb & dataviruset",
	description = "An example of how to add LRs",
	version = PLUGIN_VERSION,
	url = "vintagejailbreak.org"
};

public OnPluginStart()
{
	// Load translations
	LoadTranslations("shotgunwars.phrases");
	
	// Create any cvars you need here
	
}

public OnConfigsExecuted()
{
	static bool:bAddedShotgunWars = false;
	if (!bAddedShotgunWars)
	{
		g_LREntryNum = AddLastRequestToList(ShotgunWars_Start, ShotgunWars_Stop, "Shotgun Wars");
		bAddedShotgunWars = true;
	}	
}

// The plugin should remove any LRs it loads when it's unloaded
public OnPluginEnd()
{
	RemoveLastRequestFromList(ShotgunWars_Start, ShotgunWars_Stop, "Shotgun Wars");
}

public ShotgunWars_Start(Handle:LR_Array, iIndexInArray)
{
	new This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType);
	if (This_LR_Type == g_LREntryNum)
	{		
		new LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
		new LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
		
		// check datapack value
		new LR_Pack_Value = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);	
		switch (LR_Pack_Value)
		{
			case -1:
			{
				PrintToServer("no info included");
			}
		}
		
		SetEntityHealth(LR_Player_Prisoner, 200);
		SetEntityHealth(LR_Player_Guard, 200);
		
		StripAllWeapons(LR_Player_Prisoner);
		StripAllWeapons(LR_Player_Guard);
		
		// Store a countdown timer variable - we'll use 3 seconds
		SetArrayCell(LR_Array, iIndexInArray, 3, _:Block_Global1);
		
		if (gH_Timer_Countdown == INVALID_HANDLE)
		{
			gH_Timer_Countdown = CreateTimer(1.0, Timer_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		
		PrintToChatAll(CHAT_BANNER, "LR SGW Start", LR_Player_Prisoner, LR_Player_Guard);
	}
}

public ShotgunWars_Stop(This_LR_Type, LR_Player_Prisoner, LR_Player_Guard)
{
	if (This_LR_Type == g_LREntryNum)
	{
		if (IsClientInGame(LR_Player_Prisoner))
		{
			SetEntityGravity(LR_Player_Prisoner, 1.0);
			if (IsPlayerAlive(LR_Player_Prisoner))
			{
				SetEntityHealth(LR_Player_Prisoner, 100);
				GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
				PrintToChatAll(CHAT_BANNER, "SGW Win", LR_Player_Prisoner);
			}
		}
		if (IsClientInGame(LR_Player_Guard))
		{
			SetEntityGravity(LR_Player_Guard, 1.0);
			if (IsPlayerAlive(LR_Player_Guard))
			{
				SetEntityHealth(LR_Player_Guard, 100);
				GivePlayerItem(LR_Player_Guard, "weapon_knife");
				PrintToChatAll(CHAT_BANNER, "SGW Win", LR_Player_Guard);
			}
		}
	}
}

public Action:Timer_Countdown(Handle:timer)
{
	new numberOfLRsActive = ProcessAllLastRequests(ShotgunWars_Countdown, g_LREntryNum);
	if ((numberOfLRsActive <= 0) || bAllCountdownsCompleted)
	{
		gH_Timer_Countdown = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:Timer_GiveHealth(Handle:timer)
{
	// Sort through all last requests
	new numberOfLRsActive = ProcessAllLastRequests(ShotgunWars_Heal, g_LREntryNum);	
	if (numberOfLRsActive <= 0)
	{
		gH_Timer_GiveHealth = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public ShotgunWars_Countdown(Handle:LR_Array, iIndexInArray)
{
	new LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
	new LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
	
	new countdown = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);
	if (countdown > 0)
	{
		bAllCountdownsCompleted = false;
		PrintCenterText(LR_Player_Prisoner, "LR begins in %i...", countdown);
		PrintCenterText(LR_Player_Guard, "LR begins in %i...", countdown);
		SetArrayCell(LR_Array, iIndexInArray, --countdown, _:Block_Global1);		
	}
	else if (countdown == 0)
	{
		bAllCountdownsCompleted = true;
		SetArrayCell(LR_Array, iIndexInArray, --countdown, _:Block_Global1);	
		
		new PrisonerGun = GivePlayerItem(LR_Player_Prisoner, "weapon_xm1014");
		new GuardGun = GivePlayerItem(LR_Player_Guard, "weapon_xm1014");
		
		SetArrayCell(LR_Array, iIndexInArray, PrisonerGun, _:Block_PrisonerData);
		SetArrayCell(LR_Array, iIndexInArray, GuardGun, _:Block_GuardData);
		
		SetEntityRenderFx(PrisonerGun, RenderFx:RENDERFX_DISTORT);
		SetEntityRenderFx(GuardGun, RenderFx:RENDERFX_DISTORT);
		
		SetEntityRenderColor(PrisonerGun, 255, 0, 0, 255);
		SetEntityRenderColor(GuardGun, 255, 0, 0, 255);
		
		SetEntityGravity(LR_Player_Prisoner, 0.7);
		SetEntityGravity(LR_Player_Guard, 0.7);
		
		if (gH_Timer_GiveHealth == INVALID_HANDLE)
		{
			gH_Timer_GiveHealth = CreateTimer(2.0, Timer_GiveHealth, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public ShotgunWars_Heal(Handle:LR_Array, iIndexInArray)
{
	new Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
	new Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
	
	SetEntityHealth(Prisoner, GetClientHealth(Prisoner) + 10);
	SetEntityHealth(Guard, GetClientHealth(Guard) + 10);
	
	new PrisonerGun = GetArrayCell(LR_Array, iIndexInArray, _:Block_PrisonerData);
	new GuardGun = GetArrayCell(LR_Array, iIndexInArray, _:Block_GuardData);
	
	static randomColor = _:color_Red;
	
	switch (randomColor % 3)
	{
		case color_Red:
		{
			SetEntityRenderColor(PrisonerGun, 255, 0, 0, 255);
			SetEntityRenderColor(GuardGun, 255, 0, 0, 255);
		}
		case color_Green:
		{
			SetEntityRenderColor(PrisonerGun, 0, 255, 0, 255);
			SetEntityRenderColor(GuardGun, 0, 255, 0, 255);		
		}
		case color_Blue:
		{
			SetEntityRenderColor(PrisonerGun, 0, 0, 255, 255);
			SetEntityRenderColor(GuardGun, 0, 0, 255, 255);
		}
	}
	
	randomColor++;
}
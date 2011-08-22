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
#include <sdkhooks>
#include <hosties>

// this looks largely from psychonic, so thanks to him!
new bool:g_bIsMapLoaded = false;
new Handle:gH_Cvar_GameDescriptionOn = INVALID_HANDLE;
new bool:gShadow_GameDescriptionOn;

#define GAMEDESC "Hosties/jailbreak"

GameDescription_OnPluginStart()
{
	gH_Cvar_GameDescriptionOn = CreateConVar("sm_hosties_override_gamedesc", "1", "Enable or disable an override of the game description (standard Counter-Strike: Source, override to Hosties/jailbreak): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_GameDescriptionOn = true;
	
	HookConVarChange(gH_Cvar_GameDescriptionOn, GameDescription_CvarChanged);
}

public GameDescription_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_GameDescriptionOn)
	{
		gShadow_GameDescriptionOn = bool:StringToInt(newValue);
	}
}

GameDescription_OnMapStart()
{
	g_bIsMapLoaded = true;
}

GameDescription_OnMapEnd()
{
	g_bIsMapLoaded = false;
}

public Action:OnGetGameDescription(String:gameDesc[64])
{
	if (gShadow_GameDescriptionOn && g_bIsMapLoaded)
	{
		strcopy(gameDesc, sizeof(gameDesc), GAMEDESC);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}


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

// this looks like it's largely from psychonic, so thanks to him!
new bool:g_bIsMapLoaded = false;
new Handle:gH_Cvar_GameDescriptionOn = INVALID_HANDLE;
new bool:gShadow_GameDescriptionOn;
new Handle:gH_Cvar_GameDescriptionTag = INVALID_HANDLE;
new String:gShadow_GameDescriptionTag[64];

GameDescription_OnPluginStart()
{
	gH_Cvar_GameDescriptionOn = CreateConVar("sm_hosties_override_gamedesc", "1", "Enable or disable an override of the game description (standard Counter-Strike: Source, override to Hosties/jailbreak): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_GameDescriptionOn = true;
	
	gH_Cvar_GameDescriptionTag = CreateConVar("sm_hosties_gamedesc_tag", "Hosties/Jailbreak v2", "Sets the game description tag.", FCVAR_PLUGIN);
	Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), "Hosties/Jailbreak v2");
	
	HookConVarChange(gH_Cvar_GameDescriptionOn, GameDescription_CvarChanged);
	HookConVarChange(gH_Cvar_GameDescriptionTag, GameDescription_CvarChanged);
}

public GameDescription_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_GameDescriptionOn)
	{
		gShadow_GameDescriptionOn = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_GameDescriptionTag)
	{
		Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), newValue);
	}
}

GameDesc_OnConfigsExecuted()
{
	gShadow_GameDescriptionOn = GetConVarBool(gH_Cvar_GameDescriptionOn);
	GetConVarString(gH_Cvar_GameDescriptionTag, gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag));
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
		strcopy(gameDesc, sizeof(gameDesc), gShadow_GameDescriptionTag);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

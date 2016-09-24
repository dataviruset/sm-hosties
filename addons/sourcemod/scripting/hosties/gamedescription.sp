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
#include <hosties>

Handle gH_Cvar_GameDescriptionOn = null;
bool gShadow_GameDescriptionOn;
Handle gH_Cvar_GameDescriptionTag = null;
char gShadow_GameDescriptionTag[64];
bool g_bSTAvailable = false; // SteamTools

void GameDescription_OnPluginStart()
{
	gH_Cvar_GameDescriptionOn = CreateConVar("sm_hosties_override_gamedesc", "1", "Enable or disable an override of the game description (standard Counter-Strike: Source, override to Hosties/jailbreak): 0 - disable, 1 - enable", FCVAR_NONE, true, 0.0, true, 1.0);
	gShadow_GameDescriptionOn = true;
	
	gH_Cvar_GameDescriptionTag = CreateConVar("sm_hosties_gamedesc_tag", "Hosties/Jailbreak v2", "Sets the game description tag.", FCVAR_NONE);
	Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), "Hosties/Jailbreak v2");
	
	HookConVarChange(gH_Cvar_GameDescriptionOn, GameDescription_CvarChanged);
	HookConVarChange(gH_Cvar_GameDescriptionTag, GameDescription_CvarChanged);
	
	// check for SteamTools
	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_SetGameDescription") == FeatureStatus_Available)
	{
		g_bSTAvailable = true;
	}
}

public void GameDescription_CvarChanged(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == gH_Cvar_GameDescriptionOn)
	{
		gShadow_GameDescriptionOn = view_as<bool>(StringToInt(newValue));
	}
	else if (cvar == gH_Cvar_GameDescriptionTag)
	{
		Format(gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag), newValue);
		
		if (gShadow_GameDescriptionOn && g_bSTAvailable)
		{
			SteamWorks_SetGameDescription(gShadow_GameDescriptionTag);
		}
	}
}

void GameDesc_OnConfigsExecuted()
{
	gShadow_GameDescriptionOn = GetConVarBool(gH_Cvar_GameDescriptionOn);
	GetConVarString(gH_Cvar_GameDescriptionTag, gShadow_GameDescriptionTag, sizeof(gShadow_GameDescriptionTag));
	
	if (gShadow_GameDescriptionOn && g_bSTAvailable)
	{
		SteamWorks_SetGameDescription(gShadow_GameDescriptionTag);
	}
}

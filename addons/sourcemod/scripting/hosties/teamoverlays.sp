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
#include <sdktools>
#include <hosties>

#define FILE_SEPARATOR_LENGTH 3

Handle gH_Cvar_T_Material = null;
Handle gH_Cvar_T_Texture = null;
Handle gH_Cvar_CT_Material = null;
Handle gH_Cvar_CT_Texture = null;

char gShadow_T_Material[PLATFORM_MAX_PATH];
char gShadow_T_Texture[PLATFORM_MAX_PATH];
char gShadow_CT_Material[PLATFORM_MAX_PATH];
char gShadow_CT_Texture[PLATFORM_MAX_PATH];

void TeamOverlays_OnPluginStart()
{
	HookEvent("round_start", TeamOverlays_RoundStart);
	HookEvent("round_end", TeamOverlays_RoundEnd);
	
	gH_Cvar_T_Material = CreateConVar("sm_hosties_roundend_overlay_t_vmt", "overlays/sm_hosties/prisoners_win.vmt", "Terrorist overlay material file", FCVAR_NONE);
	Format(gShadow_T_Material, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisoners_win.vmt");
	
	gH_Cvar_T_Texture = CreateConVar("sm_hosties_roundend_overlay_t", "overlays/sm_hosties/prisoners_win.vtf", "Terrorist overlay texture file", FCVAR_NONE);
	Format(gShadow_T_Texture, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisoners_win.vtf");
	
	gH_Cvar_CT_Material = CreateConVar("sm_hosties_roundend_overlay_ct_vmt", "overlays/sm_hosties/prisonguards_win.vmt", "Counter-Terrorist overlay material file", FCVAR_NONE);
	Format(gShadow_CT_Material, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisonguards_win.vmt");
	
	gH_Cvar_CT_Texture = CreateConVar("sm_hosties_roundend_overlay_ct", "overlays/sm_hosties/prisonguards_win.vtf", "Counter-Terrorist overlay texture file", FCVAR_NONE);
	Format(gShadow_CT_Texture, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisonguards_win.vtf");
	
	HookConVarChange(gH_Cvar_T_Material, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_T_Texture, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Material, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Texture, TeamOverlay_CvarChanged);
}

void TeamOverlays_OnConfigsExecuted()
{
	GetConVarString(gH_Cvar_T_Material, gShadow_T_Material, sizeof(gShadow_T_Material));
	GetConVarString(gH_Cvar_T_Texture, gShadow_T_Texture, sizeof(gShadow_T_Texture));
	GetConVarString(gH_Cvar_CT_Material, gShadow_CT_Material, sizeof(gShadow_CT_Material));
	GetConVarString(gH_Cvar_CT_Texture, gShadow_CT_Texture, sizeof(gShadow_CT_Texture));
}

public void TeamOverlay_CvarChanged(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == gH_Cvar_T_Material)
	{
		Format(gShadow_T_Material, PLATFORM_MAX_PATH, newValue);
	}
	else if (cvar == gH_Cvar_T_Texture)
	{
		Format(gShadow_T_Texture, PLATFORM_MAX_PATH, newValue);
	}
	else if (cvar == gH_Cvar_CT_Material)
	{
		Format(gShadow_CT_Material, PLATFORM_MAX_PATH, newValue);
	}
	else if (cvar == gH_Cvar_CT_Texture)
	{
		Format(gShadow_CT_Texture, PLATFORM_MAX_PATH, newValue);
	}
}

void TeamOverlays_OnMapStart()
{
	MediaType overlayType = type_Decal;
	if (strlen(gShadow_T_Material) > 0)
	{
		CacheTheFile(gShadow_T_Material, overlayType);
	}
	if (strlen(gShadow_T_Texture) > 0)
	{
		CacheTheFile(gShadow_T_Texture, overlayType);
	}
	if (strlen(gShadow_CT_Material) > 0)
	{	
		CacheTheFile(gShadow_CT_Material, overlayType);
	}
	if (strlen(gShadow_CT_Texture) > 0)
	{
		CacheTheFile(gShadow_CT_Texture, overlayType);
	}
}

public Action TeamOverlays_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	// overlay stuff
	int winner_team = GetEventInt(event, "winner");
	char theOverlay[PLATFORM_MAX_PATH];
	int iOverlayLength = 0;
	
	if (winner_team == CS_TEAM_T)
	{
		if (strlen(gShadow_T_Material) > 0)
		{
			iOverlayLength = strlen(gShadow_T_Material);
			strcopy(theOverlay, iOverlayLength-FILE_SEPARATOR_LENGTH, gShadow_T_Material);
			ShowOverlayToAll(theOverlay);
		}
	}
	else if (winner_team == CS_TEAM_CT)
	{
		if (strlen(gShadow_CT_Material) > 0)
		{
			iOverlayLength = strlen(gShadow_CT_Material);
			strcopy(theOverlay, iOverlayLength-FILE_SEPARATOR_LENGTH, gShadow_CT_Material);
			ShowOverlayToAll(theOverlay);		
		}
	}
}

public Action TeamOverlays_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	ShowOverlayToAll("");
}

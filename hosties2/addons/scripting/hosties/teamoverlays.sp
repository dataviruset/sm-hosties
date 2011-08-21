#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <hosties>

#define FILE_SEPARATOR_LENGTH 3

new Handle:gH_Cvar_T_Material = INVALID_HANDLE;
new Handle:gH_Cvar_T_Texture = INVALID_HANDLE;
new Handle:gH_Cvar_CT_Material = INVALID_HANDLE;
new Handle:gH_Cvar_CT_Texture = INVALID_HANDLE;

new String:gShadow_T_Material[PLATFORM_MAX_PATH];
new String:gShadow_T_Texture[PLATFORM_MAX_PATH];
new String:gShadow_CT_Material[PLATFORM_MAX_PATH];
new String:gShadow_CT_Texture[PLATFORM_MAX_PATH];

TeamOverlays_OnPluginStart()
{
	HookEvent("round_start", TeamOverlays_RoundStart);
	HookEvent("round_end", TeamOverlays_RoundEnd);
	
	gH_Cvar_T_Material = CreateConVar("sm_hosties_roundend_overlay_t_vmt", "overlays/sm_hosties/prisoners_win.vmt", "Terrorist overlay material file", FCVAR_PLUGIN);
	Format(gShadow_T_Material, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisoners_win.vmt");
	
	gH_Cvar_T_Texture = CreateConVar("sm_hosties_roundend_overlay_t", "overlays/sm_hosties/prisoners_win.vtf", "Terrorist overlay texture file", FCVAR_PLUGIN);
	Format(gShadow_T_Texture, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisoners_win.vtf");
	
	gH_Cvar_CT_Material = CreateConVar("sm_hosties_roundend_overlay_ct_vmt", "overlays/sm_hosties/prisonguards_win.vmt", "Counter-Terrorist overlay material file", FCVAR_PLUGIN);
	Format(gShadow_CT_Material, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisonguards_win.vmt");
	
	gH_Cvar_CT_Texture = CreateConVar("sm_hosties_roundend_overlay_ct", "overlays/sm_hosties/prisonguards_win.vtf", "Counter-Terrorist overlay texture file", FCVAR_PLUGIN);
	Format(gShadow_CT_Texture, PLATFORM_MAX_PATH, "overlays/sm_hosties/prisonguards_win.vtf");
	
	HookConVarChange(gH_Cvar_T_Material, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_T_Texture, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Material, TeamOverlay_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Texture, TeamOverlay_CvarChanged);
}

TeamOverlays_OnConfigsExecuted()
{
	GetConVarString(gH_Cvar_T_Material, gShadow_T_Material, sizeof(gShadow_T_Material));
	GetConVarString(gH_Cvar_T_Texture, gShadow_T_Texture, sizeof(gShadow_T_Texture));
	GetConVarString(gH_Cvar_CT_Material, gShadow_CT_Material, sizeof(gShadow_CT_Material));
	GetConVarString(gH_Cvar_CT_Texture, gShadow_CT_Texture, sizeof(gShadow_CT_Texture));
}

public TeamOverlay_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
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

TeamOverlays_OnMapStart()
{
	new MediaType:overlayType = type_Decal;
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

public TeamOverlays_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	// overlay stuff
	new winner_team = GetEventInt(event, "winner");
	decl String:theOverlay[PLATFORM_MAX_PATH];
	new iOverlayLength = 0;
	
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

public TeamOverlays_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	ShowOverlayToAll("");
}
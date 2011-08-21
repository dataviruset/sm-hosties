#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <hosties>

new Handle:gH_Cvar_StartWeaponsOn = INVALID_HANDLE;
new Handle:gH_Cvar_T_Weapons = INVALID_HANDLE;
new Handle:gH_Cvar_CT_Weapons = INVALID_HANDLE;
new bool:gShadow_StartWeaponsOn;
new String:gShadow_T_Weapons[256];
new String:gShadow_CT_Weapons[256];
new String:gs_T_WeaponList[8][32];
new String:gs_CT_WeaponList[8][32];
new g_iSizeOfTList;
new g_iSizeOfCTList;

StartWeapons_OnPluginStart()
{
	gH_Cvar_StartWeaponsOn = CreateConVar("sm_hosties_startweapons_on", "1", "Enable or disable configurable payloads for each time on player spawn", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_StartWeaponsOn = true;
	gH_Cvar_T_Weapons = CreateConVar("sm_hosties_t_start", "weapon_knife", "Comma delimitted list of items to give to Ts at spawn", FCVAR_PLUGIN);
	Format(gShadow_T_Weapons, sizeof(gShadow_T_Weapons), "weapon_knife");
	gH_Cvar_CT_Weapons = CreateConVar("sm_hosties_ct_start", "weapon_knife,weapon_m4a1,weapon_usp", "Comma delimitted list of items to give to CTs at spawn", FCVAR_PLUGIN);
	Format(gShadow_CT_Weapons, sizeof(gShadow_CT_Weapons), "weapon_knife,weapon_m4a1,weapon_usp");
	
	UpdateStartWeapons();
	
	HookEvent("player_spawn", StartWeapons_Spawn);
	
	HookConVarChange(gH_Cvar_StartWeaponsOn, StartWeapons_CvarChanged);
	HookConVarChange(gH_Cvar_T_Weapons, StartWeapons_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Weapons, StartWeapons_CvarChanged);
}

public StartWeapons_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (gShadow_StartWeaponsOn)
	{
		StripAllWeapons(client);
		
		new team = GetClientTeam(client);
		switch (team)
		{
			case CS_TEAM_T:
			{
				for (new Tidx = 0; Tidx < g_iSizeOfTList; Tidx++)
				{
					GivePlayerItem(client, gs_T_WeaponList[Tidx]);
				}
			}
			case CS_TEAM_CT:
			{
				for (new CTidx = 0; CTidx < g_iSizeOfCTList; CTidx++)
				{
					GivePlayerItem(client, gs_CT_WeaponList[CTidx]);
				}
			}
		}
	}
}

public StartWeapons_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_StartWeaponsOn)
	{
		gShadow_StartWeaponsOn = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_T_Weapons)
	{
		Format(gShadow_T_Weapons, sizeof(gShadow_T_Weapons), newValue);
		UpdateStartWeapons();
	}
	else if (cvar == gH_Cvar_CT_Weapons)
	{
		Format(gShadow_CT_Weapons, sizeof(gShadow_CT_Weapons), newValue);
		UpdateStartWeapons();
	}
}

void:UpdateStartWeapons()
{
	g_iSizeOfTList = ExplodeString(gShadow_T_Weapons, ",", gs_T_WeaponList, sizeof(gs_T_WeaponList), sizeof(gs_T_WeaponList[]));
	g_iSizeOfCTList = ExplodeString(gShadow_CT_Weapons, ",", gs_CT_WeaponList, sizeof(gs_CT_WeaponList), sizeof(gs_CT_WeaponList[]));
}


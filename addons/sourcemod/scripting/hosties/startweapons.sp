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
#include <sdktools>
#include <cstrike>
#include <hosties>

Handle gH_Cvar_StartWeaponsOn = null;
Handle gH_Cvar_T_Weapons = null;
Handle gH_Cvar_CT_Weapons = null;
bool gShadow_StartWeaponsOn;
char gShadow_T_Weapons[256];
char gShadow_CT_Weapons[256];
char gs_T_WeaponList[8][32];
char gs_CT_WeaponList[8][32];
int g_iSizeOfTList;
int g_iSizeOfCTList;

void StartWeapons_OnPluginStart()
{
	gH_Cvar_StartWeaponsOn = CreateConVar("sm_hosties_startweapons_on", "1", "Enable or disable configurable payloads for each time on player spawn", FCVAR_NONE, true, 0.0, true, 1.0);
	gShadow_StartWeaponsOn = true;
	gH_Cvar_T_Weapons = CreateConVar("sm_hosties_t_start", "weapon_knife", "Comma delimitted list of items to give to Ts at spawn", FCVAR_NONE);
	Format(gShadow_T_Weapons, sizeof(gShadow_T_Weapons), "weapon_knife");
	if (g_Game == Game_CSS)
	{
		gH_Cvar_CT_Weapons = CreateConVar("sm_hosties_ct_start", "weapon_knife,weapon_m4a1,weapon_usp", "Comma delimitted list of items to give to CTs at spawn", FCVAR_NONE);
		Format(gShadow_CT_Weapons, sizeof(gShadow_CT_Weapons), "weapon_knife,weapon_m4a1,weapon_usp");
	}
	else if (g_Game == Game_CSGO)
	{
		gH_Cvar_CT_Weapons = CreateConVar("sm_hosties_ct_start", "weapon_knife,weapon_m4a1,weapon_hkp2000", "Comma delimitted list of items to give to CTs at spawn", FCVAR_NONE);
		Format(gShadow_CT_Weapons, sizeof(gShadow_CT_Weapons), "weapon_knife,weapon_m4a1,weapon_hkp2000");
	}
	UpdateStartWeapons();	
	
	HookEvent("player_spawn", StartWeapons_Spawn);
	
	HookConVarChange(gH_Cvar_StartWeaponsOn, StartWeapons_CvarChanged);
	HookConVarChange(gH_Cvar_T_Weapons, StartWeapons_CvarChanged);
	HookConVarChange(gH_Cvar_CT_Weapons, StartWeapons_CvarChanged);
}

void StartWeapons_OnConfigsExecuted()
{
	GetConVarString(gH_Cvar_CT_Weapons, gShadow_CT_Weapons, sizeof(gShadow_CT_Weapons));
	GetConVarString(gH_Cvar_T_Weapons, gShadow_T_Weapons, sizeof(gShadow_T_Weapons));
	gShadow_StartWeaponsOn = GetConVarBool(gH_Cvar_StartWeaponsOn);
	UpdateStartWeapons();
}

public Action StartWeapons_Spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (gShadow_StartWeaponsOn)
	{
		StripAllWeapons(client);
		
		int team = GetClientTeam(client);
		switch (team)
		{
			case CS_TEAM_T:
			{
				for (int Tidx = 0; Tidx < g_iSizeOfTList; Tidx++)
				{
					GivePlayerItem(client, gs_T_WeaponList[Tidx]);
				}
			}
			case CS_TEAM_CT:
			{
				for (int CTidx = 0; CTidx < g_iSizeOfCTList; CTidx++)
				{
					char sWeapon[64];
					
					if(GetEngineVersion() == Engine_CSGO && StrEqual(gs_CT_WeaponList[CTidx], "weapon_usp", false))
					{
						Format(sWeapon, sizeof(sWeapon), "weapon_hkp2000");
					}
					else
					{
						Format(sWeapon, sizeof(sWeapon), gs_CT_WeaponList[CTidx]);
					}

					GivePlayerItem(client, sWeapon);
				}
			}
		}
	}
}

public void StartWeapons_CvarChanged(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == gH_Cvar_StartWeaponsOn)
	{
		gShadow_StartWeaponsOn = view_as<bool>(StringToInt(newValue));
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

void UpdateStartWeapons()
{
	g_iSizeOfTList = ExplodeString(gShadow_T_Weapons, ",", gs_T_WeaponList, sizeof(gs_T_WeaponList), sizeof(gs_T_WeaponList[]));
	g_iSizeOfCTList = ExplodeString(gShadow_CT_Weapons, ",", gs_CT_WeaponList, sizeof(gs_CT_WeaponList), sizeof(gs_CT_WeaponList[]));
}


#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <hosties>

new g_Offset_CollisionGroup = -1;
new Handle:gH_Cvar_NoBlock = INVALID_HANDLE;
new bool:gShadow_NoBlock;

NoBlock_OnPluginStart()
{
	gH_Cvar_NoBlock = CreateConVar("sm_hosties_noblock_enable", "1", "Enable or disable integrated removing of player vs player collisions (noblock): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_NoBlock = true;
	
	HookConVarChange(gH_Cvar_NoBlock, NoBlock_CvarChanged);
	
	g_Offset_CollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
	
	HookEvent("player_spawn", NoBlock_PlayerSpawn);
}

public NoBlock_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_NoBlock)
	{
		gShadow_NoBlock = bool:StringToInt(newValue);
	}
}

public NoBlock_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (gShadow_NoBlock)
	{
		UnblockEntity(client, g_Offset_CollisionGroup);
	}
}

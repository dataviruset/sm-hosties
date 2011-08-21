/* 
Last Request Include
*/

// Double include protection
#if defined _LastRequest_Included_
	#endinput
#endif
#define _LastRequest_Included_

// Custom types
enum LastRequest
{
	LR_KnifeFight = 0,
	LR_Shot4Shot,
	LR_GunToss,
	LR_ChickenFight,
	LR_HotPotato,
	LR_Dodgeball,
	LR_NoScope,
	LR_RockPaperScissors,
	LR_Rebel,
	LR_Mag4Mag,
	LR_Race,
	LR_RussianRoulette,
	LR_JumpContest
};

enum PartnersArray
{
	Block_LRType = 0,
	Block_Prisoner,
	Block_Guard,
	Block_PrisonerData,
	Block_GuardData,
	Block_Global1,
	Block_Global2,
	Block_Global3,
	Block_Global4,
	Block_DataPackHandle
};

enum DataType
{
	Type_Int = 0,
	Type_Float,
	Type_Handle,
	Type_LastRequest,
	Type_PartnerArray
};

enum LR_Structure
{
	DataType:LR_Type,
	DataType:Prisoner_Index,
	DataType:Guard_Index,
	DataType:Prisoner_Data,
	DataType:Guard_Data,
	DataType:Global1,
	DataType:Global2,
	DataType:Global3,
	DataType:Global4,
	DataType:TheDataPack
};

public SharedPlugin:__pl_lastrequest =
{
        name = "lastrequest",
        file = "sm_hosties.smx",
        required = 1,
};

public __pl_lastrequest_SetNTVOptional()
{
        MarkNativeAsOptional("IsClientRebel");
        MarkNativeAsOptional("IsClientInLastRequest");
        MarkNativeAsOptional("AddLastRequestToList");
        MarkNativeAsOptional("RemoveLastRequestFromList");
        MarkNativeAsOptional("ProcessAllLastRequests");
}

functag FuncLastRequest public(type, prisoner, guard);
functag FuncProcessLR public(Handle:array, iLRNumber);

/**
 * Find if a client is listed as a rebel.
 * 
 * @param client				Client index.
 * @return						True if rebel, false otherwise.
 * @error                       Invalid client index.
 */
native bool:IsClientRebel(client);

/**
 * Find if a client is in a last request.
 * 
 * @param client				Client index.
 * @return						False if not in LR
 *									Otherwise client index of partner or -1 if in LR but no partner exists
 * @error                       Invalid client index.
 */
 native IsClientInLastRequest(client);

/**
 * Adds a custom last request.
 * 
 * @param Start					Function call to when the LR is started.
 * @param Stop					Function call to when the LR is ended.
 * @param LR_Name				The name for the LR that will appear on the menu.
 * @return						The type index of the LR added.
 */
native AddLastRequestToList(FuncProcessLR:Start, FuncLastRequest:Stop, String:LR_Name[]);

/**
 * Removes a custom last request.
 * 
 * @param Start					Function call to when the LR is started.
 * @param Stop					Function call to when the LR is ended.
 * @param LR_Name				Name of the LR that appeared on the menu.
 * @noreturn						
 * @error                     	Last request not found.
 */
native void:RemoveLastRequestFromList(FuncProcessLR:Start, FuncLastRequest:Stop, String:LR_Name[]);

/**
 * Removes a custom last request.
 * 
 * @param ProcessLR				Function call to process each last request.
 * @param iLastRequestIndex		Index number of last request in array.
 * @return						Number of last requests in progress.
 */
native ProcessAllLastRequests(FuncProcessLR:ProcessLR, iLastRequestIndex);

stock SetThirdPerson(client)
{
	if (!client && IsValidEntity(client) && client < MaxClients+1)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 0);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 1);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(client, Prop_Send, "m_iFOV", 120);
	}
}

stock SetFirstPerson(client)
{
	if (!client && IsValidEntity(client) && client < MaxClients+1)
	{
		SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", 1);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
	}
}

stock CancelAllMenus()
{
	for (new idx = 1; idx < MaxClients; idx++)
	{
		if (IsClientInGame(idx))
		{
			if (GetClientMenu(idx))
			{
				CancelClientMenu(idx);
			}
		}
	}
}

stock ClosePotentialLRMenus()
{
   for (new idx = 1; idx < MaxClients; idx++)
   {
      if (IsClientInGame(idx))
      {
			if (GetClientTeam(idx) == CS_TEAM_T)
			{
				if (GetClientMenu(idx))
				{
					CancelClientMenu(idx);
				}
			}
      }
   }
}

stock bool:PlayerHasGun(client)
{
	if (PlayerHasPrimary(client) || PlayerHasSecondary(client))
	{
		return true;
	}
	return false;
}

stock bool:PlayerHasPrimary(client)
{
	if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
	{
		return true;
	}
	return false;
}

stock bool:PlayerHasSecondary(client)
{
	if (GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
	{
		return true;
	}
	return false;
}

// filter function to ignore everything
public bool:Trace_FilterNothing(entity, contentsMask)
{
	return entity == 0;
}

// Based on Client_IsLookingAtWall from SM-LIB with permission from Berni
// detects if it's safe to teleport a player where the player is aiming
stock bool:IsClientTooNearObstacle(client)
{
	new Float:distance = 110.0;
	decl Float:posEye[3], Float:posEyeAngles[3];
	new bool:isClientLookingAtWall = false;
	
	GetClientEyePosition(client, posEye);
	GetClientEyeAngles(client,	posEyeAngles);
	
	posEyeAngles[0] = 0.0;
	
	new Handle:trace = TR_TraceRayFilterEx(posEye, posEyeAngles, CONTENTS_SOLID, RayType_Infinite, Trace_FilterNothing);
	
	if (TR_DidHit(trace)) {
		decl Float:posEnd[3];

		TR_GetEndPosition(posEnd, trace);
		
		if (GetVectorDistance(posEye, posEnd) <= distance)
		{
			new Float:m_vHullMin[3] = {-16.0, -16.0, 0.0};
			new Float:m_vHullMax[3] = {16.0, 16.0, 72.0};
			new Handle:hullTrace = 	TR_TraceHullEx(posEye, posEnd, m_vHullMin, m_vHullMax, CONTENTS_SOLID);
			if (TR_DidHit(hullTrace))
			{
				TR_GetEndPosition(posEnd, hullTrace);
				if (GetVectorDistance(posEye, posEnd) <= distance)
				{
					isClientLookingAtWall = true;
				}
			}
			CloseHandle(hullTrace);
		}
	}
	
	CloseHandle(trace);	
	return isClientLookingAtWall;
}										 
/*
 * FruitNinja last request originally made by Elad Nava.
 * Fixed to work with SM_Hosties 2.0.4 by CoMaNdO.
 * Modified to be a sample for SM_Hosties 2.0.5 and was used to make & test SM_Hosties 2.0.5 AutoStart function by CoMaNdO.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib> // https://forums.alliedmods.net/showthread.php?t=148387
// Make certain the lastrequest.inc is last on the list
#include <hosties>
#include <lastrequest>

#pragma semicolon 1

#define PLUGIN_VERSION "1.1.0"

// This global will store the index number for the new Last Request
new g_LREntryNum;
new This_LR_Type;

// Handles for timers
new Handle:gH_FruitNinja = INVALID_HANDLE;
new Handle:gH_Timer_Countdown = INVALID_HANDLE;
new Handle:gH_Timer_RopeBeam = INVALID_HANDLE;
new Handle:gH_Timer_CircleBeamT = INVALID_HANDLE;
new Handle:gH_Timer_CircleBeamCT = INVALID_HANDLE;

// Handles for cvars
new Handle:gH_Cvar_FruitNinja_M1 = INVALID_HANDLE;
new FruitNinja_Mode1;
new Handle:gH_Cvar_FruitNinja_M2 = INVALID_HANDLE;
new FruitNinja_Mode2;
new Handle:gH_Cvar_FruitNinja_MinDis = INVALID_HANDLE;
new Float:FruitNinja_MinDis;
new Handle:gH_Cvar_FruitNinja_MaxDis = INVALID_HANDLE;
new Float:FruitNinja_MaxDis;
new Handle:gH_Cvar_FruitNinja_M1Time = INVALID_HANDLE;
new FruitNinja_M1Time;
new Handle:gH_Cvar_FruitNinja_M2Time = INVALID_HANDLE;
new FruitNinja_M2Time;
new Handle:gH_Cvar_FruitNinja_ExTimes = INVALID_HANDLE;
new FruitNinja_ExTimes;
new Handle:gH_Cvar_FruitNinja_ExTime = INVALID_HANDLE;
new FruitNinja_ExTime;
new Handle:gH_Cvar_FruitNinja_ExTimeMax = INVALID_HANDLE;
new FruitNinja_ExTimeMax;

// Handles for menus
new Handle:FnSs = INVALID_HANDLE;
new Handle:FnTFSs = INVALID_HANDLE;
new Handle:FnCTFSs = INVALID_HANDLE;

new BeamSprite = -1;
new HaloSprite = -1;
new LaserSprite = -1;
new LaserHalo = -1;
new greenColor[] = {0, 255, 0, 255};
new redColor[] = {255, 0, 0, 255};
new blueColor[] = {0, 0, 255, 255};
new greyColor[] = {128, 128, 128, 255};

new bool:bAllCountdownsCompleted = false;

new LR_Player_Prisoner;
new LR_Player_Guard;
new Float:TFruitSpawnOrigin[3];
new Float:CTFruitSpawnOrigin[3];
new ExtraTimes = 0;
new FruitNinjaRunning;
new FruitNinjaMode;
new FruitNinjaValueChanged = 0;
new g_Game = 0;
new FruitNinjaCounter[2];
new Float:FruitNinjaStarted;
new String:FruitNinjaModels[4][255] = { "models/props/cs_italy/orange.mdl", "models/props/cs_italy/bananna.mdl", "models/props_junk/watermelon01.mdl", "models/props/cs_italy/bananna_bunch.mdl" };

public Plugin:myinfo =
{
	name = "Last Request: FruitNinja",
	author = "Elad Nava & CoMaNdO",
	description = "This plugin adds FruitNinja lastrequest to sm_hosties 2.0.5",
	version = PLUGIN_VERSION,
	url = "http://eladnava.com"
};

public OnPluginStart()
{
	// Load translations
	LoadTranslations("LR.Fruitninja.phrases");
	
	// Detect game
	if(g_Game == 0)
	{
		decl String:gdir[PLATFORM_MAX_PATH];
		GetGameFolderName(gdir,sizeof(gdir));
		if (StrEqual(gdir,"cstrike",false))		g_Game = 1;	else
		if (StrEqual(gdir,"csgo",false))			g_Game = 2;
	}
	
	// ConVars
	gH_Cvar_FruitNinja_M1 =	 		CreateConVar("sm_fn_m1", "1", "Mode 1 (normal) enabled.", 0, true, 0.0, true, 1.0); // had problems with bool for unknown reason, it uses int but converted to bool.
	FruitNinja_Mode1 = true;
	gH_Cvar_FruitNinja_M2 = 			CreateConVar("sm_fn_m2", "1", "Mode 2 (iPhone like) enabled.", 0, true, 0.0, true, 1.0); // had problems with bool for unknown reason, it uses int but converted to bool.
	FruitNinja_Mode2 = true;
	gH_Cvar_FruitNinja_MinDis = 		CreateConVar("sm_fn_mindis", "100.0", "Minimum distance between fruits' spawn.", 0, true, 50.0, true, 100.0);
	FruitNinja_MinDis = 100.0;
	gH_Cvar_FruitNinja_MaxDis = 		CreateConVar("sm_fn_maxdis", "200.0", "Maximum distance between fruits' spawn.", 0, true, 200.0, true, 400.0);
	FruitNinja_MaxDis = 200.0;
	gH_Cvar_FruitNinja_M1Time = 		CreateConVar("sm_fn_m1_time", "45", "Mode 1's (normal) long.", 0, true, 20.0, true, 120.0);
	FruitNinja_M1Time = 45;
	gH_Cvar_FruitNinja_M2Time = 		CreateConVar("sm_fn_m2_time", "75", "Mode 2's (iPhone like) long.", 0, true, 20.0, true, 120.0);
	FruitNinja_M2Time = 75;
	gH_Cvar_FruitNinja_ExTimes = 		CreateConVar("sm_fn_extra_times", "1", "Enable extra time which added if players' scores are equal.", 0, true, 0.0, true, 1.0); // had problems with bool for unknown reason, it uses int but converted to bool.
	FruitNinja_ExTimes = true;
	gH_Cvar_FruitNinja_ExTime = 		CreateConVar("sm_fn_extra_time", "5", "Extra time which added if players' scores are equal.", 0, true, 3.0, true, 10.0);
	FruitNinja_ExTime = 5;
	gH_Cvar_FruitNinja_ExTimeMax = 	CreateConVar("sm_fn_extra_time_max", "3", "Maximum times that extra time will be added", 0, true, 0.0, true, 5.0);
	FruitNinja_ExTimeMax = 3;
	
	// Hook ConVars
	HookConVarChange(gH_Cvar_FruitNinja_M1, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_M2, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_MinDis, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_MaxDis, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_M1Time, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_M2Time, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_ExTimes, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_ExTime, ConVarChanged);
	HookConVarChange(gH_Cvar_FruitNinja_ExTimeMax, ConVarChanged);
	
	AutoExecConfig();
	
	CreateMenus();
}

public ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new newValueInt = StringToInt(newValue);
	new Float:newValueFloat = StringToFloat(newValue);
	
	if(!FruitNinjaRunning)
	{
		if(convar == gH_Cvar_FruitNinja_M1)
		{
			if(newValueInt)
				FruitNinja_Mode1 = true;
			else
				FruitNinja_Mode1 = false;
		}
		if(convar == gH_Cvar_FruitNinja_M2)
		{
			if(newValueInt)
				FruitNinja_Mode2 = true;
			else
				FruitNinja_Mode2 = false;
		}
		
		if(convar == gH_Cvar_FruitNinja_MinDis)
			FruitNinja_MinDis = newValueFloat;

		if(convar == gH_Cvar_FruitNinja_MaxDis)
			FruitNinja_MaxDis = newValueFloat;

		if(convar == gH_Cvar_FruitNinja_M1Time)
			FruitNinja_M1Time = newValueInt;

		if(convar == gH_Cvar_FruitNinja_M2Time)
			FruitNinja_M2Time = newValueInt;
		
		if(convar == gH_Cvar_FruitNinja_ExTimes)
		{
			if(newValueInt)
				FruitNinja_ExTimes = true;
			else
				FruitNinja_ExTimes = false;
		}
		
		if(convar == gH_Cvar_FruitNinja_ExTime)
			FruitNinja_ExTime = newValueInt;
		
		if(convar == gH_Cvar_FruitNinja_ExTimeMax)
			FruitNinja_ExTimeMax = newValueInt;
	}
	else
	{
		FruitNinjaValueChanged = 1;
	}
}

public UpdateValues()
{
	if(GetConVarInt(gH_Cvar_FruitNinja_M1))
		FruitNinja_Mode1 = true;
	else
		FruitNinja_Mode1 = false;
	
	if(GetConVarInt(gH_Cvar_FruitNinja_M2))
		FruitNinja_Mode2 = true;
	else
		FruitNinja_Mode2 = false;
	
	FruitNinja_MinDis = GetConVarFloat(gH_Cvar_FruitNinja_MinDis);
	FruitNinja_MaxDis = GetConVarFloat(gH_Cvar_FruitNinja_MaxDis);
	FruitNinja_M1Time = GetConVarInt(gH_Cvar_FruitNinja_M1Time);
	FruitNinja_M2Time = GetConVarInt(gH_Cvar_FruitNinja_M2Time);
	
	if(GetConVarInt(gH_Cvar_FruitNinja_ExTimes))
		FruitNinja_ExTimes = true;
	else
		FruitNinja_ExTimes = false;
	
	FruitNinja_ExTime = GetConVarInt(gH_Cvar_FruitNinja_ExTime);
	FruitNinja_ExTimeMax = GetConVarInt(gH_Cvar_FruitNinja_ExTimeMax);
	
	CreateMenus();
	FruitNinjaValueChanged = 0;
}

public CreateMenus()
{
	FnSs = CreateMenu(MenuHandler);
	SetMenuTitle(FnSs, "FruitNinja mode select");
	
	if(FruitNinja_Mode1)
		AddMenuItem(FnSs, "Normal", "Normal");
	else
		AddMenuItem(FnSs, "Normal", "Normal", ITEMDRAW_DISABLED);
		
	if(FruitNinja_Mode2)
		AddMenuItem(FnSs, "iPml", "iPhone's multiplayer like");
	else
		AddMenuItem(FnSs, "iPml", "iPhone's multiplayer like", ITEMDRAW_DISABLED);
	
	SetMenuExitButton(FnSs, true);
	
	FnTFSs = CreateMenu(MenuHandler2);
	SetMenuTitle(FnTFSs, "FruitNinja T fruit spawn select");
	AddMenuItem(FnTFSs, "Here", "Spawn T's fruits here");
	SetMenuExitButton(FnTFSs, true);
	
	FnCTFSs = CreateMenu(MenuHandler3);
	SetMenuTitle(FnCTFSs, "FruitNinja CT fruit spawn select");
	AddMenuItem(FnCTFSs, "Here", "Spawn CT's fruits here");
	SetMenuExitButton(FnCTFSs, true);
}

public MenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			FruitNinjaMode = 1;
			InitializeLR();
			FruitNinja_AfterMenu(LR_Player_Prisoner, LR_Player_Guard);
		}
		if(param2 == 1)
		{
			FruitNinjaMode = 2;
			DisplayMenu(FnTFSs, param1, 0);
		}
	}
	if (action == MenuAction_Cancel)
	{
		if(gH_FruitNinja != INVALID_HANDLE)
			CloseHandle(gH_FruitNinja);
		if(gH_Timer_RopeBeam != INVALID_HANDLE)
			CloseHandle(gH_Timer_RopeBeam);
		if(gH_Timer_CircleBeamT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamT);
		if(gH_Timer_CircleBeamCT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamCT);
		gH_FruitNinja = INVALID_HANDLE;
		gH_Timer_RopeBeam = INVALID_HANDLE;
		gH_Timer_CircleBeamT = INVALID_HANDLE;
		gH_Timer_CircleBeamCT = INVALID_HANDLE;
	}
}

public MenuHandler2(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			if((GetEntityFlags(param1) & FL_ONGROUND))
			{
				if(IsClientTooNearObstacle(param1))
				{
					PrintToChat(param1, CHAT_BANNER, "Obstacle");
					DisplayMenu(FnTFSs, param1, 0);
				}
				else
				{
					GetClientAbsOrigin( param1, TFruitSpawnOrigin );
					if(gH_Timer_RopeBeam == INVALID_HANDLE)
						gH_Timer_RopeBeam = CreateTimer(0.1, Timer_RopeBeam, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					if(gH_Timer_CircleBeamT == INVALID_HANDLE)
						gH_Timer_CircleBeamT = CreateTimer(0.5, Timer_CircleBeamT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

					DisplayMenu(FnCTFSs, param1, 0);
				}
			}
			else
			{
				PrintToChat(param1, CHAT_BANNER,"On Ground");
				DisplayMenu(FnTFSs, param1, 0);
			}
		}
	}
	if (action == MenuAction_Cancel)
	{
		if(gH_FruitNinja != INVALID_HANDLE)
			CloseHandle(gH_FruitNinja);
		if(gH_Timer_RopeBeam != INVALID_HANDLE)
			CloseHandle(gH_Timer_RopeBeam);
		if(gH_Timer_CircleBeamT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamT);
		if(gH_Timer_CircleBeamCT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamCT);
		gH_FruitNinja = INVALID_HANDLE;
		gH_Timer_RopeBeam = INVALID_HANDLE;
		gH_Timer_CircleBeamT = INVALID_HANDLE;
		gH_Timer_CircleBeamCT = INVALID_HANDLE;
	}
}

public MenuHandler3(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			GetClientAbsOrigin( param1, CTFruitSpawnOrigin );
			new Float:distanceBetweenSpawns = GetVectorDistance(TFruitSpawnOrigin, CTFruitSpawnOrigin, false);
			if((GetEntityFlags(param1) & FL_ONGROUND))
			{
				if(distanceBetweenSpawns >= FruitNinja_MaxDis)
				{
					PrintToChat(param1, CHAT_BANNER, "Distance too big");
					DisplayMenu(FnCTFSs, param1, 0);
				}
				else if(distanceBetweenSpawns <= FruitNinja_MinDis)
				{
					PrintToChat(param1, CHAT_BANNER, "Distance too small");
					DisplayMenu(FnCTFSs, param1, 0);
				}
				else
				{
					if(IsClientTooNearObstacle(param1))
					{
						PrintToChat(param1, CHAT_BANNER, "Obstacle");
						DisplayMenu(FnCTFSs, param1, 0);
					}
					else
					{
						TeleportEntity( LR_Player_Prisoner, TFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
						TeleportEntity( LR_Player_Guard, CTFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
						CloseHandle(gH_Timer_RopeBeam);
						gH_Timer_RopeBeam = INVALID_HANDLE;
						if(gH_Timer_CircleBeamCT == INVALID_HANDLE)
							gH_Timer_CircleBeamCT = CreateTimer(0.5, Timer_CircleBeamCT, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

						InitializeLR();
						FruitNinja_AfterMenu(LR_Player_Prisoner, LR_Player_Guard);
					}
				}
			}
			else
			{
				PrintToChat(param1, CHAT_BANNER, "On Ground");
				DisplayMenu(FnCTFSs, param1, 0);
			}
		}
	}
	if (action == MenuAction_Cancel)
	{
		if(gH_FruitNinja != INVALID_HANDLE)
			CloseHandle(gH_FruitNinja);
		if(gH_Timer_RopeBeam != INVALID_HANDLE)
			CloseHandle(gH_Timer_RopeBeam);
		if(gH_Timer_CircleBeamT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamT);
		if(gH_Timer_CircleBeamCT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamCT);
		gH_FruitNinja = INVALID_HANDLE;
		gH_Timer_RopeBeam = INVALID_HANDLE;
		gH_Timer_CircleBeamT = INVALID_HANDLE;
		gH_Timer_CircleBeamCT = INVALID_HANDLE;
	}
}

public OnConfigsExecuted()
{
	static bool:bAddedFruitNinja = false;
	if (!bAddedFruitNinja)
	{
		g_LREntryNum = AddLastRequestToList(FruitNinja_Start, FruitNinja_Stop, "FruitNinja", false);
		bAddedFruitNinja = true;
	}	
}

// The plugin should remove any LRs it loads when it's unloaded
public OnPluginEnd()
{
	RemoveLastRequestFromList(FruitNinja_Start, FruitNinja_Stop, "FruitNinja");
}

public OnMapStart()
{
	// Precache any materials needed
	if(g_Game == 1)
	{
		BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/lgtning.vmt");
		LaserHalo = PrecacheModel("materials/sprites/plasmahalo.vmt");
	}
	else
	{
		BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		LaserHalo = PrecacheModel("materials/sprites/light_glow02.vmt");
	}
	
	if(gH_Timer_RopeBeam != INVALID_HANDLE || gH_Timer_CircleBeamT != INVALID_HANDLE || gH_Timer_CircleBeamCT != INVALID_HANDLE)
	{
		gH_Timer_RopeBeam = INVALID_HANDLE;
		gH_Timer_CircleBeamT = INVALID_HANDLE;
		gH_Timer_CircleBeamCT = INVALID_HANDLE;
	}
	
	for ( new i = 0; i < 4; i++ )
	{
		if ( ! IsModelPrecached( FruitNinjaModels[ i ] ) )
		{
			PrecacheModel( FruitNinjaModels[ i ] );
		}
	}
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public SendPanelToAll( String:name[], String:message[] )
{
	decl String:title[100];
	Format(title, 64, "%s:", name);
	
	ReplaceString(message, 192, "\\n", "\n");
	
	new Handle:mSayPanel = CreatePanel();
	SetPanelTitle(mSayPanel, title);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);
	DrawPanelText(mSayPanel, message);
	DrawPanelItem(mSayPanel, "", ITEMDRAW_SPACER);

	SetPanelCurrentKey(mSayPanel, 20);
	DrawPanelItem(mSayPanel, "Exit", ITEMDRAW_CONTROL);

	for ( new i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ) && !IsFakeClient( i ) )
		{
			SendPanelToClient(mSayPanel, i, Handler_DoNothing, 2);
		}
	}

	CloseHandle( mSayPanel );
}

public Action:Timer_RopeBeam(Handle:timer)
{
	if(IsClientInGame(LR_Player_Prisoner) || IsClientInGame(LR_Player_Guard))
	{
		new clients[2];
		clients[0] = LR_Player_Prisoner;
		clients[1] = LR_Player_Guard;
				
		// setup beam
		decl Float:Prisoner_Pos[3], Float:distance;
		GetClientEyePosition(LR_Player_Prisoner, Prisoner_Pos);
		Prisoner_Pos[2] -= 40.0;
		distance = GetVectorDistance(TFruitSpawnOrigin, Prisoner_Pos);
				
		if (distance <= FruitNinja_MaxDis && distance >= FruitNinja_MinDis)
		{
			TE_SetupBeamPoints(Prisoner_Pos, TFruitSpawnOrigin, LaserSprite, LaserHalo, 1, 1, 0.2, 2.0, 2.0, 0, 10.0, greenColor, 255);			
			TE_SendToAll();
			TE_SetupBeamPoints(TFruitSpawnOrigin, Prisoner_Pos, LaserSprite, LaserHalo, 1, 1, 0.2, 2.0, 2.0, 0, 10.0, greenColor, 255);			
			TE_SendToAll();
		}
		else
		{
			TE_SetupBeamPoints(Prisoner_Pos, TFruitSpawnOrigin, LaserSprite, LaserHalo, 1, 1, 0.2, 2.0, 2.0, 0, 10.0, redColor, 255);			
			TE_SendToAll();
			TE_SetupBeamPoints(TFruitSpawnOrigin, Prisoner_Pos, LaserSprite, LaserHalo, 1, 1, 0.2, 2.0, 2.0, 0, 10.0, redColor, 255);			
			TE_SendToAll();
		}
	}
	return Plugin_Continue;
}

public Action:Timer_CircleBeamT(Handle:timer)
{
	decl Float:f_Origin[3];
	f_Origin[0] = TFruitSpawnOrigin[0];
	f_Origin[1] = TFruitSpawnOrigin[1];
	f_Origin[2] = TFruitSpawnOrigin[2] + 10;
	TE_SetupBeamRingPoint(f_Origin, 10.0, 50.0, BeamSprite, HaloSprite, 0, 15, 0.6, 5.0, 0.0, greyColor, 10, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(f_Origin, 49.9, 50.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, redColor, 10, 0);
	TE_SendToAll();
	return Plugin_Continue;
}

public Action:Timer_CircleBeamCT(Handle:timer)
{
	decl Float:f_Origin[3];
	f_Origin[0] = CTFruitSpawnOrigin[0];
	f_Origin[1] = CTFruitSpawnOrigin[1];
	f_Origin[2] = CTFruitSpawnOrigin[2] + 10;
	TE_SetupBeamRingPoint(f_Origin, 10.0, 50.0, BeamSprite, HaloSprite, 0, 15, 0.6, 5.0, 0.0, greyColor, 10, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(f_Origin, 49.9, 50.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
	TE_SendToAll();
				
	return Plugin_Continue;
}

public FruitNinja_Start(Handle:LR_Array, iIndexInArray)
{
	This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType); // get this lr from selection
	if (This_LR_Type == g_LREntryNum)
	{
		LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner); // get prisoner's id
		LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard); // get guard's id
		
		// check datapack value
		new LR_Pack_Value = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);	
		switch (LR_Pack_Value)
		{
			case -1:
			{
				PrintToServer("no info included");
			}
		}
			
		SetArrayCell(LR_Array, iIndexInArray, 3, _:Block_Global1);
		
		DisplayMenu(FnSs, LR_Player_Prisoner, 0); // send the modes menu to the prisoner
	}
}

public FruitNinja_AfterMenu(Prisoner, Guard)
{
	SetEntityHealth(Prisoner, 100);
	SetEntityHealth(Guard, 100);
	
	StripAllWeapons(Prisoner);
	StripAllWeapons(Guard);
	
	if (gH_Timer_Countdown == INVALID_HANDLE)
		gH_Timer_Countdown = CreateTimer(1.0, Timer_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	PrintToChatAll(CHAT_BANNER, "LR FruitNinja Start", Prisoner, Guard);
}

public Action:Timer_Countdown(Handle:timer)
{
	new numberOfLRsActive = ProcessAllLastRequests(FruitNinja_Countdown, g_LREntryNum);
	if ((numberOfLRsActive <= 0) || bAllCountdownsCompleted)
	{
		gH_Timer_Countdown = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public FruitNinja_Countdown(Handle:LR_Array, iIndexInArray)
{
	LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
	LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
	
	new countdown = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);
	if (countdown > 0)
	{
		bAllCountdownsCompleted = false;
		PrintCenterText(LR_Player_Prisoner, "FruitNinja begins in %i...", countdown);
		PrintCenterText(LR_Player_Guard, "FruitNinja begins in %i...", countdown);
		SetArrayCell(LR_Array, iIndexInArray, --countdown, _:Block_Global1);		
	}
	else if (countdown == 0)
	{
		bAllCountdownsCompleted = true;
		SetArrayCell(LR_Array, iIndexInArray, --countdown, _:Block_Global1);	
		
		new PrisonerGun = GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
		new GuardGun = GivePlayerItem(LR_Player_Guard, "weapon_knife");
		
		FruitNinjaRunning	= 1;
		FruitNinjaStarted	= GetEngineTime();
			
		FruitNinjaCounter[0] = 0;
		FruitNinjaCounter[1] = 0;
		
		if(gH_FruitNinja == INVALID_HANDLE)
			gH_FruitNinja = CreateTimer( 1.0, FruitNinja, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
		SetArrayCell(LR_Array, iIndexInArray, PrisonerGun, _:Block_PrisonerData);
		SetArrayCell(LR_Array, iIndexInArray, GuardGun, _:Block_GuardData);
	}
}

public OnEntityCreated(entity, const String:classname[])
{
	if((This_LR_Type == g_LREntryNum) && FruitNinjaRunning && ( StrEqual( classname, "prop_physics" ) ) )
	{
		SDKHook( entity, SDKHook_OnTakeDamage, OnFruitSliced );
		CreateTimer( 2.0, ExplodeFruit, entity, TIMER_FLAG_NO_MAPCHANGE );
	}
}

public Action:ExplodeFruit( Handle:timer, any:entity )
{
	if ( IsValidEntity( entity ) )
	{
		decl String:strName[50];
		Entity_GetName(entity, strName, sizeof(strName));
		if(strcmp(strName, "Fruit") == 0 || strcmp(strName, "TFruit") == 0 || strcmp(strName, "CTFruit") == 0 || strcmp(strName, "Bomb") == 0)
		{
			AcceptEntityInput( entity, "Kill" );
		}
	}
}

public Action:OnFruitSliced( entity, &attacker, &inflictor, &Float:damage, &damagetype )
{
	if ( attacker > 0 && attacker < MAXPLAYERS )
	{
		if ( attacker == LR_Player_Guard || attacker == LR_Player_Prisoner ) // switched because an error caused when entity destroyed another.
		{
			if ( IsClientInGame( attacker ) )
			{
				decl String:strName[50];
				Entity_GetName(entity, strName, sizeof(strName));
				
				if(FruitNinjaMode == 1)
				{
					if(strcmp(strName, "Fruit") == 0)
					{
						if ( attacker == LR_Player_Guard )
							FruitNinjaCounter[ 0 ]++;
						
						if ( attacker == LR_Player_Prisoner )
							FruitNinjaCounter[ 1 ]++;
					}
				}
				if(FruitNinjaMode == 2)
				{
					if ( IsValidEntity( entity ) )
					{
						if(attacker != 0)
						{
							new team = GetClientTeam(attacker);
							if(strcmp(strName, "TFruit") == 0)
							{
								if ( team == 2 )
								{
									FruitNinjaCounter[ 1 ]++;
								}
								else if ( team == 3 )
								{
									if(FruitNinjaCounter[ 0 ] < 1)
										FruitNinjaCounter[ 0 ] = 0;
									else
										FruitNinjaCounter[ 0 ]--;
								}
							}
							else if(strcmp(strName, "CTFruit") == 0)
							{
								if ( team == 2 )
								{
									if(FruitNinjaCounter[ 1 ] < 1)
										FruitNinjaCounter[ 1 ] = 0;
									else
										FruitNinjaCounter[ 1 ]--;
								}
								else if ( team == 3 )
								{
									FruitNinjaCounter[ 0 ]++;
								}
							}
							else if(strcmp(strName, "Bomb") == 0)
							{
								if ( team == 2 )
								{
									if(FruitNinjaCounter[ 1 ] < 5)
										FruitNinjaCounter[ 1 ] = 0;
									else
										FruitNinjaCounter[ 1 ] -= 5;
								}
								else if ( team == 3 )
								{
									if(FruitNinjaCounter[ 0 ] < 5)
										FruitNinjaCounter[ 0 ] = 0;
									else
										FruitNinjaCounter[ 0 ] -= 5;
								}
							}
						}
					}
				}
				
				//-----------------------------------------
				// Fruit Effects
				//-----------------------------------------
				
				new Float:FruitPosition[3];
				
				if ( IsValidEntity( entity ) )
				{
					GetEntPropVector( entity, Prop_Send, "m_vecOrigin", FruitPosition );
					
					new Float:NewPosition[3];
					NewPosition[0] = 920.0;
					NewPosition[1] = 0.0;
					NewPosition[2] = 0.0;
					
					TE_SetupSparks( FruitPosition, NULL_VECTOR, 20, 10 );
					TE_SendToAll();
					
					TE_SetupArmorRicochet( FruitPosition, NULL_VECTOR );
					TE_SendToAll();
					
					
				}
				
				ClientCommand( attacker, "play buttons/blip2.wav" );
			}
		}
	}
}

public SpawnFruit( any:Client )
{
	if ( IsClientInGame( Client ) )
	{
		if ( IsPlayerAlive( Client ) )
		{
			for ( new i = 0; i < GetRandomInt( 3, 10 ); i++ )
			{
				new Prop = CreateEntityByName( "prop_physics" );
				
				if(FruitNinjaMode == 1)
				{
					new Float:PlayerOrigin[3];
					GetClientAbsOrigin( Client, PlayerOrigin );
					PlayerOrigin[0] += GetRandomInt( -30, 30 );
					PlayerOrigin[1] += GetRandomInt( -30, 30 );
					PlayerOrigin[2] += GetRandomInt( 150, 250 );
					
					SetEntityModel( Prop, FruitNinjaModels[ GetRandomInt( 0, 3 ) ] );
					Entity_SetName(Prop, "Fruit");
					
					DispatchSpawn( Prop );
					TeleportEntity( Prop, PlayerOrigin, NULL_VECTOR, NULL_VECTOR );
				}
				else if(FruitNinjaMode == 2)
				{
					new Random1 = GetRandomInt( -30, 30 );
					new Random2 = GetRandomInt( -30, 30 );
					new Random3 = GetRandomInt( 150, 250 );
					new createbomb = GetRandomInt(0, 15);
					
					new team = GetClientTeam(Client);
					
					if(createbomb != 5)
					{
						SetEntityModel( Prop, FruitNinjaModels[ GetRandomInt( 0, 3 ) ] );
						
						if(Client != 0)
						{
							if(team == 2)
							{
								TFruitSpawnOrigin[0] += Random1;
								TFruitSpawnOrigin[1] += Random2;
								TFruitSpawnOrigin[2] += Random3;
								SetEntityRenderColor(Prop, 255, 0, 0, 255);
								Entity_SetName(Prop, "TFruit");
								
								DispatchSpawn( Prop );
								TeleportEntity( Prop, TFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
								
								TFruitSpawnOrigin[0] -= Random1;
								TFruitSpawnOrigin[1] -= Random2;
								TFruitSpawnOrigin[2] -= Random3;
							}
							else if(team == 3)
							{
								CTFruitSpawnOrigin[0] += Random1;
								CTFruitSpawnOrigin[1] += Random2;
								CTFruitSpawnOrigin[2] += Random3;
								SetEntityRenderColor(Prop, 0, 0, 255, 255);
								Entity_SetName(Prop, "CTFruit");
								
								DispatchSpawn( Prop );
								TeleportEntity( Prop, CTFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
								
								CTFruitSpawnOrigin[0] -= Random1;
								CTFruitSpawnOrigin[1] -= Random2;
								CTFruitSpawnOrigin[2] -= Random3;
							}
						}
					}
					else
					{
						SetEntityModel( Prop, "models/props_junk/watermelon01.mdl" );
						SetEntityRenderColor(Prop, 0, 0, 0, 255);
						Entity_SetName(Prop, "Bomb");
						
						new bombspawn = GetRandomInt(0, 1);
						
						if(bombspawn == 0)
						{
							TFruitSpawnOrigin[0] += Random1;
							TFruitSpawnOrigin[1] += Random2;
							TFruitSpawnOrigin[2] += Random3;
							
							DispatchSpawn( Prop );
							TeleportEntity( Prop, TFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
							
							TFruitSpawnOrigin[0] -= Random1;
							TFruitSpawnOrigin[1] -= Random2;
							TFruitSpawnOrigin[2] -= Random3;
						}
						else if(bombspawn == 0)
						{
							CTFruitSpawnOrigin[0] += Random1;
							CTFruitSpawnOrigin[1] += Random2;
							CTFruitSpawnOrigin[2] += Random3;
							
							DispatchSpawn( Prop );
							TeleportEntity( Prop, CTFruitSpawnOrigin, NULL_VECTOR, NULL_VECTOR );
							
							CTFruitSpawnOrigin[0] -= Random1;
							CTFruitSpawnOrigin[1] -= Random2;
							CTFruitSpawnOrigin[2] -= Random3;
						}
					}
				}
			}
		}
	}
}

public Action:FruitNinja( Handle:timer )
{	
	if ( ! FruitNinjaRunning )
	{
		return Plugin_Stop;
	}
	
	new String:LR_Player_Guard_Name[64];
	new String:LR_Player_Prisoner_Name[64];
	
	GetClientName( LR_Player_Guard, LR_Player_Guard_Name, sizeof( LR_Player_Guard_Name ) );
	GetClientName( LR_Player_Prisoner, LR_Player_Prisoner_Name, sizeof( LR_Player_Prisoner_Name ) );
	
	new TimeRemaining;
	
	if(FruitNinja_ExTimes)
	{
		if(ExtraTimes == 0)
		{
			if(FruitNinjaMode == 1)
				TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M1Time ) - GetEngineTime() );
			else if(FruitNinjaMode == 2)
				TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M2Time ) - GetEngineTime() );
		}
		else
		{
			if(FruitNinjaMode == 1)
				TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M1Time ) - GetEngineTime() + ((FruitNinja_ExTime * ExtraTimes) + 1));
			else if(FruitNinjaMode == 2)
				TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M2Time ) - GetEngineTime() + ((FruitNinja_ExTime * ExtraTimes) + 1));
		}
		
		if(TimeRemaining <= 0 && FruitNinjaCounter[0] == FruitNinjaCounter[1])
		{
			if(ExtraTimes == FruitNinja_ExTimeMax)
			{
				PrintToChatAll(CHAT_BANNER, "Tie and Slay");
				FruitNinjaRunning = 0;
				ForcePlayerSuicide( LR_Player_Guard );
				ForcePlayerSuicide( LR_Player_Prisoner );
				return Plugin_Stop;
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "Tie and Extra", FruitNinja_ExTime);
				ExtraTimes += 1;
				return Plugin_Continue;
			}
		}
		else if ( TimeRemaining >= 0 )
		{
			//-----------------------------------------
			// Toggle god
			//-----------------------------------------	
			
			SetEntProp( LR_Player_Guard, Prop_Data, "m_takedamage", 0, 1 );
			SetEntProp( LR_Player_Prisoner, Prop_Data, "m_takedamage", 0, 1 );
			
			//-----------------------------------------
			// Send menu
			//-----------------------------------------	
			
			new String:message[128];
			
			Format( message, sizeof( message ), "%s: %d\n%s: %d\n \nTime left to slice fruit: %d seconds", LR_Player_Guard_Name, FruitNinjaCounter[0], LR_Player_Prisoner_Name, FruitNinjaCounter[1], TimeRemaining );
			
			SendPanelToAll( "FruitNinja", message );
			
			//-----------------------------------------
			// Spawn random fruit for LR_Player_Guard
			//-----------------------------------------	

			SpawnFruit( LR_Player_Guard );

			//-----------------------------------------
			// Spawn random fruit for LR_Player_Prisoner
			//-----------------------------------------	

			SpawnFruit( LR_Player_Prisoner );
		}
		else if(TimeRemaining <= 0 && FruitNinjaCounter[0] != FruitNinjaCounter[1])
		{
			FruitNinjaRunning = 0;
					
			//-----------------------------------------
			// Remove god
			//-----------------------------------------	
			
			SetEntProp( LR_Player_Guard, Prop_Data, "m_takedamage", 2, 1 );
			SetEntProp( LR_Player_Prisoner, Prop_Data, "m_takedamage", 2, 1 );
			
			if ( IsClientInGame( LR_Player_Guard ) && IsClientInGame( LR_Player_Prisoner ) )
			{
				new WinnerCount;
				new String:WinnerName[64];
				
				if ( FruitNinjaCounter[0] < FruitNinjaCounter[1] )
				{
					WinnerCount = FruitNinjaCounter[1];
					ForcePlayerSuicide( LR_Player_Guard );
					
					GetClientName( LR_Player_Prisoner, WinnerName, sizeof( WinnerName ) );
				}
				else
				{
					WinnerCount = FruitNinjaCounter[0];
					ForcePlayerSuicide( LR_Player_Prisoner );
					
					GetClientName( LR_Player_Guard, WinnerName, sizeof( WinnerName ) );
				}
				
				//-----------------------------------------
				// Send clients sound
				//-----------------------------------------
				
				for ( new Client = 1; Client <= MaxClients; Client++ )
				{
					if ( IsClientInGame( Client ) )
					{
						ClientCommand( Client, "play ui/achievement_earned.wav" );
					}
				}
				
				new String:message[255];
				Format( message, sizeof( message ), "%s: %d\n%s: %d\n \nThe winner of the FruitNinja is %s with %d sliced fruit!", LR_Player_Guard_Name, FruitNinjaCounter[0], LR_Player_Prisoner_Name, FruitNinjaCounter[1], WinnerName, WinnerCount );
				
				PrintToChatAll(CHAT_BANNER, "\x01The winner of the FruitNinja is \x03%s\x01 with \x03%d\x01 sliced fruits!", WinnerName, WinnerCount );
				SendPanelToAll( "FruitNinja", message );
			}
			return Plugin_Stop;
		}
	}
	else
	{
		if(FruitNinjaMode == 1)
			TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M1Time ) - GetEngineTime() );
		else if(FruitNinjaMode == 2)
			TimeRemaining = RoundToZero( ( FruitNinjaStarted + FruitNinja_M2Time ) - GetEngineTime() );
			
		if ( TimeRemaining >= 0 )
		{
			//-----------------------------------------
			// Toggle god
			//-----------------------------------------	
			
			SetEntProp( LR_Player_Guard, Prop_Data, "m_takedamage", 0, 1 );
			SetEntProp( LR_Player_Prisoner, Prop_Data, "m_takedamage", 0, 1 );
			
			//-----------------------------------------
			// Send menu
			//-----------------------------------------	
			
			new String:message[128];
			
			Format( message, sizeof( message ), "%s: %d\n%s: %d\n \nTime left to slice fruit: %d seconds", LR_Player_Guard_Name, FruitNinjaCounter[0], LR_Player_Prisoner_Name, FruitNinjaCounter[1], TimeRemaining );
			
			SendPanelToAll( "FruitNinja", message );
			
			//-----------------------------------------
			// Spawn random fruit for LR_Player_Guard
			//-----------------------------------------	

			SpawnFruit( LR_Player_Guard );

			//-----------------------------------------
			// Spawn random fruit for LR_Player_Prisoner
			//-----------------------------------------	

			SpawnFruit( LR_Player_Prisoner );
		}
		else
		{
			FruitNinjaRunning = 0;
					
			//-----------------------------------------
			// Remove god
			//-----------------------------------------	
			
			SetEntProp( LR_Player_Guard, Prop_Data, "m_takedamage", 2, 1 );
			SetEntProp( LR_Player_Prisoner, Prop_Data, "m_takedamage", 2, 1 );
			
			if ( IsClientInGame( LR_Player_Guard ) && IsClientInGame( LR_Player_Prisoner ) )
			{
				new WinnerCount;
				new String:WinnerName[64];
				
				if ( FruitNinjaCounter[0] < FruitNinjaCounter[1] )
				{
					WinnerCount = FruitNinjaCounter[1];
					ForcePlayerSuicide( LR_Player_Guard );
					
					GetClientName( LR_Player_Prisoner, WinnerName, sizeof( WinnerName ) );
				}
				else
				{
					WinnerCount = FruitNinjaCounter[0];
					ForcePlayerSuicide( LR_Player_Prisoner );
					
					GetClientName( LR_Player_Guard, WinnerName, sizeof( WinnerName ) );
				}
				
				//-----------------------------------------
				// Send clients sound
				//-----------------------------------------
				
				for ( new Client = 1; Client <= MaxClients; Client++ )
				{
					if ( IsClientInGame( Client ) )
					{
						ClientCommand( Client, "play ui/achievement_earned.wav" );
					}
				}
				
				new String:message[255];
				Format( message, sizeof( message ), "%s: %d\n%s: %d\n \nThe winner of the FruitNinja is %s with %d sliced fruit!", LR_Player_Guard_Name, FruitNinjaCounter[0], LR_Player_Prisoner_Name, FruitNinjaCounter[1], WinnerName, WinnerCount );
				
				PrintToChatAll(CHAT_BANNER, "\x01The winner of the FruitNinja is \x03%s\x01 with \x03%d\x01 sliced fruits!", WinnerName, WinnerCount );
				SendPanelToAll( "FruitNinja", message );
			}
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public FruitNinja_Stop(Type, Prisoner, Guard)
{
	if (Type == g_LREntryNum)
	{
		if (IsClientInGame(Prisoner))
		{
			if (IsPlayerAlive(Prisoner))
			{
				SetEntityHealth(Prisoner, 100);
				SetEntProp( Prisoner, Prop_Data, "m_takedamage", 2, 1 );
				StripAllWeapons(Prisoner);
				GivePlayerItem(Prisoner, "weapon_knife");
			}
		}
		if (IsClientInGame(Guard))
		{
			if (IsPlayerAlive(Guard))
			{
				SetEntityHealth(Guard, 100);
				SetEntProp( Guard, Prop_Data, "m_takedamage", 2, 1 );
				StripAllWeapons(Guard);
				GivePlayerItem(Guard, "weapon_knife");
			}
		}
		
		if(FruitNinjaValueChanged)
			UpdateValues();
		
		ExtraTimes = 0;
		FruitNinjaRunning = 0;
		if(gH_FruitNinja != INVALID_HANDLE)
			CloseHandle(gH_FruitNinja);
		if(gH_Timer_RopeBeam != INVALID_HANDLE)
			CloseHandle(gH_Timer_RopeBeam);
		if(gH_Timer_CircleBeamT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamT);
		if(gH_Timer_CircleBeamCT != INVALID_HANDLE)
			CloseHandle(gH_Timer_CircleBeamCT);
		gH_FruitNinja = INVALID_HANDLE;
		gH_Timer_RopeBeam = INVALID_HANDLE;
		gH_Timer_CircleBeamT = INVALID_HANDLE;
		gH_Timer_CircleBeamCT = INVALID_HANDLE;
	}
}
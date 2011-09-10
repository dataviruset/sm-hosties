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

// Include files
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <hosties>
#include <lastrequest>

// Compiler options
#pragma semicolon 1

// Global variables
new bool:g_bIsLRAvailable = false;
new bool:g_bAnnouncedThisRound = false;
new bool:g_bInLastRequest[MAXPLAYERS+1];
new bool:g_bIsARebel[MAXPLAYERS+1];
new Handle:gH_BuildLR[MAXPLAYERS+1];
new LastRequest:g_LRLookup[MAXPLAYERS+1];
new g_LR_PermissionLookup[MAXPLAYERS+1];
new Handle:g_GunTossTimer = INVALID_HANDLE;
new Handle:g_ChickenFightTimer = INVALID_HANDLE;
new Handle:g_DodgeballTimer = INVALID_HANDLE;
new Handle:g_BeaconTimer = INVALID_HANDLE;
new Handle:g_RaceTimer = INVALID_HANDLE;
new Handle:g_DelayLREnableTimer = INVALID_HANDLE;
new Handle:g_BeerGogglesTimer = INVALID_HANDLE;
new Handle:g_CountdownTimer = INVALID_HANDLE;
new Handle:g_FarthestJumpTimer = INVALID_HANDLE;

new Handle:gH_Frwd_LR_CleanUp = INVALID_HANDLE;
new Handle:gH_Frwd_LR_Start = INVALID_HANDLE;
new Handle:gH_Frwd_LR_Process = INVALID_HANDLE;

new BeamSprite = -1;
new HaloSprite = -1;
new LaserSprite = -1;
new LaserHalo = -1;
new greenColor[] = {15, 255, 15, 255};
new redColor[] = {255, 25, 15, 255};
new blueColor[] = {50, 75, 255, 255};
new greyColor[] = {128, 128, 128, 255};
new yellowColor[] = {255, 255, 0, 255};

new g_Offset_Health = -1;
new g_Offset_Armor = -1;
new g_Offset_Clip1 = -1;
new g_Offset_Ammo = -1;
new g_Offset_FOV = -1;
new g_Offset_ActiveWeapon = -1;
new g_Offset_GroundEnt = -1;
new g_Offset_DefFOV = -1;
new g_Offset_PunchAngle = -1; 
new g_Offset_SecAttack = -1;

new Handle:gH_DArray_LastRequests = INVALID_HANDLE;
new Handle:gH_DArray_LR_Partners = INVALID_HANDLE;
new Handle:gH_DArray_Beacons = INVALID_HANDLE;
new Handle:gH_DArray_LR_CustomNames = INVALID_HANDLE;

new Handle:gH_Cvar_LR_KnifeFight_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Shot4Shot_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_GunToss_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Dodgeball_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_NoScope_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_RockPaperScissors_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Rebel_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Mag4Mag_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Race_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_RussianRoulette_On = INVALID_HANDLE;
new Handle:gH_Cvar_LR_JumpContest_On = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_Delay_Enable = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_Mode = INVALID_HANDLE;
new Handle:gH_Cvar_MaxPrisonersToLR = INVALID_HANDLE;
new Handle:gH_Cvar_RebelAction = INVALID_HANDLE;
new Handle:gH_Cvar_RebelHandling = INVALID_HANDLE;
new Handle:gH_Cvar_SendGlobalMsgs = INVALID_HANDLE;
new Handle:gH_Cvar_ColorRebels = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Enable = INVALID_HANDLE;
new Handle:gH_Cvar_ColorRebels_Red = INVALID_HANDLE;
new Handle:gH_Cvar_ColorRebels_Blue = INVALID_HANDLE;
new Handle:gH_Cvar_ColorRebels_Green = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Beacons = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HelpBeams = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Beacon_Interval = INVALID_HANDLE;
new Handle:gH_Cvar_RebelOnImpact = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_Slay = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_C_Blue = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_C_Red = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_C_Green = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Dodgeball_CheatCheck = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Dodgeball_SpawnTime = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Dodgeball_Gravity = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_MaxTime = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_MinTime = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_Speed = INVALID_HANDLE;
new Handle:gH_Cvar_LR_NoScope_Sound = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Sound = INVALID_HANDLE;
new Handle:gH_Cvar_LR_NoScope_Weapon = INVALID_HANDLE;
new Handle:gH_Cvar_LR_S4S_DoubleShot = INVALID_HANDLE;
new Handle:gH_Cvar_LR_GunToss_MarkerMode = INVALID_HANDLE;
new Handle:gH_Cvar_LR_GunToss_StartMode = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Race_AirPoints = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Race_NotifyCTs = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_CT_FreeHit = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_LR = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_Rebel = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_RebelDown = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_Weapon_Attack = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_HotPotato_Eqp = INVALID_HANDLE;
new Handle:gH_Cvar_Announce_Shot4Shot = INVALID_HANDLE;
new Handle:gH_Cvar_LR_NonContKiller_Action = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Delay_Enable_Time = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Damage = INVALID_HANDLE;
new Handle:gH_Cvar_LR_NoScope_Delay = INVALID_HANDLE;
new Handle:gH_Cvar_LR_ChickenFight_Rebel = INVALID_HANDLE;
new Handle:gH_Cvar_LR_HotPotato_Rebel = INVALID_HANDLE;
new Handle:gH_Cvar_LR_KnifeFight_Rebel = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Rebel_MaxTs = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Rebel_MinCTs = INVALID_HANDLE;
new Handle:gH_Cvar_LR_M4M_MagCapacity = INVALID_HANDLE;
new Handle:gH_Cvar_LR_KnifeFight_LowGrav = INVALID_HANDLE;
new Handle:gH_Cvar_LR_KnifeFight_HiSpeed = INVALID_HANDLE;
new Handle:gH_Cvar_LR_KnifeFight_Drunk = INVALID_HANDLE;
new Handle:gH_Cvar_LR_Beacon_Sound = INVALID_HANDLE;

new gShadow_LR_KnifeFight_On = -1;
new gShadow_LR_Shot4Shot_On = -1;
new gShadow_LR_GunToss_On = -1;
new gShadow_LR_ChickenFight_On = -1;
new gShadow_LR_HotPotato_On = -1;
new gShadow_LR_Dodgeball_On = -1;
new gShadow_LR_NoScope_On = -1;
new gShadow_LR_RockPaperScissors_On = -1;
new gShadow_LR_Rebel_On = -1;
new gShadow_LR_Mag4Mag_On = -1;
new gShadow_LR_Race_On = -1;
new gShadow_LR_RussianRoulette_On = -1;
new gShadow_LR_JumpContest_On = -1;
new Float:gShadow_LR_Beacon_Interval = -1.0;
new bool:gShadow_LR_ChickenFight_Slay = false;
new gShadow_LR_ChickenFight_C_Blue = -1;
new gShadow_LR_ChickenFight_C_Red = -1;
new gShadow_LR_ChickenFight_C_Green = -1;
new bool:gShadow_LR_Dodgeball_CheatCheck = false;
new Float:gShadow_LR_Dodgeball_SpawnTime = -1.0;
new Float:gShadow_LR_Dodgeball_Gravity = -1.0;
new gShadow_RebelOnImpact = -1;
new gShadow_ColorRebels_Red = -1;
new gShadow_ColorRebels_Blue = -1;
new gShadow_ColorRebels_Green = -1;
new gShadow_LR_HotPotato_Mode = -1;
new gShadow_MaxPrisonersToLR = -1;
new gShadow_RebelAction = -1;
new gShadow_RebelHandling = -1;
new gShadow_SendGlobalMsgs = -1;
new gShadow_ColorRebels = -1;
new bool:gShadow_LR_Enable = false;
new bool:gShadow_LR_Beacons = false;
new bool:gShadow_LR_HelpBeams = false;
new Float:gShadow_LR_HotPotato_MaxTime = -1.0;
new Float:gShadow_LR_HotPotato_MinTime = -1.0;
new Float:gShadow_LR_HotPotato_Speed = -1.0;
new bool:gShadow_LR_S4S_DoubleShot;
new bool:gShadow_LR_NonContKiller_Action;
new gShadow_LR_GunToss_MarkerMode = -1;
new gShadow_LR_GunToss_StartMode = -1;
new bool:gShadow_LR_Race_AirPoints = false;
new bool:gShadow_LR_Race_NotifyCTs = false;
new bool:gShadow_Announce_CT_FreeHit = false;
new bool:gShadow_Announce_LR = false;
new bool:gShadow_Announce_Rebel = false;
new bool:gShadow_Announce_RebelDown = false;
new bool:gShadow_Announce_HotPotato_Eqp = false;
new bool:gShadow_Announce_Weapon_Attack = false;
new bool:gShadow_Announce_Shot4Shot = false;
new String:gShadow_LR_NoScope_Sound[PLATFORM_MAX_PATH];
new String:gShadow_LR_Sound[PLATFORM_MAX_PATH];
new gShadow_LR_NoScope_Weapon = -1;
new bool:gShadow_Announce_Delay_Enable = false;
new Float:gShadow_LR_Delay_Enable_Time = 0.0;
new bool:g_bPushedToMenu = false;
new bool:gShadow_LR_Damage = false;
new gShadow_LR_NoScope_Delay = -1;
new gShadow_LR_ChickenFight_Rebel = -1;
new gShadow_LR_HotPotato_Rebel = -1;
new gShadow_LR_KnifeFight_Rebel = -1;
new gShadow_LR_Rebel_MaxTs = -1;
new gShadow_LR_Rebel_MinCTs = -1;
new gShadow_LR_M4M_MagCapacity = -1;
new Float:gShadow_LR_KnifeFight_LowGrav = -1.0;
new Float:gShadow_LR_KnifeFight_HiSpeed = -1.0;
new gShadow_LR_KnifeFight_Drunk = -1;
new String:gShadow_LR_Beacon_Sound[PLATFORM_MAX_PATH];

// Custom types local to the plugin
enum NoScopeWeapon
{
	NSW_AWP = 0,
	NSW_Scout,
	NSW_SG550,
	NSW_G3SG1
};

enum PistolWeapon
{
	Pistol_Deagle = 0,
	Pistol_P228,
	Pistol_Glock,
	Pistol_FiveSeven,
	Pistol_Dualies,
	Pistol_USP
};

enum KnifeType
{
	Knife_Vintage = 0,
	Knife_Drunk,
	Knife_LowGrav,
	Knife_HiSpeed,
	Knife_Drugs,
	Knife_ThirdPerson,
	Knife_Throwing,
	Knife_Flying
};

enum JumpContest
{
	Jump_TheMost = 0,
	Jump_Farthest,
	Jump_BrinkOfDeath
};

new String:g_sLastRequestPhrase[LastRequest][MAX_DISPLAYNAME_SIZE];

LastRequest_OnPluginStart()
{
	// Populate translation entries
	Format(g_sLastRequestPhrase[LR_KnifeFight], MAX_DISPLAYNAME_SIZE, "%T", "Knife Fight", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_Shot4Shot], MAX_DISPLAYNAME_SIZE, "%T", "Shot4Shot", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_GunToss], MAX_DISPLAYNAME_SIZE, "%T", "Gun Toss", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_ChickenFight], MAX_DISPLAYNAME_SIZE, "%T", "Chicken Fight", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_HotPotato], MAX_DISPLAYNAME_SIZE, "%T", "Hot Potato", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_Dodgeball], MAX_DISPLAYNAME_SIZE, "%T", "Dodgeball", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_NoScope], MAX_DISPLAYNAME_SIZE, "%T", "No Scope Battle", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_RockPaperScissors], MAX_DISPLAYNAME_SIZE, "%T", "Rock Paper Scissors", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_Rebel], MAX_DISPLAYNAME_SIZE, "%T", "Rebel!", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_Mag4Mag], MAX_DISPLAYNAME_SIZE, "%T", "Mag4Mag", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_Race], MAX_DISPLAYNAME_SIZE, "%T", "Race", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_RussianRoulette], MAX_DISPLAYNAME_SIZE, "%T", "Russian Roulette", LANG_SERVER);
	Format(g_sLastRequestPhrase[LR_JumpContest], MAX_DISPLAYNAME_SIZE, "%T", "Jumping Contest", LANG_SERVER);

	// Gather all offsets
	g_Offset_Health = FindSendPropOffs("CBasePlayer", "m_iHealth");
	if (g_Offset_Health == -1)
	{
		SetFailState("Unable to find offset for health.");
	}
	g_Offset_Armor = FindSendPropOffs("CCSPlayer", "m_ArmorValue");
	if (g_Offset_Armor == -1)
	{
		SetFailState("Unable to find offset for armor.");
	}
	g_Offset_Clip1 = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	if (g_Offset_Clip1 == -1)
	{
		SetFailState("Unable to find offset for clip.");
	}
	g_Offset_Ammo = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	if (g_Offset_Ammo == -1)
	{
		SetFailState("Unable to find offset for ammo.");
	}
	g_Offset_FOV = FindSendPropOffs("CBasePlayer", "m_iFOV");
	if (g_Offset_FOV == -1)
	{
		SetFailState("Unable to find offset for FOV.");
	}
	g_Offset_ActiveWeapon = FindSendPropInfo("CCSPlayer", "m_hActiveWeapon");
	if (g_Offset_ActiveWeapon == -1)
	{
		SetFailState("Unable to find offset for active weapon.");
	}
	g_Offset_GroundEnt = FindSendPropOffs("CBasePlayer", "m_hGroundEntity");
	if (g_Offset_GroundEnt == -1)
	{
		SetFailState("Unable to find offset for ground entity.");
	}
	g_Offset_DefFOV = FindSendPropOffs("CBasePlayer", "m_iDefaultFOV");
	if (g_Offset_DefFOV == -1)
	{
		SetFailState("Unable to find offset for default FOV.");
	}
	g_Offset_PunchAngle = FindSendPropInfo("CBasePlayer", "m_vecPunchAngle");
	if (g_Offset_PunchAngle == -1)
	{
		SetFailState("Unable to find offset for punch angle.");
	}
	g_Offset_SecAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	if (g_Offset_SecAttack == -1)
	{
		SetFailState("Unable to find offset for next secondary attack.");
	}
	
	// Console commands
	RegConsoleCmd("sm_lr", Command_LastRequest);
	RegConsoleCmd("sm_lastrequest", Command_LastRequest);
	
	// Admin commands
	RegAdminCmd("sm_stoplr", Command_CancelLR, ADMFLAG_SLAY);
	RegAdminCmd("sm_cancellr", Command_CancelLR, ADMFLAG_SLAY);
	RegAdminCmd("sm_abortlr", Command_CancelLR, ADMFLAG_SLAY);
	
	// Events hooks
	HookEvent("round_start", LastRequest_RoundStart);
	HookEvent("round_end", LastRequest_RoundEnd);
	HookEvent("player_hurt", LastRequest_PlayerHurt);
	HookEvent("player_death", LastRequest_PlayerDeath);
	HookEvent("bullet_impact", LastRequest_BulletImpact);
	HookEvent("player_disconnect", LastRequest_PlayerDisconnect);
	HookEvent("weapon_zoom", LastRequest_WeaponZoom, EventHookMode_Pre);
	HookEvent("weapon_fire", LastRequest_WeaponFire);
	HookEvent("player_jump", LastRequest_PlayerJump);
	
	// Make global arrays
	gH_DArray_LastRequests = CreateArray();
	gH_DArray_Beacons = CreateArray();
	gH_DArray_LR_CustomNames = CreateArray(MAX_DISPLAYNAME_SIZE);
	gH_DArray_LR_Partners = CreateArray(10);
	// array structure:
	// -- block 0 -> LastRequest type
	// -- block 1 -> Prisoner client index
	// -- block 2 -> Guard client index
	// -- block 3 -> LR Data (Prisoner)
	// -- block 4 -> LR Data (Guard)
	// -- block 5 -> LR Data (Global 1)
	// -- block 6 -> LR Data (Global 2)
	// -- block 7 -> LR Data (Global 3)
	// -- block 8 -> LR Data (Global 4)
	// -- block 9 -> Handle to Additional Data
	
	// Create forwards for custom LR plugins
	gH_Frwd_LR_CleanUp = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	gH_Frwd_LR_Start = CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	gH_Frwd_LR_Process = CreateForward(ET_Event, Param_Cell, Param_Cell);
	
	// Register cvars
	gH_Cvar_LR_Enable = CreateConVar("sm_hosties_lr", "1", "Enable or disable Last Requests (the !lr command): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);	
	gShadow_LR_Enable = true;
	gH_Cvar_LR_KnifeFight_On = CreateConVar("sm_hosties_lr_kf_enable", "1", "Enable LR Knife Fight: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_KnifeFight_On = true;
	gH_Cvar_LR_Shot4Shot_On = CreateConVar("sm_hosties_lr_s4s_enable", "1", "Enable LR Shot4Shot: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Shot4Shot_On = true;
	gH_Cvar_LR_GunToss_On = CreateConVar("sm_hosties_lr_gt_enable", "1", "Enable LR Gun Toss: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_GunToss_On = true;
	gH_Cvar_LR_ChickenFight_On = CreateConVar("sm_hosties_lr_cf_enable", "1", "Enable LR Chicken Fight: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_ChickenFight_On = true;
	gH_Cvar_LR_HotPotato_On = CreateConVar("sm_hosties_lr_hp_enable", "1", "Enable LR Hot Potato: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_HotPotato_On = true;
	gH_Cvar_LR_Dodgeball_On = CreateConVar("sm_hosties_lr_db_enable", "1", "Enable LR Dodgeball: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Dodgeball_On = true;
	gH_Cvar_LR_NoScope_On = CreateConVar("sm_hosties_lr_ns_enable", "1", "Enable LR No Scope Battle: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_NoScope_On = true;
	gH_Cvar_LR_RockPaperScissors_On = CreateConVar("sm_hosties_lr_rps_enable", "1", "Enable LR Rock Paper Scissors: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_RockPaperScissors_On = true;
	gH_Cvar_LR_Rebel_On = CreateConVar("sm_hosties_lr_rebel_on", "1", "Enables the LR Rebel: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Rebel_On = true;
	gH_Cvar_LR_Mag4Mag_On = CreateConVar("sm_hosties_lr_mag4mag_on", "1", "Enables the LR Magazine4Magazine: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Mag4Mag_On = true;
	gH_Cvar_LR_Race_On = CreateConVar("sm_hosties_lr_race_on", "1", "Enables the LR Race: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Race_On = true;
	gH_Cvar_LR_RussianRoulette_On = CreateConVar("sm_hosties_lr_russianroulette_on", "1", "Enables the LR Russian Roulette: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_RussianRoulette_On = true;
	gH_Cvar_LR_JumpContest_On = CreateConVar("sm_hosties_lr_jumpcontest_on", "1", "Enables the LR Jumping Contest: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);	
	gShadow_LR_JumpContest_On = true;

	gH_Cvar_LR_HotPotato_Mode = CreateConVar("sm_hosties_lr_hp_teleport", "2", "Teleport CT to T on hot potato contest start: 0 - disable, 1 - enable, 2 - enable and freeze", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	gShadow_LR_HotPotato_Mode = 2;
	gH_Cvar_SendGlobalMsgs = CreateConVar("sm_hosties_lr_send_global_msgs", "0", "Specifies if non-death related LR messages are sent to everyone or just the active participants in that LR. 0: participants, 1: everyone", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_SendGlobalMsgs = 0;
	gH_Cvar_MaxPrisonersToLR = CreateConVar("sm_hosties_lr_ts_max", "2", "The maximum number of terrorists left to enable LR: 0 - LR is always enabled, >0 - maximum number of Ts", FCVAR_PLUGIN, true, 0.0, true, 63.0);
	gShadow_MaxPrisonersToLR = 1;
	gH_Cvar_RebelAction = CreateConVar("sm_hosties_lr_rebel_action", "2", "Decides what to do with those who rebel/interfere during an LR. 1 - Abort, 2 - Slay.", FCVAR_PLUGIN, true, 1.0, true, 2.0);
	gShadow_RebelAction = 2;
	gH_Cvar_RebelHandling = CreateConVar("sm_hosties_lr_rebel_mode", "1", "LR-mode for rebelling terrorists: 0 - Rebelling Ts can never have a LR, 1 - Rebelling Ts must let the CT decide if a LR is OK, 2 - Rebelling Ts can have a LR just like other Ts", FCVAR_PLUGIN, true, 0.0);
	gShadow_RebelHandling = 1;
	gH_Cvar_RebelOnImpact = CreateConVar("sm_hosties_lr_rebel_impact", "0", "Sets terrorists to rebels for firing a bullet. 0 - Disabled, 1 - Enabled.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_RebelOnImpact = 0;
	gH_Cvar_ColorRebels = CreateConVar("sm_hosties_rebel_color", "0", "Turns on coloring rebels", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_ColorRebels = 0;
	gH_Cvar_ColorRebels_Red = CreateConVar("sm_hosties_rebel_red", "255", "What color to turn a rebel into (set R, G and B values to 255 to disable) (Rgb): x - red value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_ColorRebels_Red = 255;
	gH_Cvar_ColorRebels_Green = CreateConVar("sm_hosties_rebel_green", "0", "What color to turn a rebel into (rGb): x - green value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_ColorRebels_Green = 0;
	gH_Cvar_ColorRebels_Blue = CreateConVar("sm_hosties_rebel_blue", "0", "What color to turn a rebel into (rgB): x - blue value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_ColorRebels_Blue = 0;
	gH_Cvar_LR_Beacons = CreateConVar("sm_hosties_lr_beacon", "1", "Beacon players on LR or not: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Beacons = true;
	gH_Cvar_LR_HelpBeams = CreateConVar("sm_hosties_lr_beams", "1", "Displays connecting beams between LR contestants: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_HelpBeams = true;
	gH_Cvar_LR_Beacon_Interval = CreateConVar("sm_hosties_lr_beacon_interval", "1.0", "The interval in seconds of which the beacon 'beeps' on LR", FCVAR_PLUGIN, true, 0.1);
	gShadow_LR_Beacon_Interval = 1.0;
	gH_Cvar_LR_ChickenFight_Slay = CreateConVar("sm_hosties_lr_cf_slay", "1", "Slay the loser of a Chicken Fight instantly? 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_ChickenFight_Slay = true;
	gH_Cvar_LR_ChickenFight_C_Blue = CreateConVar("sm_hosties_lr_cf_loser_blue", "0", "What color to turn the loser of a chicken fight into (rgB): x - blue value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_LR_ChickenFight_C_Blue = 0;
	gH_Cvar_LR_ChickenFight_C_Green = CreateConVar("sm_hosties_lr_cf_loser_green", "255", "What color to turn the loser of a chicken fight into (rGb): x - green value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_LR_ChickenFight_C_Green = 255;
	gH_Cvar_LR_ChickenFight_C_Red = CreateConVar("sm_hosties_lr_cf_loser_red", "255", "What color to turn the loser of a chicken fight into (only if sm_hosties_lr_cf_slay == 0, set R, G and B values to 255 to disable) (Rgb): x - red value", FCVAR_PLUGIN, true, 0.0, true, 255.0);
	gShadow_LR_ChickenFight_C_Red = 255;
	gH_Cvar_LR_Dodgeball_CheatCheck = CreateConVar("sm_hosties_lr_db_cheatcheck", "1", "Enable health-checker in LR Dodgeball to prevent contestant cheating (healing themselves): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Dodgeball_CheatCheck = true;
	gH_Cvar_LR_Dodgeball_SpawnTime = CreateConVar("sm_hosties_lr_db_flash_duration", "1.4", "The amount of time after a thrown flash before a new flash is given to a contestant: float value - delay in seconds", FCVAR_PLUGIN, true, 0.7, true, 6.0);
	gShadow_LR_Dodgeball_SpawnTime = 1.4;
	gH_Cvar_LR_Dodgeball_Gravity = CreateConVar("sm_hosties_lr_db_gravity", "0.6", "What gravity multiplier the dodgeball contestants will get: <1.0 - less/lower, >1.0 - more/higher", FCVAR_PLUGIN, true, 0.1, true, 2.0);
	gShadow_LR_Dodgeball_Gravity = 0.6;
	gH_Cvar_LR_HotPotato_MaxTime = CreateConVar("sm_hosties_lr_hp_maxtime", "20.0", "Maximum time in seconds the Hot Potato contest will last for (time is randomized): float value - time", FCVAR_PLUGIN, true, 8.0, true, 120.0);
	gShadow_LR_HotPotato_MaxTime = 20.0;
	gH_Cvar_LR_HotPotato_MinTime = CreateConVar("sm_hosties_lr_hp_mintime", "10.0", "Minimum time in seconds the Hot Potato contest will last for (time is randomized): float value - time", FCVAR_PLUGIN, true, 0.0, true, 45.0);
	gShadow_LR_HotPotato_MinTime = 10.0;
	gH_Cvar_LR_HotPotato_Speed = CreateConVar("sm_hosties_lr_hp_speed_multipl", "1.5", "What speed multiplier a hot potato contestant who has the deagle is gonna get: <1.0 - slower, >1.0 - faster", FCVAR_PLUGIN, true, 0.8, true, 3.0);
	gShadow_LR_HotPotato_Speed = 1.5;
	gH_Cvar_LR_S4S_DoubleShot = CreateConVar("sm_hosties_lr_s4s_dblsht_action", "1", "What to do with someone who fires 2 shots in a row in Shot4Shot: 0 - nothing (ignore completely), 1 - Follow rebel punishment cvars", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_S4S_DoubleShot = false;
	gH_Cvar_LR_NoScope_Sound = CreateConVar("sm_hosties_noscope_sound", "sm_hosties/noscopestart1.mp3", "What sound to play when a No Scope Battle starts, relative to the sound-folder: -1 - disable, path - path to sound file", FCVAR_PLUGIN);
	Format(gShadow_LR_NoScope_Sound, sizeof(gShadow_LR_NoScope_Sound ), "sm_hosties/noscopestart1.mp3");
	gH_Cvar_LR_Sound = CreateConVar("sm_hosties_lr_sound", "sm_hosties/lr1.mp3", "What sound to play when LR gets available, relative to the sound-folder (also requires sm_hosties_announce_lr to be 1): -1 - disable, path - path to sound file", FCVAR_PLUGIN);
	Format(gShadow_LR_Sound, sizeof(gShadow_LR_Sound), "sm_hosties/lr1.mp3");
	gH_Cvar_LR_Beacon_Sound = CreateConVar("sm_hosties_beacon_sound", "buttons/blip1.wav", "What sound to play each second a beacon is 'ping'ed.", FCVAR_PLUGIN);
	Format(gShadow_LR_Beacon_Sound, sizeof(gShadow_LR_Beacon_Sound), "buttons/blip1.wav");
	gH_Cvar_LR_NoScope_Weapon = CreateConVar("sm_hosties_lr_ns_weapon", "2", "Weapon to use in a No Scope Battle: 0 - AWP, 1 - scout, 2 - let the terrorist choose, 3 - SG550, 4 - G3SG1", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	gShadow_LR_NoScope_Weapon = 2;
	gH_Cvar_LR_NonContKiller_Action = CreateConVar("sm_hosties_lr_p_killed_action", "1", "What to do when a LR-player gets killed by a player not in LR during LR: 0 - just abort LR, 1 - abort LR and slay the attacker", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_NonContKiller_Action = true;
	gH_Cvar_LR_GunToss_MarkerMode = CreateConVar("sm_hosties_lr_gt_markers", "0", "Deagle marking (requires sm_hosties_lr_gt_mode 1): 0 - markers straight up where the deagles land, 1 - markers starting where the deagle was dropped ending at the deagle landing point", FCVAR_PLUGIN);
	gShadow_LR_GunToss_MarkerMode = 0;
	gH_Cvar_LR_GunToss_StartMode = CreateConVar("sm_hosties_lr_gt_mode", "1", "How Gun Toss will be played: 0 - no double-dropping checking, deagle gets 7 ammo at start, 1 - double dropping check, deagle gets 7 ammo on drop, colouring of deagles, deagle markers", FCVAR_PLUGIN);
	gShadow_LR_GunToss_StartMode = 1;
	gH_Cvar_LR_Delay_Enable_Time = CreateConVar("sm_hosties_lr_enable_delay", "0.0", "Delay in seconds before a last request can be started: 0.0 - instantly, >0.0 - (float value) delay in seconds", FCVAR_PLUGIN, true, 0.0);
	gShadow_LR_Delay_Enable_Time = 0.0;
	gH_Cvar_LR_Damage = CreateConVar("sm_hosties_lr_damage", "0", "Enables that players can not attack players in LR and players in LR can not attack players outside LR: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Damage = false; 	
	gH_Cvar_LR_NoScope_Delay = CreateConVar("sm_hosties_lr_ns_delay", "3", "Delay in seconds before a No Scope Battle begins (to prepare the contestants...)", FCVAR_PLUGIN, true, 0.0);
	gShadow_LR_NoScope_Delay = 3;
	gH_Cvar_LR_ChickenFight_Rebel = CreateConVar("sm_hosties_lr_cf_cheat_action", "1", "What to do with a chicken fighter who attacks the other player with another weapon than knife: 0 - abort LR, 1 - slay player", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_ChickenFight_Rebel = 1;
	gH_Cvar_LR_HotPotato_Rebel = CreateConVar("sm_hosties_lr_hp_cheat_action", "1", "What to do with a hot potato contestant who attacks the other player: 0 - abort LR, 1 - slay player", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_HotPotato_Rebel = 1;
	gH_Cvar_LR_KnifeFight_Rebel = CreateConVar("sm_hosties_lr_kf_cheat_action", "1", "What to do with a knife fighter who attacks the other player with another weapon than knife: 0 - abort LR, 1 - slay player", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_KnifeFight_Rebel = 1;
	gH_Cvar_LR_Race_AirPoints = CreateConVar("sm_hosties_lr_race_airpoints", "0", "Allow prisoners to set race points in the air.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Race_AirPoints = false;
	gH_Cvar_LR_Race_NotifyCTs = CreateConVar("sm_hosties_lr_race_tell_cts", "1", "Tells all CTs when a T has selected the race option from the LR menu", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_Race_NotifyCTs = false;
	gH_Cvar_LR_Rebel_MaxTs = CreateConVar("sm_hosties_lr_rebel_ts", "1", "If the Rebel LR option is enabled, specifies the maximum number of alive terrorists needed for the option to appear in the LR menu.", FCVAR_PLUGIN, true, 1.0);
	gShadow_LR_Rebel_MaxTs = 1;
	gH_Cvar_LR_Rebel_MinCTs = CreateConVar("sm_hosties_lr_rebel_cts", "1", "If the Rebel LR option is enabled, specifies how minimum number of alive counter-terrorists needed for the option to appear in the LR menu.", FCVAR_PLUGIN, true, 1.0);
	gShadow_LR_Rebel_MinCTs = 1;
	gH_Cvar_LR_M4M_MagCapacity = CreateConVar("sm_hosties_lr_m4m_capacity", "7", "The number of bullets in each magazine given to Mag4Mag LR contestants", FCVAR_PLUGIN, true, 2.0);
	gShadow_LR_M4M_MagCapacity = 7;
	gH_Cvar_LR_KnifeFight_LowGrav = CreateConVar("sm_hosties_lr_kf_gravity", "0.6", "The multiplier used for the low-gravity knife fight.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_LR_KnifeFight_LowGrav = 0.6;
	gH_Cvar_LR_KnifeFight_HiSpeed = CreateConVar("sm_hosties_lr_kf_speed", "2.2", "The multiplier used for the high-speed knife fight.", FCVAR_PLUGIN, true, 1.1);
	gShadow_LR_KnifeFight_HiSpeed = 2.2;
	gH_Cvar_LR_KnifeFight_Drunk = CreateConVar("sm_hosties_lr_kf_drunk", "4", "The multiplier used for how drunk the player will be during the drunken boxing knife fight.", FCVAR_PLUGIN, true, 0.0);
	gShadow_LR_KnifeFight_Drunk = 4;
	gH_Cvar_Announce_CT_FreeHit = CreateConVar("sm_hosties_announce_attack", "1", "Enable or disable announcements when a CT attacks a non-rebelling T: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_CT_FreeHit = true;
	gH_Cvar_Announce_LR = CreateConVar("sm_hosties_announce_lr", "1", "Enable or disable chat announcements when Last Requests starts to be available: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_LR = true;
	gH_Cvar_Announce_Rebel = CreateConVar("sm_hosties_announce_rebel", "0", "Enable or disable chat announcements when a terrorist becomes a rebel: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_Rebel = false;
	gH_Cvar_Announce_RebelDown = CreateConVar("sm_hosties_announce_rebel_down", "0", "Enable or disable chat announcements when a rebel is killed: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_RebelDown = false;
	gH_Cvar_Announce_Weapon_Attack = CreateConVar("sm_hosties_announce_wpn_attack", "0", "Enable or disable an announcement telling that a non-rebelling T has a weapon when he gets attacked by a CT (also requires sm_hosties_announce_attack 1): 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_Weapon_Attack = false;
	gH_Cvar_Announce_Shot4Shot = CreateConVar("sm_hosties_lr_s4s_shot_taken", "1", "Enable announcements in Shot4Shot or Mag4Mag when a contestant empties their gun: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_Shot4Shot = false;
	gH_Cvar_Announce_Delay_Enable = CreateConVar("sm_hosties_announce_lr_delay", "1", "Enable or disable chat announcements to tell that last request delaying is activated and how long the delay is: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_Delay_Enable = false;
	gH_Cvar_Announce_HotPotato_Eqp = CreateConVar("sm_hosties_lr_hp_pickupannounce", "0", "Enable announcement when a Hot Potato contestant picks up the hot potato: 0 - disable, 1 - enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_Announce_HotPotato_Eqp = false;
	
	// Listen for changes
	HookConVarChange(gH_Cvar_LR_KnifeFight_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Shot4Shot_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_GunToss_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_ChickenFight_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_HotPotato_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Dodgeball_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_NoScope_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_RockPaperScissors_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Rebel_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Mag4Mag_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Race_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_RussianRoulette_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_JumpContest_On, ConVarChanged_LastRequest);
	
	HookConVarChange(gH_Cvar_LR_Enable, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_HotPotato_Mode, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_SendGlobalMsgs, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_MaxPrisonersToLR, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_RebelAction, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_RebelHandling, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_ColorRebels, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Beacons, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_HelpBeams, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Beacon_Interval, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_RebelOnImpact, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_ColorRebels_Blue, ConVarChanged_Setting);	
	HookConVarChange(gH_Cvar_ColorRebels_Green, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_ColorRebels_Red, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_ChickenFight_C_Blue, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_ChickenFight_C_Green, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_ChickenFight_C_Red, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_ChickenFight_Slay, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Dodgeball_CheatCheck, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Dodgeball_Gravity, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Dodgeball_SpawnTime, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_HotPotato_MaxTime, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_HotPotato_MinTime, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_HotPotato_Speed, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_NoScope_Sound, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Sound, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Beacon_Sound, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_NoScope_Weapon, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_NonContKiller_Action, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_S4S_DoubleShot, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_GunToss_MarkerMode, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_GunToss_StartMode, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Delay_Enable_Time, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Damage, ConVarChanged_Setting); 
	HookConVarChange(gH_Cvar_LR_NoScope_Delay, ConVarChanged_Setting); 
	HookConVarChange(gH_Cvar_LR_KnifeFight_Rebel, ConVarChanged_Setting); 
	HookConVarChange(gH_Cvar_LR_ChickenFight_Rebel, ConVarChanged_Setting); 
	HookConVarChange(gH_Cvar_LR_HotPotato_Rebel, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Race_AirPoints, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Race_NotifyCTs, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Rebel_MinCTs, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_Rebel_MaxTs, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_M4M_MagCapacity, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_KnifeFight_LowGrav, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_KnifeFight_HiSpeed, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_LR_KnifeFight_Drunk, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_CT_FreeHit, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_LR, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_Rebel, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_RebelDown, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_Weapon_Attack, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_Shot4Shot, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_Delay_Enable, ConVarChanged_Setting);
	HookConVarChange(gH_Cvar_Announce_HotPotato_Eqp, ConVarChanged_Setting);
	
	// Account for late loading
	for (new idx = 1; idx <= MaxClients ; idx++)
	{
		if (IsClientInGame(idx))
		{
			SDKHook(idx, SDKHook_WeaponDrop, OnWeaponDrop);
			SDKHook(idx, SDKHook_WeaponEquip, OnWeaponEquip);
			SDKHook(idx, SDKHook_WeaponCanUse, OnWeaponDecideUse);
			SDKHook(idx, SDKHook_OnTakeDamage, OnTakeDamage);
		}
		g_bIsARebel[idx] = false;
		g_bInLastRequest[idx] = false;
		gH_BuildLR[idx] = INVALID_HANDLE;
	}
}

public APLRes:AskPluginLoad2(Handle:h_Myself, bool:bLateLoaded, String:sError[], error_max)
{
	CreateNative("AddLastRequestToList", Native_LR_AddToList);
	CreateNative("RemoveLastRequestFromList", Native_LR_RemoveFromList);
	CreateNative("IsClientRebel", Native_IsClientRebel);
	CreateNative("IsClientInLastRequest", Native_IsClientInLR);
	CreateNative("ProcessAllLastRequests", Native_ProcessLRs);
	RegPluginLibrary("lastrequest");
	return APLRes_Success;
}

public Native_ProcessLRs(Handle:h_Plugin, iNumParameters)
{
	new Function:LoopCallback = GetNativeCell(1);
	AddToForward(gH_Frwd_LR_Process, h_Plugin, LoopCallback);
	new LastRequest:thisType = GetNativeCell(2);
		
	new theLRArraySize = GetArraySize(gH_DArray_LR_Partners);
	for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
		if (type == thisType)
		{
			Call_StartForward(gH_Frwd_LR_Process);
			Call_PushCell(gH_DArray_LR_Partners);
			Call_PushCell(idx);
			Call_Finish();
		}
	}
	
	RemoveFromForward(gH_Frwd_LR_Process, h_Plugin, LoopCallback);
	return theLRArraySize;
}

public Native_LR_AddToList(Handle:h_Plugin, iNumParameters)
{
	new Function:StartCall = GetNativeCell(1);
	new Function:CleanUpCall = GetNativeCell(2);
	AddToForward(gH_Frwd_LR_Start, h_Plugin, StartCall);
	AddToForward(gH_Frwd_LR_CleanUp, h_Plugin, CleanUpCall);
	decl String:sLR_Name[MAX_DISPLAYNAME_SIZE];
	GetNativeString(3, sLR_Name, MAX_DISPLAYNAME_SIZE);
	new iPosition = PushArrayString(gH_DArray_LR_CustomNames, sLR_Name);
	// take the maximum number of LRs + the custom LR index to get new value to push
	iPosition += _:LastRequest;
	PushArrayCell(gH_DArray_LastRequests, iPosition);
	return iPosition;
}

public Native_LR_RemoveFromList(Handle:h_Plugin, iNumParameters)
{
	new Function:StartCall = GetNativeCell(1);
	new Function:CleanUpCall = GetNativeCell(2);
	RemoveFromForward(gH_Frwd_LR_Start, h_Plugin, StartCall);
	RemoveFromForward(gH_Frwd_LR_CleanUp, h_Plugin, CleanUpCall);
	decl String:sLR_Name[MAX_DISPLAYNAME_SIZE];
	GetNativeString(3, sLR_Name, MAX_DISPLAYNAME_SIZE);
	new iPosition = FindStringInArray(gH_DArray_LR_CustomNames, sLR_Name);
	if (iPosition == -1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "LR Name (%s) Not Found", sLR_Name);
	}
	else
	{
		RemoveFromArray(gH_DArray_LR_CustomNames, iPosition);
		iPosition += _:LastRequest;
		RemoveFromArray(gH_DArray_LastRequests, iPosition);
	}
	return 1;
}

public Native_IsClientRebel(Handle:h_Plugin, iNumParameters)
{
	new client = GetNativeCell(1);
	if (client > MaxClients || client < 0)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	return bool:g_bIsARebel[client];
}

public Native_IsClientInLR(Handle:h_Plugin, iNumParameters)
{
	new client = GetNativeCell(1);
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Given client index (%d) not in game", client);
	}
	return Local_IsClientInLR(client);
}

Local_IsClientInLR(client)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	for (new idx = 0; idx < iArraySize; idx++)
	{
		new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
		new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
		if ((LR_Player_Prisoner == client) || (LR_Player_Guard == client))
		{
			// check if a partner exists
			if ((LR_Player_Prisoner == 0) || (LR_Player_Guard == 0))
			{
				return -1;
			}
			else
			{
				return (LR_Player_Prisoner == client ? LR_Player_Guard : LR_Player_Prisoner);
			}
		}
	}
	return 0;
}

public LastRequest_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bAnnouncedThisRound = false;
	
	// roundstart done, enable LR if there should be no LR delay (credits to Caza for this :p)
	if (gShadow_LR_Delay_Enable_Time > 0.0)
	{
		g_bIsLRAvailable = false;		
		g_DelayLREnableTimer = CreateTimer(gShadow_LR_Delay_Enable_Time, Timer_EnableLR, _, TIMER_FLAG_NO_MAPCHANGE);

		if (gShadow_Announce_Delay_Enable)
		{
			PrintToChatAll(CHAT_BANNER, "LR Delay Announcement", RoundToNearest(gShadow_LR_Delay_Enable_Time));
		}
	}
	else
	{
		g_bIsLRAvailable = true;
	}
	
	for (new idx = 1; idx <= MaxClients; idx++)
	{
		g_bIsARebel[idx] = false;
		g_bInLastRequest[idx] = false;
	}
}

public Action:Timer_EnableLR(Handle:timer)
{
	g_bIsLRAvailable = true;
	g_DelayLREnableTimer = INVALID_HANDLE;
	return Plugin_Stop;
}

public Action:Command_CancelLR(client, args)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	while (iArraySize > 0)
	{
		CleanupLastRequest(client, iArraySize-1);
		RemoveFromArray(gH_DArray_LR_Partners, iArraySize-1);
		iArraySize--;
	}
	ShowActivity(client, "%t", "LR Aborted");
	//PrintToChatAll(CHAT_BANNER, "LR Aborted", client);
	return Plugin_Handled;
}

public LastRequest_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Block LRs and reset
	g_bIsLRAvailable = false;
	
	// Remove all the LR data
	ClearArray(gH_DArray_LR_Partners);
	ClearArray(gH_DArray_Beacons);
	
	// Stop timers for short rounds
	if (g_DelayLREnableTimer != INVALID_HANDLE)
	{
		CloseHandle(g_DelayLREnableTimer);
		g_DelayLREnableTimer = INVALID_HANDLE;
	}
	
	// Cancel menus of all alive prisoners	
	ClosePotentialLRMenus();
}

public LastRequest_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
			new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
			
			if (victim == LR_Player_Prisoner || victim == LR_Player_Guard) 
			{					
				if (attacker != LR_Player_Prisoner && attacker != LR_Player_Guard \
					&& attacker && (type != LR_Rebel))
				{
					if (!gShadow_LR_NonContKiller_Action)
					{
						PrintToChatAll(CHAT_BANNER, "Non LR Kill LR Abort", attacker, victim);
					}
					else
					{
						// follow rebel action
						DecideRebelsFate(attacker, idx);
						return;
					}
				}
            
				CleanupLastRequest(victim, idx);            
				RemoveFromArray(gH_DArray_LR_Partners, idx);            
			}
		}
	}

	new Ts, CTs, NumCTsAvailable;
	UpdatePlayerCounts(Ts, CTs, NumCTsAvailable);
	
	if ((Ts > 0) && gShadow_Announce_RebelDown && g_bIsARebel[victim] && attacker && (attacker != victim))
	{
		if (gShadow_SendGlobalMsgs)
		{
			PrintToChatAll(CHAT_BANNER, "Rebel Kill", attacker, victim);
		}
		else
		{
			PrintToChat(attacker, CHAT_BANNER, "Rebel Kill", attacker, victim);
			PrintToChat(victim, CHAT_BANNER, "Rebel Kill", attacker, victim);
		}
	}
	
	if (gShadow_Announce_LR && !g_bAnnouncedThisRound && gShadow_LR_Enable)
	{
		if ((Ts == gShadow_MaxPrisonersToLR) && (NumCTsAvailable > 0) && (Ts > 0))
		{
			g_bAnnouncedThisRound = true;
			PrintToChatAll(CHAT_BANNER, "LR Available");
			
			if ((strlen(gShadow_LR_Sound) > 0) && !StrEqual(gShadow_LR_Sound, "-1"))
			{
				EmitSoundToAll(gShadow_LR_Sound);
			}
		}		
	}
}

public LastRequest_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new target = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (Local_IsClientInLR(attacker) || Local_IsClientInLR(target))	
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);

			if ((type == LR_Rebel) || !attacker || (attacker == target))
			{
				continue;
			}

			new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
			new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
					
			// someone outside the group interfered inside this LR
			if ((target == LR_Player_Prisoner || target == LR_Player_Guard) && \
            attacker != LR_Player_Prisoner && attacker != LR_Player_Guard)
			{
				// take action for rebelers
				if (!g_bIsARebel[attacker] && (GetClientTeam(attacker) == CS_TEAM_T))
				{
					g_bIsARebel[attacker] = true;
					if (gShadow_Announce_Rebel && IsClientInGame(attacker))
					{
						if (gShadow_SendGlobalMsgs)
						{
							PrintToChatAll(CHAT_BANNER, "New Rebel", attacker);
						}
						else
						{
							PrintToChat(attacker, CHAT_BANNER, "New Rebel", attacker);
							PrintToChat(target, CHAT_BANNER, "New Rebel", attacker);
						}
					}
				}
			}
			// someone inside this LR interfered with someone else
			else if (target != LR_Player_Prisoner && target != LR_Player_Guard && \
				(attacker == LR_Player_Prisoner || attacker == LR_Player_Guard))
			{
				DecideRebelsFate(attacker, idx, target);
			}
			
			// if the current LR partner is being attacked
			if ((attacker == LR_Player_Prisoner || attacker == LR_Player_Guard) && \
            (target == LR_Player_Prisoner || target == LR_Player_Guard))
			{
				decl String:weapon[32];
				GetEventString(event, "weapon", weapon, 32);
				new bool:bIsItAKnife = StrEqual(weapon, "knife");
				
				switch (type)
				{
					case LR_KnifeFight, LR_ChickenFight:
					{
						if (!bIsItAKnife)
						{							
							DecideRebelsFate(attacker, idx, target);
						}
					}
					case LR_NoScope:
					{
						if (bIsItAKnife)
						{
							DecideRebelsFate(attacker, idx, target);
						}
					}
					case LR_HotPotato:
					{
						DecideRebelsFate(attacker, idx, target);
					}
				}		
			}
		}
	}
	// if a T attacks a CT and there's no last requests active
	else if (attacker && target && (GetClientTeam(attacker) == CS_TEAM_T) && (GetClientTeam(target) == CS_TEAM_CT) \
		&& !g_bIsARebel[attacker])
	{
		g_bIsARebel[attacker] = true;
		if (IsClientInGame(attacker))
		{
			if (gShadow_Announce_Rebel)
			{
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "New Rebel", attacker);
				}
				else
				{
					PrintToChat(attacker, CHAT_BANNER, "New Rebel", attacker);
					PrintToChat(target, CHAT_BANNER, "New Rebel", attacker);
				}
			}
			if (gShadow_ColorRebels)
			{
				SetEntityRenderColor(attacker, gShadow_ColorRebels_Red, gShadow_ColorRebels_Green, 
               gShadow_ColorRebels_Blue, 255);
			}
		}
	}
	else if (attacker && target && (GetClientTeam(attacker) == CS_TEAM_CT) && (GetClientTeam(target) == CS_TEAM_T) \
		&& !g_bIsARebel[target])
	{
		new bool:bPrisonerHasGun = PlayerHasGun(target);
		
		if (gShadow_Announce_CT_FreeHit)
		{
			
			if (gShadow_Announce_Weapon_Attack && bPrisonerHasGun)
			{
				if (IsClientInGame(target) && IsPlayerAlive(target))
				{
					PrintToChatAll(CHAT_BANNER, "CT Attack T Gun", attacker, target);
				}
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "Freeattack", attacker, target);
			}
		}
		
		// "freeattack" sound
		if ((gShadow_Freekill_Sound_Mode == 0) && (strlen(gShadow_Freekill_Sound) > 0) \
			&& !StrEqual(gShadow_Freekill_Sound, "-1") && (!bPrisonerHasGun))
		{
			EmitSoundToAll(gShadow_Freekill_Sound);
		}
	}
}

public LastRequest_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
			new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
			
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				CleanupLastRequest(client, idx);
				RemoveFromArray(gH_DArray_LR_Partners, idx);
				PrintToChatAll(CHAT_BANNER, "LR Player Disconnect", client);
			}
		}
	}
}

CleanupLastRequest(loser, arrayIndex)
{
	new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_LRType);
	new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_Prisoner);
	new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_Guard);
	
	g_bInLastRequest[LR_Player_Prisoner] = false;
	g_bInLastRequest[LR_Player_Guard] = false;
	
	RemoveBeacon(LR_Player_Prisoner);
	RemoveBeacon(LR_Player_Guard);
	
	new winner = (loser == LR_Player_Prisoner) ? LR_Player_Guard : LR_Player_Prisoner;
	
	switch (type)
	{
		case LR_KnifeFight:
		{
			new KnifeType:KnifeChoice = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_Global1);
			switch (KnifeChoice)
			{
				case Knife_Drunk, Knife_Drugs:
				{
					if (IsClientInGame(LR_Player_Prisoner))
					{
						SetEntData(LR_Player_Prisoner, g_Offset_FOV, NORMAL_VISION, 4, true);
						SetEntData(LR_Player_Prisoner, g_Offset_DefFOV, NORMAL_VISION, 4, true);
						ShowOverlayToClient(LR_Player_Prisoner, "");
					}	
					if (IsClientInGame(LR_Player_Guard))
					{
						SetEntData(LR_Player_Guard, g_Offset_FOV, NORMAL_VISION, 4, true);
						SetEntData(LR_Player_Guard, g_Offset_DefFOV, NORMAL_VISION, 4, true);
						ShowOverlayToClient(LR_Player_Guard, "");
					}	
				}
				case Knife_LowGrav:
				{
					if  (IsClientInGame(LR_Player_Prisoner))
					{
						SetEntityGravity(LR_Player_Prisoner, 1.0);
					}
					if (IsClientInGame(LR_Player_Guard))
					{
						SetEntityGravity(LR_Player_Guard, 1.0);
					}
				}
				case Knife_HiSpeed:
				{
					if (IsClientInGame(winner) && IsPlayerAlive(winner))
					{
						SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
					}
					if (IsClientInGame(loser))
					{
						SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
					}
				}
				case Knife_ThirdPerson:
				{
					if (IsClientInGame(LR_Player_Prisoner))
					{
						SetFirstPerson(LR_Player_Prisoner);
					}
					if (IsClientInGame(LR_Player_Guard))
					{
						SetFirstPerson(LR_Player_Guard);
					}
				}
			}
		}
		case LR_GunToss:
		{
			new GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_PrisonerData));
			new GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_GuardData));
			if (IsValidEntity(GTdeagle1))
			{
				SetEntityRenderColor(GTdeagle1, 255, 255, 255);
				SetEntityRenderMode(GTdeagle1, RENDER_NORMAL);
			}
			if (IsValidEntity(GTdeagle2))
			{
				SetEntityRenderColor(GTdeagle2, 255, 255, 255);
				SetEntityRenderMode(GTdeagle2, RENDER_NORMAL);
			}		
		}
		case LR_ChickenFight:
		{
			if (gShadow_NoBlock)
			{
				if (IsClientInGame(winner) && IsPlayerAlive(winner))
				{
					UnblockEntity(winner, g_Offset_CollisionGroup);
					GivePlayerItem(winner, "weapon_knife");
				}	
			}	
			
		}
		case LR_HotPotato:
		{
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
				SetEntityMoveType(winner, MOVETYPE_WALK);
				GivePlayerItem(winner, "weapon_knife");
			}
			
			new HPdeagle = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_Global4);
			RemoveBeacon(HPdeagle);
			if (IsValidEntity(HPdeagle))
			{
				SetEntityRenderColor(HPdeagle, 255, 255, 255);
				SetEntityRenderMode(HPdeagle, RENDER_NORMAL);
			}
		}
		case LR_RussianRoulette:
		{
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				SetEntityMoveType(winner, MOVETYPE_WALK);
				GivePlayerItem(winner, "weapon_knife");
			}
		}
		case LR_Dodgeball:
		{
			if  (IsClientInGame(LR_Player_Prisoner))
			{
				SetEntityGravity(LR_Player_Prisoner, 1.0);
			}
			if (IsClientInGame(LR_Player_Guard))
			{
				SetEntityGravity(LR_Player_Guard, 1.0);
			}
			
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				StripAllWeapons(winner);
				SetEntData(winner, g_Offset_Ammo + (_:12 * 4), 0, _, true);
				
				SetEntData(winner, g_Offset_Health, 100);
				GivePlayerItem(winner, "weapon_knife");
	
				if (gShadow_NoBlock)
				{
					UnblockEntity(winner, g_Offset_CollisionGroup);
				}
			}
		}
		case LR_Race:
		{
			// free these resources	
			CloseHandle(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, 9));
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				GivePlayerItem(winner, "weapon_knife");
				
				if (!gShadow_NoBlock)
				{				
					BlockEntity(winner, g_Offset_CollisionGroup);
				}			
			}
		}
		case LR_JumpContest:
		{
			new JumpContest:JumpType = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, _:Block_Global2);

			switch (JumpType)
			{
				case Jump_TheMost, Jump_BrinkOfDeath:
				{
					if (IsClientInGame(winner) && IsPlayerAlive(winner))
					{
						if (!gShadow_NoBlock)
						{
							BlockEntity(winner, g_Offset_CollisionGroup);						
						}
					}
				}
				case Jump_Farthest:
				{
					if (IsClientInGame(winner) && IsPlayerAlive(winner))
					{
						SetEntityMoveType(winner, MOVETYPE_WALK);
						GivePlayerItem(winner, "weapon_knife");
					}               
				}
			}
		}
		default:
		{
			Call_StartForward(gH_Frwd_LR_CleanUp);
			Call_PushCell(type);
			Call_PushCell(LR_Player_Prisoner);
			Call_PushCell(LR_Player_Guard);
			new ignore;
			Call_Finish(_:ignore);
		}
	}	
}

public LastRequest_BulletImpact(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (!g_bIsARebel[attacker] && gShadow_RebelOnImpact && (GetClientTeam(attacker) == CS_TEAM_T))
	{
		g_bIsARebel[attacker] = true;
		
		if (gShadow_ColorRebels)
		{
			SetEntityRenderColor(attacker, gShadow_ColorRebels_Red, gShadow_ColorRebels_Green, gShadow_ColorRebels_Blue, 255);
		}
		
		if (gShadow_Announce_Rebel && IsClientInGame(attacker))
		{
			if (gShadow_SendGlobalMsgs)
			{
			  PrintToChatAll(CHAT_BANNER, "New Rebel", attacker);
			}
			else
			{
			  PrintToChat(attacker, CHAT_BANNER, "New Rebel", attacker);
			}
		}
	}
}

public Action:LastRequest_WeaponZoom(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_NoScope)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					SetEntData(client, g_Offset_FOV, 0, 4, true);
					return Plugin_Handled;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public LastRequest_PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_JumpContest)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				new JumpContest:JumpType = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
				
				switch (JumpType)
				{
					case Jump_TheMost:
					{
						new iJumpCount = 0;
						if (client == LR_Player_Prisoner)
						{
							iJumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
							SetArrayCell(gH_DArray_LR_Partners, idx, ++iJumpCount, _:Block_PrisonerData);
						}
						else if (client == LR_Player_Guard)
						{
							iJumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
							SetArrayCell(gH_DArray_LR_Partners, idx, ++iJumpCount, _:Block_GuardData);
						}					
					}
					case Jump_Farthest:
					{
						new bool:Prisoner_Jumped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
						new bool:Guard_Jumped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
						
						if ((client == LR_Player_Prisoner) && !Prisoner_Jumped)
						{
							// record position
							decl Float:Prisoner_Position[3];
							GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
							new Handle:JumpPackPosition = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_DataPackHandle);						
							SetPackPosition(JumpPackPosition, 0);
							WritePackFloat(JumpPackPosition, Prisoner_Position[0]);
							WritePackFloat(JumpPackPosition, Prisoner_Position[1]);
							WritePackFloat(JumpPackPosition, Prisoner_Position[2]);
						}
						else if ((client == LR_Player_Guard) && !Guard_Jumped)
						{
							// record position
							decl Float:Guard_Position[3];
							GetClientAbsOrigin(LR_Player_Guard, Guard_Position);
							new Handle:JumpPackPosition = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_DataPackHandle);							
							SetPackPosition(JumpPackPosition, 24);
							WritePackFloat(JumpPackPosition, Guard_Position[0]);
							WritePackFloat(JumpPackPosition, Guard_Position[1]);
							WritePackFloat(JumpPackPosition, Guard_Position[2]);
						}
					}
				}
			}
		}
	}
}

public LastRequest_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_Mag4Mag)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{
					new M4M_Prisoner_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
					new M4M_Guard_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
					new M4M_RoundsFired = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
					new M4M_Ammo = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global3);
					
					decl String:FiredWeapon[32];
					GetEventString(event, "weapon", FiredWeapon, sizeof(FiredWeapon));
					new iClientWeapon = GetEntDataEnt2(client, g_Offset_ActiveWeapon);	
					
					// set the time to enable burst value to a high value
					SetEntDataFloat(iClientWeapon, g_Offset_SecAttack, 5000.0);
					
					if (iClientWeapon != M4M_Prisoner_Weapon && iClientWeapon != M4M_Guard_Weapon && !StrEqual(FiredWeapon, "knife"))
					{
						DecideRebelsFate(client, idx, -1);
					}
					else if (!StrEqual(FiredWeapon, "knife"))
					{
						new currentAmmo = GetEntData(iClientWeapon, g_Offset_Clip1);
						// check if a shot was actually fired
						if (currentAmmo != M4M_Ammo)
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, currentAmmo, _:Block_Global3);
							SetArrayCell(gH_DArray_LR_Partners, idx, ++M4M_RoundsFired, _:Block_Global2);
							
							if (M4M_RoundsFired >= gShadow_LR_M4M_MagCapacity)
							{
								M4M_RoundsFired = 0;
								SetArrayCell(gH_DArray_LR_Partners, idx, M4M_RoundsFired, _:Block_Global2);
								if (gShadow_Announce_Shot4Shot)
								{
									if (gShadow_SendGlobalMsgs)
									{
										PrintToChatAll(CHAT_BANNER, "M4M Mag Used", client);
									}
									else
									{
										PrintToChat(LR_Player_Guard, CHAT_BANNER, "M4M Mag Used", client);
										PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "M4M Mag Used", client);
									}
								}

								// send it to the next player
								if (LR_Player_Prisoner == client)
								{
									SetEntData(M4M_Guard_Weapon, g_Offset_Clip1, gShadow_LR_M4M_MagCapacity);
									SetArrayCell(gH_DArray_LR_Partners, idx, LR_Player_Guard, _:Block_Global1);
								}
								else if (LR_Player_Guard == client)
								{
									SetEntData(M4M_Prisoner_Weapon, g_Offset_Clip1, gShadow_LR_M4M_MagCapacity);
									SetArrayCell(gH_DArray_LR_Partners, idx, LR_Player_Prisoner, _:Block_Global1);
								}
							}
						}
					}			
				}			
			}
			else if (type == LR_RussianRoulette)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{							
					new Prisoner_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
					new Guard_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);

					if (gShadow_Announce_Shot4Shot)
					{
						if (gShadow_SendGlobalMsgs)
						{
							PrintToChatAll(CHAT_BANNER, "S4S Shot Taken", client);
						}
						else
						{
							PrintToChat(LR_Player_Guard, CHAT_BANNER, "S4S Shot Taken", client);
							PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "S4S Shot Taken", client);
						}
					}
					
					// give the opposite LR player 1 bullet in their deagle
					if (client == LR_Player_Prisoner)
					{
						// modify deagle 2s ammo
						SetEntData(Guard_Weapon, g_Offset_Clip1, 1);
					}
					else if (client == LR_Player_Guard)
					{
						// modify deagle 1s ammo
						SetEntData(Prisoner_Weapon, g_Offset_Clip1, 1);
					}
					
					ChangeEdictState(Prisoner_Weapon, g_Offset_Clip1);
					ChangeEdictState(Guard_Weapon, g_Offset_Clip1);					
				}
			}
			else if (type == LR_Shot4Shot)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{
					new Prisoner_S4S_Pistol = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
					new Guard_S4S_Pistol = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
					new S4Slastshot = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
					
					decl String:FiredWeapon[32];
					GetEventString(event, "weapon", FiredWeapon, sizeof(FiredWeapon));
					
					// get the entity index of the pistol
					new iClientWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					
					// check if we have the same weapon
					new String:LR_WeaponName[32];
					if (iClientWeapon != -1)
					{
						GetEdictClassname(iClientWeapon, LR_WeaponName, sizeof(LR_WeaponName));
						ReplaceString(LR_WeaponName, sizeof(LR_WeaponName), "weapon_", "");
					}
					
					if (StrEqual(LR_WeaponName, FiredWeapon))
					{
						// update who took the last shot
						SetArrayCell(gH_DArray_LR_Partners, idx, client, _:Block_Global1);
						
						// they picked up an identical gun and are using it instead
						if (iClientWeapon != Prisoner_S4S_Pistol && iClientWeapon != Guard_S4S_Pistol)		    	
						{
							DecideRebelsFate(client, idx, -1);
						}
						// firing weapon IS correct
						else
						{		    	
							// check for double shot situation (if they picked up another deagle with more ammo between shots)
							if (gShadow_LR_S4S_DoubleShot && (S4Slastshot == client))
							{
								// this should no longer be possible to do without extra manipulation								
								DecideRebelsFate(client, idx, -1);								
							}
							else // if we didn't repeat
							{		
								if (gShadow_Announce_Shot4Shot)
								{
									if (gShadow_SendGlobalMsgs)
									{
										PrintToChatAll(CHAT_BANNER, "S4S Shot Taken", client);
									}
									else
									{
										PrintToChat(LR_Player_Guard, CHAT_BANNER, "S4S Shot Taken", client);
										PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "S4S Shot Taken", client);
									}
								}
								
								// give the opposite LR player 1 bullet in their deagle
								if (client == LR_Player_Prisoner)
								{
									// modify deagle 2s ammo
									SetEntData(Guard_S4S_Pistol, g_Offset_Clip1, 1);
								}
								else if (client == LR_Player_Guard)
								{
									// modify deagle 1s ammo
									SetEntData(Prisoner_S4S_Pistol, g_Offset_Clip1, 1);
								}		    	

								// propogate the ammo immediately! (thanks psychonic)
								ChangeEdictState(Prisoner_S4S_Pistol, g_Offset_Clip1);
								ChangeEdictState(Guard_S4S_Pistol, g_Offset_Clip1);
							}
						}		    							
					}
					else if (!StrEqual(FiredWeapon, "knife"))
					{
						DecideRebelsFate(client, idx, -1);
					}
				}	
			}
		}
	}
} // end LastRequest_WeaponFire

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if ((victim != attacker) && (victim > 0) && (victim <= MaxClients) && (attacker > 0) && (attacker <= MaxClients))
	{
		new iArraySize = GetArraySize(gH_DArray_LR_Partners);
		if (iArraySize > 0)
		{
			for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				new LastRequest:Type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
				
				// if a roulette player is hurting the other contestant
				if ((Type == LR_RussianRoulette) && (attacker == LR_Player_Guard || attacker == LR_Player_Prisoner) && \
					(victim == LR_Player_Guard || victim == LR_Player_Prisoner))
				{
					// null any damage
					damage = 0.0;
					
					// decide if there's a winner
					new bullet = GetRandomInt(1,6);
					switch (bullet)
					{
						case 1:
						{
							ForcePlayerSuicide(victim);
							PrintToChatAll(CHAT_BANNER, "Russian Roulette - Hit", victim);
							
						}
						default:
						{
							if (gShadow_SendGlobalMsgs)
							{						
								PrintToChatAll(CHAT_BANNER, "Russian Roulette - Miss");
							}
							else
							{
								PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Russian Roulette - Miss");
								PrintToChat(LR_Player_Guard, CHAT_BANNER, "Russian Roulette - Miss");
							}
						}
					}

					return Plugin_Handled;
				}
				else if (!gShadow_LR_Damage)
				{
					return Plugin_Continue;
				}
				else if (Type == LR_Rebel)
				{
					return Plugin_Continue;
				}				
				// Allow LR contestants to attack each other
				else if ((victim == LR_Player_Prisoner && attacker == LR_Player_Guard) || (victim == LR_Player_Guard && attacker == LR_Player_Prisoner))
				{
					return Plugin_Continue;
				}
				// Don't allow attacks outside or inside the Last Request
				else if (victim == LR_Player_Prisoner || victim == LR_Player_Guard || attacker == LR_Player_Prisoner || attacker == LR_Player_Guard)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}  

public Action:OnWeaponDecideUse(client, weapon)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);

			if (type == LR_HotPotato)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				new HPdeagle = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global4);
				
				// check if someone else picked up the hot potato
				if (client != LR_Player_Guard && client != LR_Player_Prisoner && weapon == HPdeagle)
				{
					return Plugin_Handled;
				}				
			}
		}
	}
	return Plugin_Continue;
}

public Action:OnWeaponEquip(client, weapon)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
			new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
			
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				if (type == LR_GunToss)
				{
					new GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
					new GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
					new GTp1done = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global3);
					new GTp2done = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global4);
					
					if (client == LR_Player_Prisoner && GTp1dropped && !GTp1done)
					{
						decl String:weapon_name[32];
						GetEdictClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_deagle"))
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, true, _:Block_Global3);
						}			
					}
					else if (client == LR_Player_Guard && GTp2dropped && !GTp2done)
					{
						decl String:weapon_name[32];
						GetEdictClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_deagle"))
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, true, _:Block_Global4);
						}						
					}	
				}
				else if (type == LR_HotPotato)
				{
					new HPdeagle = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global4);
					if (weapon == HPdeagle)
					{
						SetArrayCell(gH_DArray_LR_Partners, idx, client, _:Block_Global1); // HPloser
						if (gShadow_LR_HotPotato_Mode != 2)
						{
							SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gShadow_LR_HotPotato_Speed);
							// reset other player's speed
							SetEntPropFloat((client == LR_Player_Prisoner ? LR_Player_Guard : LR_Player_Prisoner), 
								Prop_Data, "m_flLaggedMovementValue", 1.0);
						}
						
						if (gShadow_Announce_HotPotato_Eqp)
						{
							if (gShadow_SendGlobalMsgs)
							{
								PrintToChatAll(CHAT_BANNER, "Hot Potato PickUp", client);
							}
							else
							{
								PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Hot Potato Pickup", client);
								PrintToChat(LR_Player_Guard, CHAT_BANNER, "Hot Potato Pickup", client);
							}
						}
					}
					else
					{
						// prevent them from picking up any other pistol
						decl String:weapon_name[32];
						GetEdictClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_p228") || 
							StrEqual(weapon_name, "weapon_deagle") ||
							StrEqual(weapon_name, "weapon_elite") ||
							StrEqual(weapon_name, "weapon_fiveseven") ||
							StrEqual(weapon_name, "weapon_glock") ||
							StrEqual(weapon_name, "weapon_usp"))
						{
							return Plugin_Handled;
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:OnWeaponDrop(client, weapon)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_GunToss)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					new GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData));
					new GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData));
					new GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
					new GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
					
					if (((client == LR_Player_Prisoner && GTp1dropped) || 
						(client == LR_Player_Guard && GTp2dropped)) && (gShadow_LR_GunToss_StartMode == 1))
					{
						decl String:weapon_name[32];
						GetEdictClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_deagle"))
						{
							PrintToChat(client, CHAT_BANNER, "Already Dropped Deagle");
							return Plugin_Handled;
						}
					}
					else
					{
						new Handle:PositionDataPack = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_DataPackHandle);
						if (client == LR_Player_Prisoner)
						{
							if (IsValidEntity(GTdeagle1))
							{
								SetEntData(GTdeagle1, g_Offset_Clip1, 7);
							}
							
							decl Float:GTp1droppos[3];
							GetClientAbsOrigin(LR_Player_Prisoner, GTp1droppos);
							SetPackPosition(PositionDataPack, 48);
							WritePackFloat(PositionDataPack, GTp1droppos[0]);
							WritePackFloat(PositionDataPack, GTp1droppos[1]);
							WritePackFloat(PositionDataPack, GTp1droppos[2]);
							
							if (weapon == GTdeagle1)
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, true, _:Block_Global1);
							}
						}
						else if (client == LR_Player_Guard)
						{
							if (IsValidEntity(GTdeagle2))
							{
								SetEntData(GTdeagle2, g_Offset_Clip1, 7);
							}
							decl Float:GTp2droppos[3];
							GetClientAbsOrigin(LR_Player_Guard, GTp2droppos);
							SetPackPosition(PositionDataPack, 72);
							WritePackFloat(PositionDataPack, GTp2droppos[0]);
							WritePackFloat(PositionDataPack, GTp2droppos[1]);
							WritePackFloat(PositionDataPack, GTp2droppos[2]);
							
							if (weapon == GTdeagle2)
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, true, _:Block_Global2);
							}
						}	
						
						if (g_GunTossTimer == INVALID_HANDLE)
						{
							g_GunTossTimer = CreateTimer(0.1, Timer_GunToss, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						}			
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

LastRequest_OnMapStart()
{
	// Precache any materials needed
	BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	LaserSprite = PrecacheModel("materials/sprites/lgtning.vmt");
	LaserHalo = PrecacheModel("materials/sprites/plasmahalo.vmt");
	HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	
	// Potential fix for problems with g_BeaconTimer not being set to INVALID_HANDLE on timer terminating (TIMER_FLAG_NO_MAPCHANGE)
	if (g_BeaconTimer != INVALID_HANDLE)
	{
		g_BeaconTimer = INVALID_HANDLE;
	}
}

LastRequest_OnConfigsExecuted()
{
	if (!g_bPushedToMenu)
	{
		// Check LRs
		gShadow_LR_KnifeFight_On = GetConVarBool(gH_Cvar_LR_KnifeFight_On);
		if (gShadow_LR_KnifeFight_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_KnifeFight);
		}
		gShadow_LR_Shot4Shot_On = GetConVarBool(gH_Cvar_LR_Shot4Shot_On);
		if (gShadow_LR_Shot4Shot_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_Shot4Shot);
		}
		gShadow_LR_GunToss_On = GetConVarBool(gH_Cvar_LR_GunToss_On);
		if (gShadow_LR_GunToss_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_GunToss);
		}
		gShadow_LR_ChickenFight_On = GetConVarBool(gH_Cvar_LR_ChickenFight_On);
		if (gShadow_LR_ChickenFight_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_ChickenFight);
		}
		gShadow_LR_HotPotato_On = GetConVarBool(gH_Cvar_LR_HotPotato_On);
		if (gShadow_LR_HotPotato_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_HotPotato);
		}
		gShadow_LR_Dodgeball_On = GetConVarBool(gH_Cvar_LR_Dodgeball_On);
		if (gShadow_LR_Dodgeball_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_Dodgeball);
		}
		gShadow_LR_NoScope_On = GetConVarBool(gH_Cvar_LR_NoScope_On);
		if (gShadow_LR_NoScope_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_NoScope);
		}
		gShadow_LR_RockPaperScissors_On = GetConVarBool(gH_Cvar_LR_RockPaperScissors_On);
		if (gShadow_LR_RockPaperScissors_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_RockPaperScissors);
		}
		gShadow_LR_Rebel_On = GetConVarBool(gH_Cvar_LR_Rebel_On);
		if (gShadow_LR_Rebel_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_Rebel);
		}
		gShadow_LR_Mag4Mag_On = GetConVarBool(gH_Cvar_LR_Mag4Mag_On);
		if (gShadow_LR_Mag4Mag_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_Mag4Mag);
		}
		gShadow_LR_Race_On = GetConVarBool(gH_Cvar_LR_Race_On);
		if (gShadow_LR_Race_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_Race);
		}
		gShadow_LR_RussianRoulette_On = GetConVarBool(gH_Cvar_LR_RussianRoulette_On);
		if (gShadow_LR_RussianRoulette_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_RussianRoulette);
		}
		gShadow_LR_JumpContest_On = GetConVarBool(gH_Cvar_LR_JumpContest_On);
		if (gShadow_LR_JumpContest_On)
		{
			PushArrayCell(gH_DArray_LastRequests, LR_JumpContest);
		}
	}
	g_bPushedToMenu = true;
	
	// check for -1 for backward compatibility
	new MediaType:soundfile = type_Sound;
	GetConVarString(gH_Cvar_LR_NoScope_Sound, gShadow_LR_NoScope_Sound, sizeof(gShadow_LR_NoScope_Sound));
	if ((strlen(gShadow_LR_NoScope_Sound) > 0) && !StrEqual(gShadow_LR_NoScope_Sound, "-1"))
	{		
		CacheTheFile(gShadow_LR_NoScope_Sound, soundfile);
	}
	GetConVarString(gH_Cvar_LR_Sound, gShadow_LR_Sound, sizeof(gShadow_LR_Sound));
	if ((strlen(gShadow_LR_Sound) > 0) && !StrEqual(gShadow_LR_Sound, "-1"))
	{
		CacheTheFile(gShadow_LR_Sound, soundfile);
	}
	GetConVarString(gH_Cvar_LR_Beacon_Sound, gShadow_LR_Beacon_Sound, sizeof(gShadow_LR_Beacon_Sound));
	if ((strlen(gShadow_LR_Beacon_Sound) > 0) && !StrEqual(gShadow_LR_Beacon_Sound, "-1"))
	{
		CacheTheFile(gShadow_LR_Beacon_Sound, soundfile);
	}
	
	// update settings from configs
	gShadow_LR_Enable = bool:GetConVarInt(gH_Cvar_LR_Enable);
	gShadow_LR_HotPotato_Mode = GetConVarInt(gH_Cvar_LR_HotPotato_Mode);
	gShadow_SendGlobalMsgs = GetConVarInt(gH_Cvar_SendGlobalMsgs);
	gShadow_MaxPrisonersToLR = GetConVarInt(gH_Cvar_MaxPrisonersToLR);
	gShadow_RebelAction = GetConVarInt(gH_Cvar_RebelAction);
	gShadow_RebelHandling = GetConVarInt(gH_Cvar_RebelHandling);
	gShadow_ColorRebels = GetConVarInt(gH_Cvar_ColorRebels);
	gShadow_Announce_CT_FreeHit = bool:GetConVarInt(gH_Cvar_Announce_CT_FreeHit);
	gShadow_Announce_LR = bool:GetConVarInt(gH_Cvar_Announce_LR);
	gShadow_Announce_Rebel = bool:GetConVarInt(gH_Cvar_Announce_Rebel);
	gShadow_Announce_RebelDown = bool:GetConVarInt(gH_Cvar_Announce_RebelDown);		
	gShadow_Announce_Weapon_Attack = bool:GetConVarInt(gH_Cvar_Announce_Weapon_Attack);
	gShadow_Announce_HotPotato_Eqp = bool:GetConVarInt(gH_Cvar_Announce_HotPotato_Eqp);
	gShadow_LR_Race_AirPoints = bool:GetConVarInt(gH_Cvar_LR_Race_AirPoints);
	gShadow_LR_Race_NotifyCTs = bool:GetConVarInt(gH_Cvar_LR_Race_NotifyCTs);
	gShadow_LR_Beacons = bool:GetConVarInt(gH_Cvar_LR_Beacons);
	gShadow_LR_HelpBeams = bool:GetConVarInt(gH_Cvar_LR_HelpBeams);
	gShadow_LR_Beacon_Interval = GetConVarFloat(gH_Cvar_LR_Beacon_Interval);
	gShadow_RebelOnImpact = bool:GetConVarInt(gH_Cvar_RebelOnImpact);
	gShadow_ColorRebels_Blue = GetConVarInt(gH_Cvar_ColorRebels_Blue);
	gShadow_ColorRebels_Green = GetConVarInt(gH_Cvar_ColorRebels_Green);
	gShadow_ColorRebels_Red = GetConVarInt(gH_Cvar_ColorRebels_Red);
	gShadow_LR_ChickenFight_C_Blue = GetConVarInt(gH_Cvar_LR_ChickenFight_C_Blue);
	gShadow_LR_ChickenFight_C_Green = GetConVarInt(gH_Cvar_LR_ChickenFight_C_Green);
	gShadow_LR_ChickenFight_C_Red = GetConVarInt(gH_Cvar_LR_ChickenFight_C_Red);
	gShadow_LR_ChickenFight_Slay = bool:GetConVarInt(gH_Cvar_LR_ChickenFight_Slay);
	gShadow_LR_Dodgeball_CheatCheck = bool:GetConVarInt(gH_Cvar_LR_Dodgeball_CheatCheck);
	gShadow_LR_Dodgeball_Gravity = GetConVarFloat(gH_Cvar_LR_Dodgeball_Gravity);
	gShadow_LR_Dodgeball_SpawnTime = GetConVarFloat(gH_Cvar_LR_Dodgeball_SpawnTime);
	gShadow_LR_HotPotato_MaxTime = GetConVarFloat(gH_Cvar_LR_HotPotato_MaxTime);
	gShadow_LR_HotPotato_MinTime = GetConVarFloat(gH_Cvar_LR_HotPotato_MinTime);
	gShadow_LR_HotPotato_Speed = GetConVarFloat(gH_Cvar_LR_HotPotato_Speed);
	GetConVarString(gH_Cvar_LR_NoScope_Sound, gShadow_LR_NoScope_Sound, sizeof(gShadow_LR_NoScope_Sound));
	GetConVarString(gH_Cvar_LR_Sound, gShadow_LR_Sound, sizeof(gShadow_LR_Sound));
	GetConVarString(gH_Cvar_LR_Beacon_Sound, gShadow_LR_Beacon_Sound, sizeof(gShadow_LR_Beacon_Sound));	
	gShadow_LR_NoScope_Weapon = GetConVarInt(gH_Cvar_LR_NoScope_Weapon);
	gShadow_Announce_Shot4Shot = bool:GetConVarInt(gH_Cvar_Announce_Shot4Shot);
	gShadow_LR_NonContKiller_Action = bool:GetConVarInt(gH_Cvar_LR_NonContKiller_Action);
	gShadow_LR_S4S_DoubleShot = bool:GetConVarInt(gH_Cvar_LR_S4S_DoubleShot);
	gShadow_LR_GunToss_MarkerMode = GetConVarInt(gH_Cvar_LR_GunToss_MarkerMode);
	gShadow_LR_GunToss_StartMode = GetConVarInt(gH_Cvar_LR_GunToss_StartMode);
	gShadow_LR_Delay_Enable_Time = GetConVarFloat(gH_Cvar_LR_Delay_Enable_Time);
	gShadow_Announce_Delay_Enable = bool:GetConVarInt(gH_Cvar_Announce_Delay_Enable);
	gShadow_LR_Damage = bool:GetConVarInt(gH_Cvar_LR_Damage); 	
	gShadow_LR_NoScope_Delay = GetConVarInt(gH_Cvar_LR_NoScope_Delay);
	gShadow_LR_KnifeFight_Rebel = GetConVarInt(gH_Cvar_LR_KnifeFight_Rebel);
	gShadow_LR_ChickenFight_Rebel = GetConVarInt(gH_Cvar_LR_ChickenFight_Rebel);
	gShadow_LR_HotPotato_Rebel = GetConVarInt(gH_Cvar_LR_HotPotato_Rebel);	
	gShadow_LR_Rebel_MaxTs = GetConVarInt(gH_Cvar_LR_Rebel_MaxTs);
	gShadow_LR_Rebel_MinCTs = GetConVarInt(gH_Cvar_LR_Rebel_MinCTs);
	gShadow_LR_M4M_MagCapacity = GetConVarInt(gH_Cvar_LR_M4M_MagCapacity);
	gShadow_LR_KnifeFight_LowGrav = GetConVarFloat(gH_Cvar_LR_KnifeFight_LowGrav);
	gShadow_LR_KnifeFight_HiSpeed = GetConVarFloat(gH_Cvar_LR_KnifeFight_HiSpeed);
	gShadow_LR_KnifeFight_Drunk = GetConVarInt(gH_Cvar_LR_KnifeFight_Drunk);
}

public ConVarChanged_Setting(Handle:cvar, const String:oldValue[], const String:newValue[])
{	
	if (cvar == gH_Cvar_LR_Enable)
	{
		gShadow_LR_Enable = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_Mode)
	{
		gShadow_LR_HotPotato_Mode = StringToInt(newValue);
	}	
	else if (cvar == gH_Cvar_SendGlobalMsgs)
	{
		gShadow_SendGlobalMsgs = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_MaxPrisonersToLR)
	{
		gShadow_MaxPrisonersToLR = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_RebelAction)
	{
		gShadow_RebelAction = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_RebelHandling)
	{
		gShadow_RebelHandling = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_ColorRebels)
	{
		gShadow_ColorRebels = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_CT_FreeHit)
	{
		gShadow_Announce_CT_FreeHit = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_LR)
	{
		gShadow_Announce_LR = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_Rebel)
	{
		gShadow_Announce_Rebel = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_RebelDown)
	{
		gShadow_Announce_RebelDown = bool:StringToInt(newValue);		
	}
	else if (cvar == gH_Cvar_Announce_Weapon_Attack)
	{
		gShadow_Announce_Weapon_Attack = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Race_AirPoints)
	{
		gShadow_LR_Race_AirPoints = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Race_NotifyCTs)
	{
		gShadow_LR_Race_NotifyCTs = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Beacons)
	{
		gShadow_LR_Beacons = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_HelpBeams)
	{
		gShadow_LR_HelpBeams = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Beacon_Interval)
	{
		gShadow_LR_Beacon_Interval = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_RebelOnImpact)
	{
		gShadow_RebelOnImpact = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_ColorRebels_Blue)
	{
		gShadow_ColorRebels_Blue = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_ColorRebels_Green)
	{
		gShadow_ColorRebels_Green = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_ColorRebels_Red)
	{
		gShadow_ColorRebels_Red = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_C_Blue)
	{
		gShadow_LR_ChickenFight_C_Blue = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_C_Green)
	{
		gShadow_LR_ChickenFight_C_Green = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_C_Red)
	{
		gShadow_LR_ChickenFight_C_Red = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_Slay)
	{
		gShadow_LR_ChickenFight_Slay = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Dodgeball_CheatCheck)
	{
		gShadow_LR_Dodgeball_CheatCheck = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Dodgeball_Gravity)
	{
		gShadow_LR_Dodgeball_Gravity = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_Dodgeball_SpawnTime)
	{
		gShadow_LR_Dodgeball_SpawnTime = StringToFloat(newValue);
	}	
	else if (cvar == gH_Cvar_LR_HotPotato_MaxTime)
	{
		gShadow_LR_HotPotato_MaxTime = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_MinTime)
	{
		gShadow_LR_HotPotato_MinTime = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_Speed)
	{
		gShadow_LR_HotPotato_Speed = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_NoScope_Sound)
	{
		Format(gShadow_LR_NoScope_Sound, sizeof(gShadow_LR_NoScope_Sound), newValue);
	}
	else if (cvar == gH_Cvar_LR_Sound)
	{
		Format(gShadow_LR_Sound, sizeof(gShadow_LR_Sound), newValue);
	}
	else if (cvar == gH_Cvar_LR_Beacon_Sound)
	{
		Format(gShadow_LR_Beacon_Sound, sizeof(gShadow_LR_Beacon_Sound), newValue);
	}
	else if (cvar == gH_Cvar_LR_NoScope_Weapon)
	{
		gShadow_LR_NoScope_Weapon = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_Shot4Shot)
	{
		gShadow_Announce_Shot4Shot = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_NonContKiller_Action)
	{
		gShadow_LR_NonContKiller_Action = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_S4S_DoubleShot)
	{
		gShadow_LR_S4S_DoubleShot = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_GunToss_MarkerMode)
	{
		gShadow_LR_GunToss_MarkerMode = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_GunToss_StartMode)
	{
		gShadow_LR_GunToss_StartMode = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Delay_Enable_Time)
	{
		gShadow_LR_Delay_Enable_Time = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_Announce_Delay_Enable)
	{
		gShadow_Announce_Delay_Enable = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_Announce_HotPotato_Eqp)
	{
		gShadow_Announce_HotPotato_Eqp = bool:StringToInt(newValue);
	}	
	else if (cvar == gH_Cvar_LR_Damage)
	{
		gShadow_LR_Damage = bool:StringToInt(newValue);
	} 	
	else if (cvar == gH_Cvar_LR_NoScope_Delay)
	{
		gShadow_LR_NoScope_Delay = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_KnifeFight_Rebel)
	{
		gShadow_LR_KnifeFight_Rebel = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_Rebel)
	{
		gShadow_LR_ChickenFight_Rebel = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_Rebel)
	{
		gShadow_LR_HotPotato_Rebel = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Rebel_MaxTs)
	{
		gShadow_LR_Rebel_MaxTs = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_Rebel_MinCTs)
	{
		gShadow_LR_Rebel_MinCTs = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_M4M_MagCapacity)
	{
		gShadow_LR_M4M_MagCapacity = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_LR_KnifeFight_LowGrav)
	{
		gShadow_LR_KnifeFight_LowGrav = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_KnifeFight_HiSpeed)
	{
		gShadow_LR_KnifeFight_HiSpeed = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_LR_KnifeFight_Drunk)
	{
		gShadow_LR_KnifeFight_Drunk = StringToInt(newValue);
	}
}

public ConVarChanged_LastRequest(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// Perform boolean checking
	new iNewValue = StringToInt(newValue);
	new iOldValue = StringToInt(oldValue);
	if (iNewValue == iOldValue || !g_bPushedToMenu)
	{
		return;
	}
	
	if (cvar == gH_Cvar_LR_KnifeFight_On)
	{
		gShadow_LR_KnifeFight_On = bool:iNewValue;
		UpdateLastRequestArray(LR_KnifeFight);
	}
	else if (cvar == gH_Cvar_LR_Shot4Shot_On)
	{
		gShadow_LR_Shot4Shot_On = bool:iNewValue;
		UpdateLastRequestArray(LR_Shot4Shot);
	}
	else if (cvar == gH_Cvar_LR_GunToss_On)
	{
		gShadow_LR_GunToss_On = bool:iNewValue;
		UpdateLastRequestArray(LR_GunToss);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_On)
	{
		gShadow_LR_ChickenFight_On = bool:iNewValue;
		UpdateLastRequestArray(LR_ChickenFight);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_On)
	{
		gShadow_LR_HotPotato_On = bool:iNewValue;
		UpdateLastRequestArray(LR_HotPotato);
	}
	else if (cvar == gH_Cvar_LR_Dodgeball_On)
	{
		gShadow_LR_Dodgeball_On = bool:iNewValue;
		UpdateLastRequestArray(LR_Dodgeball);
	}
	else if (cvar == gH_Cvar_LR_NoScope_On)
	{
		gShadow_LR_NoScope_On = bool:iNewValue;
		UpdateLastRequestArray(LR_NoScope);
	}
	else if (cvar == gH_Cvar_LR_RockPaperScissors_On)
	{
		gShadow_LR_RockPaperScissors_On = bool:iNewValue;
		UpdateLastRequestArray(LR_RockPaperScissors);
	}
	else if (cvar == gH_Cvar_LR_Rebel_On)
	{
		gShadow_LR_Rebel_On = bool:iNewValue;
		UpdateLastRequestArray(LR_Rebel);
	}
	else if (cvar == gH_Cvar_LR_Mag4Mag_On)
	{
		gShadow_LR_Mag4Mag_On = bool:iNewValue;
		UpdateLastRequestArray(LR_Mag4Mag);
	}
	else if (cvar == gH_Cvar_LR_Race_On)
	{
		gShadow_LR_Race_On = bool:iNewValue;
		UpdateLastRequestArray(LR_Race);
	}
	else if (cvar == gH_Cvar_LR_RussianRoulette_On)
	{
		gShadow_LR_RussianRoulette_On = bool:iNewValue;
		UpdateLastRequestArray(LR_RussianRoulette);
	}
	else if (cvar == gH_Cvar_LR_JumpContest_On)
	{
		gShadow_LR_JumpContest_On = bool:iNewValue;
		UpdateLastRequestArray(LR_JumpContest);
	}
}

UpdateLastRequestArray(LastRequest:entry)
{
	new iArrayIndex = FindValueInArray(gH_DArray_LastRequests, entry);
	if (iArrayIndex == -1)
	{
		PushArrayCell(gH_DArray_LastRequests, entry);
	}
	else
	{
		RemoveFromArray(gH_DArray_LastRequests, iArrayIndex);
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponDecideUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public Action:Command_LastRequest(client, args)
{
	if (gShadow_LR_Enable)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (g_bIsARebel[client] && !gShadow_RebelHandling)
					{
						PrintToChat(client, CHAT_BANNER, "LR Rebel Not Allowed");
					}
					else
					{
						// check the number of terrorists still alive
						new Ts, CTs, NumCTsAvailable;
						UpdatePlayerCounts(Ts, CTs, NumCTsAvailable);

						if (Ts <= gShadow_MaxPrisonersToLR || gShadow_MaxPrisonersToLR == 0)
						{
							if (CTs > 0)
							{
								if (NumCTsAvailable > 0)
								{
									gH_BuildLR[client] = CreateDataPack();
									new Handle:menu = CreateMenu(LR_Selection_Handler);
									SetMenuTitle(menu, "%T", "LR Choose", client);
									
									decl String:sDataField[MAX_DATAENTRY_SIZE];
									decl String:sTitleField[MAX_DISPLAYNAME_SIZE];
									new LastRequest:entry;	
									new iLR_ArraySize = GetArraySize(gH_DArray_LastRequests);
									new iCustomCount = 0;
									new iCustomLR_Size = GetArraySize(gH_DArray_LR_CustomNames);
									for (new iLR_Index = 0; iLR_Index < iLR_ArraySize; iLR_Index++)
									{
										entry = GetArrayCell(gH_DArray_LastRequests, iLR_Index);
										if (entry < LastRequest)
										{
											if (LastRequest:entry != LR_Rebel || (LastRequest:entry == LR_Rebel && Ts <= gShadow_LR_Rebel_MaxTs && CTs >= gShadow_LR_Rebel_MinCTs))
											{
												Format(sDataField, sizeof(sDataField), "%d", entry);
												Format(sTitleField, sizeof(sTitleField), "%T", g_sLastRequestPhrase[entry], client);
												AddMenuItem(menu, sDataField, sTitleField);
											}
										}
										else
										{
											if (iCustomCount < iCustomLR_Size)
											{
												Format(sDataField, sizeof(sDataField), "%d", entry);
												GetArrayString(gH_DArray_LR_CustomNames, iCustomCount, sTitleField, MAX_DISPLAYNAME_SIZE);
												AddMenuItem(menu, sDataField, sTitleField);
												iCustomCount++;
											}
										}
									}
									
									SetMenuExitButton(menu, true);
									DisplayMenu(menu, client, MENU_TIME_FOREVER);
								}
								else
								{
									PrintToChat(client, "No CTs Are Available");
								}
							}
							else
							{
								PrintToChat(client, CHAT_BANNER, "No CTs Alive");
							}
						}
						else
						{
							PrintToChat(client, CHAT_BANNER, "Too Many Ts");
						}
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "Another LR In Progress");
			}
		}
		else
		{
			PrintToChat(client, CHAT_BANNER, "LR Not Available");
		}
	}
	else
	{
		PrintToChat(client, CHAT_BANNER, "LR Not Available");
	}

	return Plugin_Handled;
}

public LR_Selection_Handler(Handle:menu, MenuAction:action, client, iButtonChoice)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				if (!g_bInLastRequest[client])
				{
					if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
					{
						decl String:sData[MAX_DATAENTRY_SIZE];
						GetMenuItem(menu, iButtonChoice, sData, sizeof(sData));
						new LastRequest:choice = LastRequest:StringToInt(sData);
						g_LRLookup[client] = choice;
						
						switch (choice)
						{
							case LR_KnifeFight:
							{
								new Handle:KnifeFightMenu = CreateMenu(SubLRType_MenuHandler);								
								SetMenuTitle(KnifeFightMenu, "%T", "Knife Fight Selection Menu", client);
								
								decl String:sSubTypeName[MAX_DISPLAYNAME_SIZE];
								decl String:sDataField[MAX_DATAENTRY_SIZE];
								Format(sDataField, sizeof(sDataField), "%d", Knife_Vintage);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Vintage", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_Drunk);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Drunk", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_LowGrav);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_LowGrav", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_HiSpeed);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_HiSpeed", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_Drugs);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Drugs", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_ThirdPerson);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_ThirdPerson", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								
								SetMenuExitBackButton(KnifeFightMenu, true);
								DisplayMenu(KnifeFightMenu, client, 10);
							}
							case LR_Shot4Shot, LR_Mag4Mag:
							{
								new Handle:SubWeaponMenu = CreateMenu(SubLRType_MenuHandler);
								SetMenuTitle(SubWeaponMenu, "%T", "Pistol Selection Menu", client);
								
								decl String:sSubTypeName[MAX_DISPLAYNAME_SIZE];
								decl String:sDataField[MAX_DATAENTRY_SIZE];
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Deagle);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Deagle", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Pistol_P228);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_P228", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);								
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Glock);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Glock", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_FiveSeven);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_FiveSeven", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Dualies);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Dualies", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_USP);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_USP", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);	
								
								SetMenuExitBackButton(SubWeaponMenu, true);
								DisplayMenu(SubWeaponMenu, client, 10);
							}					
							case LR_NoScope:
							{
								if (gShadow_LR_NoScope_Weapon == 2)
								{
									new Handle:NSweaponMenu = CreateMenu(SubLRType_MenuHandler);
									SetMenuTitle(NSweaponMenu, "%T", "NS Weapon Chooser Menu", client);

									decl String:sSubTypeName[MAX_DISPLAYNAME_SIZE];
									decl String:sDataField[MAX_DATAENTRY_SIZE];
									Format(sDataField, sizeof(sDataField), "%d", NSW_AWP);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_AWP", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_Scout);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_Scout", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_SG550);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_SG550", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_G3SG1);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_G3SG1", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
			
									SetMenuExitButton(NSweaponMenu, true);
									DisplayMenu(NSweaponMenu, client, 10);						
								}
								else
								{
									CreateMainPlayerHandler(client);
								}
							}
							case LR_Race:
							{								
								// create menu for T to choose start point
								new Handle:racemenu1 = CreateMenu(RaceStartPointHandler);
								SetMenuTitle(racemenu1, "%T", "Find a Starting Location", client);
								decl String:sMenuText[MAX_DISPLAYNAME_SIZE];
								Format(sMenuText, sizeof(sMenuText), "%T", "Use Current Position", client);
								AddMenuItem(racemenu1, "startloc", sMenuText);
								SetMenuExitButton(racemenu1, true);
								DisplayMenu(racemenu1, client, MENU_TIME_FOREVER);						
								
								if (gShadow_LR_Race_NotifyCTs)
								{
									for (new idx = 1; idx <= MaxClients; idx++)
									{
										if (IsClientInGame(idx) && IsPlayerAlive(idx) && (GetClientTeam(idx) == CS_TEAM_CT))
										{
											PrintToChat(idx, CHAT_BANNER, "Race Could Start Soon", client);
										}
									}
								}
							}
							case LR_Rebel:
							{
								new LastRequest:gametype = g_LRLookup[client];
								new iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, gametype);
								SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, _:Block_Prisoner);
								SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, _:Block_Guard);
								g_bInLastRequest[client] = true;
								InitializeGame(iArrayIndex);			
							}
							case LR_JumpContest:
							{
								new Handle:SubJumpMenu = CreateMenu(SubLRType_MenuHandler);
								SetMenuTitle(SubJumpMenu, "%T", "Jump Contest Menu", client);
								
								decl String:sSubTypeName[MAX_DISPLAYNAME_SIZE];
								decl String:sDataField[MAX_DATAENTRY_SIZE];
								
								Format(sDataField, sizeof(sDataField), "%d", Jump_TheMost);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_TheMost", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Jump_Farthest);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_Farthest", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);								
								Format(sDataField, sizeof(sDataField), "%d", Jump_BrinkOfDeath);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_BrinkOfDeath", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);		
								
								SetMenuExitBackButton(SubJumpMenu, true);
								DisplayMenu(SubJumpMenu, client, 10);							
							}
							default:
							{
								CreateMainPlayerHandler(client);
							}
						}
					}
					else
					{
						PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Another LR In Progress");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "LR Not Available");
			}
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[client] != INVALID_HANDLE)
				{
					CloseHandle(gH_BuildLR[client]);
					gH_BuildLR[client] = INVALID_HANDLE;
				}
			}
			CloseHandle(menu);
		}
	}
}

CreateMainPlayerHandler(client)
{
	new Handle:playermenu = CreateMenu(MainPlayerHandler);
	SetMenuTitle(playermenu, "%T", "Choose A Player", client);

	new iNumCTsAvailable = 0;
	new iUserId = 0;
	decl String:sClientName[MAX_DISPLAYNAME_SIZE];
	decl String:sDataField[MAX_DATAENTRY_SIZE];
	for(new i = 1; i <= MaxClients; i++)
	{
		// if player is alive and CT and not in another LR
		if (IsClientInGame(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_CT) && !g_bInLastRequest[i])
		{
			Format(sClientName, sizeof(sClientName), "%N", i);
			iUserId = GetClientUserId(i);
			Format(sDataField, sizeof(sDataField), "%d", iUserId);
			AddMenuItem(playermenu, sDataField, sClientName);
			iNumCTsAvailable++;
		}
	}

	if (iNumCTsAvailable == 0)
	{
		PrintToChat(client, CHAT_BANNER, "LR No CTs Available");
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(playermenu);
	}
	else
	{
		SetMenuExitButton(playermenu, true);
		DisplayMenu(playermenu, client, 20);
	}
}

public SubLRType_MenuHandler(Handle:SelectionMenu, MenuAction:action, client, iMenuChoice)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					WritePackCell(gH_BuildLR[client], iMenuChoice);
					CreateMainPlayerHandler(client);
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			PrintToChat(client, CHAT_BANNER, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(SelectionMenu);
	}
}

public RaceEndPointHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (gShadow_LR_Race_AirPoints || (GetEntityFlags(client) & FL_ONGROUND))
					{
						// use this location
						new Float:f_EndLocation[3];
						GetClientAbsOrigin(client, f_EndLocation);
						f_EndLocation[2] += 10;
						
						WritePackFloat(gH_BuildLR[client], f_EndLocation[0]);
						WritePackFloat(gH_BuildLR[client], f_EndLocation[1]);
						WritePackFloat(gH_BuildLR[client], f_EndLocation[2]);
						
						// get start location
						new Float:f_StartLocation[3];
						ResetPack(gH_BuildLR[client]);
						f_StartLocation[0] = ReadPackFloat(gH_BuildLR[client]);
						f_StartLocation[1] = ReadPackFloat(gH_BuildLR[client]);
						f_StartLocation[2] = ReadPackFloat(gH_BuildLR[client]);
						
						// check how far the requested end is from the start
						new Float:distanceBetweenPoints = GetVectorDistance(f_StartLocation, f_EndLocation, false);
						
						if (distanceBetweenPoints > 300.0)
						{
							TE_SetupBeamRingPoint(f_EndLocation, 100.0, 130.0, BeamSprite, HaloSprite, 0, 15, 20.0, 7.0, 0.0, greenColor, 1, 0);
							TE_SendToAll();						
							// allow them to choose a player finally
							CreateMainPlayerHandler(client);
						}
						else
						{
							PrintToChat(client, CHAT_BANNER, "Race Points too Close");
						}
					}
					else
					{
						PrintToChat(client, CHAT_BANNER, "Must Be On Ground");
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			PrintToChat(client, CHAT_BANNER, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(menu);
	}
}

public RaceStartPointHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (gShadow_LR_Race_AirPoints || (GetEntityFlags(client) & FL_ONGROUND))
					{
						// use this location
						new Float:f_StartPoint[3];
						GetClientAbsOrigin(client, f_StartPoint);
						f_StartPoint[2] += 10;

						TE_SetupBeamRingPoint(f_StartPoint, 100.0, 130.0, BeamSprite, HaloSprite, 0, 15, 30.0, 7.0, 0.0, yellowColor, 1, 0);
						TE_SendToAll();
						
						// write start point
						WritePackFloat(gH_BuildLR[client], f_StartPoint[0]);
						WritePackFloat(gH_BuildLR[client], f_StartPoint[1]);
						WritePackFloat(gH_BuildLR[client], f_StartPoint[2]);
						
						CreateRaceEndPointMenu(client);
					}
					else
					{
						PrintToChat(client, CHAT_BANNER, "Must Be On Ground");
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			PrintToChat(client, CHAT_BANNER, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(menu);
	}
}

CreateRaceEndPointMenu(client)
{
	new Handle:EndPointMenu = CreateMenu(RaceEndPointHandler);
	SetMenuTitle(EndPointMenu, "%T", "Choose an End Point", client);
	decl String:sMenuText[MAX_DISPLAYNAME_SIZE];
	Format (sMenuText, sizeof(sMenuText), "%T", "Use Current Position", client);
	AddMenuItem(EndPointMenu, "endpoint", sMenuText);
	SetMenuExitButton(EndPointMenu, true);
	DisplayMenu(EndPointMenu, client, MENU_TIME_FOREVER);
}

public MainPlayerHandler(Handle:playermenu, MenuAction:action, client, iButtonChoice)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				if (!g_bInLastRequest[client])
				{
					if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
					{
						decl String:sData[MAX_DATAENTRY_SIZE];
						GetMenuItem(playermenu, iButtonChoice, sData, sizeof(sData));
						new ClientIdxOfCT = GetClientOfUserId(StringToInt(sData));
						
						if (IsClientInGame(ClientIdxOfCT) && IsPlayerAlive(ClientIdxOfCT) && (GetClientTeam(ClientIdxOfCT) == CS_TEAM_CT))
						{
							// check the number of terrorists still alive
							new Ts, CTs, iNumCTsAvailable;
							UpdatePlayerCounts(Ts, CTs, iNumCTsAvailable);
	
							if (Ts <= gShadow_MaxPrisonersToLR || gShadow_MaxPrisonersToLR == 0)
							{
								if (CTs > 0)
								{
									if (iNumCTsAvailable > 0)
									{
										if (!IsFakeClient(ClientIdxOfCT))
										{
											if (!g_bIsARebel[client] || (gShadow_RebelHandling == 2))
											{
												if (!g_bInLastRequest[ClientIdxOfCT])
												{
													// lock in this LR pair
													new LastRequest:game = g_LRLookup[client];
													if ((game == LR_HotPotato || game == LR_RussianRoulette) && IsClientTooNearObstacle(client))
													{
														PrintToChat(client, CHAT_BANNER, "Too Near Obstruction");
													}
													// player isn't on ground
													else if ((game == LR_JumpContest) && !(GetEntityFlags(client) & FL_ONGROUND|FL_INWATER))
													{
														PrintToChat(client, CHAT_BANNER, "Must Be On Ground");
													}
													else
													{
														new iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, game);
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, _:Block_Prisoner);
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, ClientIdxOfCT, _:Block_Guard);
														g_bInLastRequest[client] = true;
														g_bInLastRequest[ClientIdxOfCT] = true;
														InitializeGame(iArrayIndex);
													}
												}
												else
												{
													PrintToChat(client, CHAT_BANNER, "Another LR In Progress");
												}
											}
											else
											{
												// if rebel, send a menu to the CT asking for permission
												new Handle:askmenu = CreateMenu(MainAskHandler);
												decl String:lrname[MAX_DISPLAYNAME_SIZE];
												if (g_LRLookup[client] < LastRequest)
												{
													Format(lrname, sizeof(lrname), "%T", g_sLastRequestPhrase[g_LRLookup[client]], ClientIdxOfCT);		
												}
												else
												{
													GetArrayString(gH_DArray_LR_CustomNames, _:(g_LRLookup[client] - LastRequest), lrname, MAX_DISPLAYNAME_SIZE);
												}
												SetMenuTitle(askmenu, "%T", "Rebel Ask CT For LR", ClientIdxOfCT, client, lrname);
		
												decl String:yes[8];
												decl String:no[8];
												Format(yes, sizeof(yes), "%T", "Yes", ClientIdxOfCT);
												Format(no, sizeof(no), "%T", "No", ClientIdxOfCT);
												AddMenuItem(askmenu, "yes", yes);
												AddMenuItem(askmenu, "no", no);
		
												g_LR_PermissionLookup[ClientIdxOfCT] = client;
												SetMenuExitButton(askmenu, true);
												DisplayMenu(askmenu, ClientIdxOfCT, 6);
		
												PrintToChat(client, CHAT_BANNER, "Asking For Permission", ClientIdxOfCT);
											}
										}
										else
										{
											PrintToChat(client, CHAT_BANNER, "LR Not With Bot");
										}
									}
									else
									{
										PrintToChat(client, "LR No CTs Available");
									}
								}
								else
								{
									PrintToChat(client, CHAT_BANNER, "No CTs Alive");
								}
							}
							else
							{
								PrintToChat(client, CHAT_BANNER, "Too Many Ts");
							}
						}
						else
						{
							PrintToChat(client, CHAT_BANNER, "Target Is Not Alive Or In Wrong Team");
						}
					}
					else
					{
						PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Another LR In Progress");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "LR Not Available");
			}	
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[client] != INVALID_HANDLE)
				{
					CloseHandle(gH_BuildLR[client]);
					gH_BuildLR[client] = INVALID_HANDLE;
				}
			}
			CloseHandle(playermenu);
		}
	}
}

public MainAskHandler(Handle:askmenu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				// client here is the guard
				if (!g_bInLastRequest[g_LR_PermissionLookup[client]])
				{
					if ((IsClientInGame(g_LR_PermissionLookup[client])) && (IsPlayerAlive(g_LR_PermissionLookup[client])))
					{
						if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_CT))
						{
							// param2, 0 -> yes
							if (param2 == 0 || (client != 0 && IsFakeClient(client)) )
							{
								if (!g_bInLastRequest[client])
								{
									// lock in this LR pair
									new LastRequest:game = g_LRLookup[g_LR_PermissionLookup[client]];
									new iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, game);
									SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, g_LR_PermissionLookup[client], _:Block_Prisoner);
									SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, _:Block_Guard);
									g_bInLastRequest[client] = true;
									g_bInLastRequest[g_LR_PermissionLookup[client]] = true;
									InitializeGame(iArrayIndex);
								}
								else
								{
									PrintToChat(client, CHAT_BANNER, "Too Slow Another LR In Progress");
								}
							}
							else
							{
								PrintToChat(g_LR_PermissionLookup[client], CHAT_BANNER, "Declined LR Request", client);
							}
						}
						else
						{
							PrintToChat(client, CHAT_BANNER, "Not Alive Or In Wrong Team");
						}
					}
					else
					{
						PrintToChat(client, CHAT_BANNER, "LR Partner Died");
					}
				}
				else
				{
					PrintToChat(client, CHAT_BANNER, "Too Slow Another LR In Progress");
				}
			}
			else
			{
				PrintToChat(client, CHAT_BANNER, "LR Not Available");
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(g_LR_PermissionLookup[client]))
			{
				PrintToChat(g_LR_PermissionLookup[client], CHAT_BANNER, "LR Request Decline Or Too Long", client);
			}
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[g_LR_PermissionLookup[client]] != INVALID_HANDLE)
				{
					CloseHandle(gH_BuildLR[g_LR_PermissionLookup[client]]);
					gH_BuildLR[g_LR_PermissionLookup[client]] = INVALID_HANDLE;
				}
			}
			CloseHandle(askmenu);
		}
	}
}

InitializeGame(iPartnersIndex)
{
	// grab the info
	new LastRequest:selection = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, _:Block_LRType);
	new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, _:Block_Prisoner);
	new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, _:Block_Guard);
	
	switch (selection)
	{
		case LR_KnifeFight:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			new KnifeType:KnifeChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			KnifeChoice = KnifeType:ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, KnifeChoice, _:Block_Global1);
			
			switch (KnifeChoice)
			{
				case Knife_Drunk:
				{
					SetEntData(LR_Player_Prisoner, g_Offset_FOV, 105, 4, true);
					SetEntData(LR_Player_Prisoner, g_Offset_DefFOV, 105, 4, true);	
					ShowOverlayToClient(LR_Player_Prisoner, "effects/strider_pinch_dudv");
					SetEntData(LR_Player_Guard, g_Offset_FOV, 105, 4, true);
					SetEntData(LR_Player_Guard, g_Offset_DefFOV, 105, 4, true);	
					ShowOverlayToClient(LR_Player_Guard, "effects/strider_pinch_dudv");
					if (g_BeerGogglesTimer == INVALID_HANDLE)
					{
						g_BeerGogglesTimer = CreateTimer(1.0, Timer_BeerGoggles, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}							
				}
				case Knife_LowGrav:
				{
					SetEntityGravity(LR_Player_Prisoner, gShadow_LR_KnifeFight_LowGrav);
					SetEntityGravity(LR_Player_Guard, gShadow_LR_KnifeFight_LowGrav);
				}
				case Knife_HiSpeed:
				{
					SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", gShadow_LR_KnifeFight_HiSpeed);
					SetEntPropFloat(LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", gShadow_LR_KnifeFight_HiSpeed);
				}
				case Knife_ThirdPerson:
				{
					SetThirdPerson(LR_Player_Prisoner);
					SetThirdPerson(LR_Player_Guard);
				}
				case Knife_Drugs:
				{
					ShowOverlayToClient(LR_Player_Prisoner, "models/effects/portalfunnel_sheet");
					ShowOverlayToClient(LR_Player_Guard, "models/effects/portalfunnel_sheet");
				}
			}
			
			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
			SetEntData(LR_Player_Guard, g_Offset_Health, 100);

			// give knives
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");

			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR KF Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_Shot4Shot:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			// grab weapon choice
			new PistolWeapon:PistolChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			PistolChoice = PistolWeapon:ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
	
			new Pistol_Prisoner, Pistol_Guard;
			switch (PistolChoice)
			{
				case Pistol_Deagle:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
				case Pistol_P228:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p228");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p228");
				}
				case Pistol_Glock:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_glock");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_glock");
				}
				case Pistol_FiveSeven:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_fiveseven");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_fiveseven");
				}
				case Pistol_Dualies:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_elite");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_elite");
				}
				case Pistol_USP:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp");
				}
				default:
				{
					LogError("hit default S4S");
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
			}
			
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Prisoner, _:Block_PrisonerData);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Guard, _:Block_GuardData);
			
			PrintToChatAll(CHAT_BANNER, "LR S4S Start", LR_Player_Prisoner, LR_Player_Guard);
			
			// randomize who starts first
			new s4sPlayerFirst = GetRandomInt(0, 1);
			if (s4sPlayerFirst == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 1);
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Prisoner, _:Block_Global1);
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 1);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);			
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Guard, _:Block_Global1);
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);				
				}
			}

			// set secondary ammo to 0
			new iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
			SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);

			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
			SetEntData(LR_Player_Guard, g_Offset_Health, 100);
		}
		case LR_GunToss:
		{
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, _:Block_Global1); // GTp1dropped
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, _:Block_Global2); // GTp2dropped
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, _:Block_Global3); // GTp1done
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, _:Block_Global4); // GTp2done
			
			new Handle:DataPackPosition = CreateDataPack();
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, DataPackPosition, _:Block_DataPackHandle); // position handle
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0); // GTdeagle1lastpos
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0); // GTdeagle2lastpos
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0); // 
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0);
			WritePackFloat(DataPackPosition, Float:0.0); // 

			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			// give knives and deagles
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");
			new GTdeagle1 = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			new GTdeagle2 = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
			new Prisoner_GunEntRef = EntIndexToEntRef(GTdeagle1);
			new Guard_GunEntRef = EntIndexToEntRef(GTdeagle2);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Prisoner_GunEntRef, _:Block_PrisonerData);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Guard_GunEntRef, _:Block_GuardData);

			// set ammo (Clip2) 0 -- we don't need any extra ammo...
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(1*4), 0);
			SetEntData(LR_Player_Guard, g_Offset_Ammo+(1*4), 0);

			if (gShadow_LR_GunToss_StartMode > 0)
			{
				// set ammo (Clip1)
				SetEntData(GTdeagle1, g_Offset_Clip1, 0);
				SetEntData(GTdeagle2, g_Offset_Clip1, 0);
				
				SetEntityRenderMode(GTdeagle1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(GTdeagle1, 255, 0, 0);
				SetEntityRenderMode(GTdeagle2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(GTdeagle2, 0, 0, 255);
			}

			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR GT Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_ChickenFight:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			if (g_ChickenFightTimer == INVALID_HANDLE)
			{
				g_ChickenFightTimer = CreateTimer(0.2, Timer_ChickenFight, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}

			if (gShadow_NoBlock)
			{
				BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
				BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			}

			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR CF Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_HotPotato:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			// always give potato to the prisoner
			new potatoClient = LR_Player_Prisoner;
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, potatoClient, _:Block_Global1); // HPloser

			// create the potato deagle
			new HPdeagle = CreateEntityByName("weapon_deagle");
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, HPdeagle, _:Block_Global4);
			DispatchSpawn(HPdeagle);
			EquipPlayerWeapon(potatoClient, HPdeagle);

			// set ammo (Clip2) 0
			SetEntData(potatoClient, g_Offset_Ammo+(1*4), 0);
			// set ammo (Clip1) 0
			SetEntData(HPdeagle, g_Offset_Clip1, 0);

			SetEntityRenderMode(HPdeagle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(HPdeagle, 255, 255, 0);

			decl Float:p1pos[3], Float:p2pos[3];
			GetClientAbsOrigin(LR_Player_Prisoner, p1pos);
			
			decl Float:f_PrisonerAngles[3], Float:f_SubtractFromPrisoner[3];
			GetClientEyeAngles(LR_Player_Prisoner, f_PrisonerAngles);			
			// zero out pitch/yaw
			f_PrisonerAngles[0] = 0.0;			
			GetAngleVectors(f_PrisonerAngles, f_SubtractFromPrisoner, NULL_VECTOR, NULL_VECTOR);
			decl Float:f_GuardDirection[3];
			f_GuardDirection = f_SubtractFromPrisoner;
			ScaleVector(f_SubtractFromPrisoner, -70.0);			
			MakeVectorFromPoints(f_SubtractFromPrisoner, p1pos, p2pos);

			// create 'unique' ID for this hot potato
			new uniqueID = GetRandomInt(1, 31337);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, uniqueID, _:Block_Global3);
			
			// create timer to end hot potato
			new Float:rndEnd = GetRandomFloat(gShadow_LR_HotPotato_MinTime, gShadow_LR_HotPotato_MaxTime);
			CreateTimer(rndEnd, Timer_HotPotatoDone, uniqueID, TIMER_FLAG_NO_MAPCHANGE);

			if (gShadow_LR_HotPotato_Mode == 2)
			{
				SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
				SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);			
				ScaleVector(f_GuardDirection, -1.0);				
				TeleportEntity(LR_Player_Guard, p2pos, f_GuardDirection, NULL_VECTOR);
			}
			else
			{
				if (gShadow_LR_HotPotato_Mode == 1)
				{	
					if (gShadow_NoBlock)
					{
						UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
						UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					}				
					TeleportEntity(LR_Player_Guard, p1pos, NULL_VECTOR, NULL_VECTOR);					
				}
				
				SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", gShadow_LR_HotPotato_Speed);				
			}


			TeleportEntity(HPdeagle, p1pos, NULL_VECTOR, NULL_VECTOR);
			
			if (gShadow_LR_Beacons)
			{
				AddBeacon(HPdeagle);
			}
			
			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR HP Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_Dodgeball:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			// bug fix...
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo + (_:12 * 4), 0, _, true);
			SetEntData(LR_Player_Guard, g_Offset_Ammo + (_:12 * 4), 0, _, true);

			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 1);
			SetEntData(LR_Player_Guard, g_Offset_Health, 1);
			SetEntData(LR_Player_Prisoner, g_Offset_Armor, 0);
			SetEntData(LR_Player_Guard, g_Offset_Armor, 0);

			// give flashbangs
			new flash1 = CreateEntityByName("weapon_flashbang");
			new flash2 = CreateEntityByName("weapon_flashbang");
			DispatchSpawn(flash1);
			DispatchSpawn(flash2);
			EquipPlayerWeapon(LR_Player_Prisoner, flash1);
			EquipPlayerWeapon(LR_Player_Guard, flash2);

			SetEntityGravity(LR_Player_Prisoner, gShadow_LR_Dodgeball_Gravity);
			SetEntityGravity(LR_Player_Guard, gShadow_LR_Dodgeball_Gravity);

			if (gShadow_NoBlock)
			{
				BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
				BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			}

			// timer making sure DB contestants stay @ 1 HP (if enabled by cvar)
			if ((g_DodgeballTimer == INVALID_HANDLE) && gShadow_LR_Dodgeball_CheatCheck)
			{
				g_DodgeballTimer = CreateTimer(1.0, Timer_DodgeballCheckCheaters, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}

			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR DB Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_NoScope:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);

			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
			SetEntData(LR_Player_Guard, g_Offset_Health, 100);

			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");

			new NoScopeWeapon:WeaponChoice;
			switch (gShadow_LR_NoScope_Weapon)
			{
				case 0:
				{
					WeaponChoice = NSW_AWP;
				}
				case 1:
				{
					WeaponChoice = NSW_Scout;
				}
				case 2:
				{
					ResetPack(gH_BuildLR[LR_Player_Prisoner]);
					WeaponChoice = NoScopeWeapon:ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);				
				}
				case 3:
				{
					WeaponChoice = NSW_SG550;
				}
				case 4:
				{
					WeaponChoice = NSW_G3SG1;
				}
			}
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, WeaponChoice, _:Block_Global2);
			
			PrintToChatAll(CHAT_BANNER, "LR NS Start", LR_Player_Prisoner, LR_Player_Guard);
			
			if (gShadow_LR_NoScope_Delay > 0)
			{
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, gShadow_LR_NoScope_Delay, _:Block_Global1);
				if (g_CountdownTimer == INVALID_HANDLE)
				{
					g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			// launch now if there's no countdown requested
			else
			{				
				new NSW_Prisoner, NSW_Guard;
				switch (WeaponChoice)
				{
					case NSW_AWP:
					{
						NSW_Prisoner = CreateEntityByName("weapon_awp");
						NSW_Guard = CreateEntityByName("weapon_awp");
					}
					case NSW_Scout:
					{
						NSW_Prisoner = CreateEntityByName("weapon_scout");
						NSW_Guard = CreateEntityByName("weapon_scout");
					}
					case NSW_SG550:
					{
						NSW_Prisoner = CreateEntityByName("weapon_sg550");
						NSW_Guard = CreateEntityByName("weapon_sg550");
					}
					case NSW_G3SG1:
					{
						NSW_Prisoner = CreateEntityByName("weapon_g3sg1");
						NSW_Guard = CreateEntityByName("weapon_g3sg1");
					}
					default:
					{
						LogError("hit default NS");
						NSW_Prisoner = CreateEntityByName("weapon_scout");
						NSW_Guard = CreateEntityByName("weapon_scout");
					}
				}
				
				DispatchSpawn(NSW_Prisoner);
				DispatchSpawn(NSW_Guard);
				EquipPlayerWeapon(LR_Player_Prisoner, NSW_Prisoner);
				EquipPlayerWeapon(LR_Player_Guard, NSW_Guard);
				SetEntData(NSW_Prisoner, g_Offset_Clip1, 99);
				SetEntData(NSW_Guard, g_Offset_Clip1, 99);		
				
				if ((strlen(gShadow_LR_NoScope_Sound) > 0) && !StrEqual(gShadow_LR_NoScope_Sound, "-1"))
				{
					EmitSoundToAll(gShadow_LR_NoScope_Sound);
				}				
			}
		}
		case LR_RockPaperScissors:
		{
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, -1, _:Block_Global1);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, -1, _:Block_Global2);
			new Handle:rpsmenu1 = CreateMenu(RPSmenuHandler);
			SetMenuTitle(rpsmenu1, "%T", "Rock Paper Scissors", LR_Player_Prisoner);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, rpsmenu1, _:Block_PrisonerData);

			decl String:r1[32], String:p1[64], String:s1[64];
			Format(r1, sizeof(r1), "%T", "Rock", LR_Player_Prisoner);
			Format(p1, sizeof(p1), "%T", "Paper", LR_Player_Prisoner);
			Format(s1, sizeof(s1), "%T", "Scissors", LR_Player_Prisoner);
			AddMenuItem(rpsmenu1, "0", r1);
			AddMenuItem(rpsmenu1, "1", p1);
			AddMenuItem(rpsmenu1, "2", s1);

			SetMenuExitButton(rpsmenu1, true);
			DisplayMenu(rpsmenu1, LR_Player_Prisoner, 20);

			new Handle:rpsmenu2 = CreateMenu(RPSmenuHandler);
			SetMenuTitle(rpsmenu2, "%T", "Rock Paper Scissors", LR_Player_Guard);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, rpsmenu2, _:Block_GuardData);

			decl String:r2[32], String:p2[64], String:s2[64];
			Format(r2, sizeof(r2), "%T", "Rock", LR_Player_Guard);
			Format(p2, sizeof(p2), "%T", "Paper", LR_Player_Guard);
			Format(s2, sizeof(s2), "%T", "Scissors", LR_Player_Guard);
			AddMenuItem(rpsmenu2, "0", r2);
			AddMenuItem(rpsmenu2, "1", p2);
			AddMenuItem(rpsmenu2, "2", s2);

			SetMenuExitButton(rpsmenu2, true);
			DisplayMenu(rpsmenu2, LR_Player_Guard, 20);

			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR RPS Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_Rebel:
		{
			// strip weapons from T rebelling
			StripAllWeapons(LR_Player_Prisoner);

			// give knife, deagle, and m249
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			new RebelDeagle = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			GivePlayerItem(LR_Player_Prisoner, "weapon_m249");

			// set primary and secondary ammo
			SetEntData(RebelDeagle, g_Offset_Clip1, 7);
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(1*4), 42);

			// find number of alive CTs
			new numCTsAlive = 0;
			for(new i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i))
				{
					if (GetClientTeam(i) == CS_TEAM_CT)
					{
						numCTsAlive++;
					}
				}
			}
			
			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, numCTsAlive*100+25);
			
			// announce LR
			PrintToChatAll(CHAT_BANNER, "LR Has Chosen to Rebel!", LR_Player_Prisoner);
		}
		case LR_Mag4Mag:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_Global2); // M4MroundsFired
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_Global3); // M4Mammo
			
			// give knives and deagles
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");
			// grab weapon choice
			new PistolChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			PistolChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
	
			new Pistol_Prisoner, Pistol_Guard;
			switch (PistolChoice)
			{
				case Pistol_Deagle:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
				case Pistol_P228:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p228");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p228");
				}
				case Pistol_Glock:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_glock");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_glock");
				}
				case Pistol_FiveSeven:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_fiveseven");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_fiveseven");
				}
				case Pistol_Dualies:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_elite");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_elite");
				}
				case Pistol_USP:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp");
				}
				default:
				{
					LogError("hit default S4S");
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
			}

			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Prisoner, _:Block_PrisonerData);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Guard, _:Block_GuardData);
			
			PrintToChatAll(CHAT_BANNER, "LR Mag4Mag Start", LR_Player_Prisoner, LR_Player_Guard);
			
			SetEntDataFloat(Pistol_Prisoner, g_Offset_SecAttack, 5000.0);
			SetEntDataFloat(Pistol_Guard, g_Offset_SecAttack, 5000.0);
			
			new m4mPlayerFirst = GetRandomInt(0, 1);
			if (m4mPlayerFirst == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, gShadow_LR_M4M_MagCapacity);
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Guard, _:Block_Global1); // S4Slastshot
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, gShadow_LR_M4M_MagCapacity);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);			
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Prisoner, _:Block_Global1);
			}
		
			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
			SetEntData(LR_Player_Guard, g_Offset_Health, 100);

			new iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
			SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
		}
		case LR_Race:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);
			
			if (!gShadow_NoBlock)
			{
				UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
				UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			}
			
			SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
			SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);
			
			//  teleport both players to the start of the race
			decl Float:f_StartLocation[3], Float:f_EndLocation[3];
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[0] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[1] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[2] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[0] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[1] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[2] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			new Handle:ThisDataPack = CreateDataPack();
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, ThisDataPack, 9);
			WritePackFloat(ThisDataPack, f_EndLocation[0]);
			WritePackFloat(ThisDataPack, f_EndLocation[1]);
			WritePackFloat(ThisDataPack, f_EndLocation[2]);
			
			TeleportEntity(LR_Player_Prisoner, f_StartLocation, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(LR_Player_Guard, f_StartLocation, NULL_VECTOR, NULL_VECTOR);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 3, _:Block_Global1);
			// fire timer for race begin countdown
			if (g_CountdownTimer == INVALID_HANDLE)
			{
				g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		case LR_RussianRoulette:
		{
			StripAllWeapons(LR_Player_Prisoner);
			StripAllWeapons(LR_Player_Guard);
			
			decl Float:p1pos[3], Float:p2pos[3];
			GetClientAbsOrigin(LR_Player_Prisoner, p1pos);
			
			decl Float:f_PrisonerAngles[3], Float:f_SubtractFromPrisoner[3];
			GetClientEyeAngles(LR_Player_Prisoner, f_PrisonerAngles);
			// zero out pitch/yaw
			f_PrisonerAngles[0] = 0.0;			
			GetAngleVectors(f_PrisonerAngles, f_SubtractFromPrisoner, NULL_VECTOR, NULL_VECTOR);
			decl Float:f_GuardDirection[3];
			f_GuardDirection = f_SubtractFromPrisoner;
			ScaleVector(f_SubtractFromPrisoner, -70.0);			
			MakeVectorFromPoints(f_SubtractFromPrisoner, p1pos, p2pos);

			SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
			SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);			
			ScaleVector(f_GuardDirection, -1.0);			
			TeleportEntity(LR_Player_Guard, p2pos, f_GuardDirection, NULL_VECTOR);

			new Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			new Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Prisoner, _:Block_PrisonerData);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Guard, _:Block_GuardData);		
			
			PrintToChatAll(CHAT_BANNER, "LR RR Start", LR_Player_Prisoner, LR_Player_Guard);
			
			// randomize who starts first
			if (GetRandomInt(0, 1) == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 1);
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Guard);
				}
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 1);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);
				if (gShadow_SendGlobalMsgs)
				{
					PrintToChatAll(CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);
					PrintToChat(LR_Player_Guard, CHAT_BANNER, "Randomly Chose First Player", LR_Player_Prisoner);				
				}
			}

			// set secondary ammo to 0
			new iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
			SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);

			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
			SetEntData(LR_Player_Guard, g_Offset_Health, 100);			
		}
		case LR_JumpContest:
		{		
			new JumpChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			JumpChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, JumpChoice, _:Block_Global2);
			
			switch (JumpChoice)
			{
				case Jump_TheMost:
				{
					// reset jump counts
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_PrisonerData);
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_GuardData);
					// set countdown timer
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 3, _:Block_Global1);
					
					if (g_CountdownTimer == INVALID_HANDLE)
					{
						g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
					
					PrintToChatAll(CHAT_BANNER, "Start Jump Contest", LR_Player_Prisoner, LR_Player_Guard);
					
					if (!gShadow_NoBlock)
					{
						UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
						UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					}
					decl Float:Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					TeleportEntity(LR_Player_Guard, Prisoner_Position, NULL_VECTOR, NULL_VECTOR);
				}
				case Jump_Farthest:
				{
					// record current starting position for "ground" level comparison
					decl Float:Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);

					// we only need the Z-axis
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Prisoner_Position[2], _:Block_Global3);					

					// set jumped bools to false					
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_PrisonerData);
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, _:Block_GuardData);					
					
					PrintToChatAll(CHAT_BANNER, "Start Farthest Jump", LR_Player_Prisoner, LR_Player_Guard);
					
					// start detection timer
					if (g_FarthestJumpTimer == INVALID_HANDLE)
					{
						g_FarthestJumpTimer = CreateTimer(0.1, Timer_FarthestJumpDetector, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
					
					new Handle:JumpPackPosition = CreateDataPack();
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, JumpPackPosition, _:Block_DataPackHandle); // position handle
					WritePackFloat(JumpPackPosition, Float:0.0);
					WritePackFloat(JumpPackPosition, Float:0.0);
					WritePackFloat(JumpPackPosition, Float:0.0); // Prisoner Jump Position
					WritePackFloat(JumpPackPosition, Float:0.0);
					WritePackFloat(JumpPackPosition, Float:0.0);
					WritePackFloat(JumpPackPosition, Float:0.0); // Guard Jump Position					
				}
				case Jump_BrinkOfDeath:
				{
					StripAllWeapons(LR_Player_Prisoner);
					StripAllWeapons(LR_Player_Guard);

					SetEntData(LR_Player_Prisoner, g_Offset_Health, 100);
					SetEntData(LR_Player_Guard, g_Offset_Health, 100);
					
					if (!gShadow_NoBlock)
					{
						UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
						UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					}
					
					decl Float:Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					TeleportEntity(LR_Player_Guard, Prisoner_Position, NULL_VECTOR, NULL_VECTOR);
					
					PrintToChatAll(CHAT_BANNER, "Start Brink of Death", LR_Player_Prisoner, LR_Player_Guard);
					
					// timer to quit the LR
					CreateTimer(22.0, Timer_JumpContestOver, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		default:
		{
			Call_StartForward(gH_Frwd_LR_Start);
			Call_PushCell(gH_DArray_LR_Partners);
			Call_PushCell(iPartnersIndex);
			new ignore;
			Call_Finish(_:ignore);
		}
	}
	
	// Close datapack
	if (gH_BuildLR[LR_Player_Prisoner] != INVALID_HANDLE)
	{
		CloseHandle(gH_BuildLR[LR_Player_Prisoner]);		
	}
	gH_BuildLR[LR_Player_Prisoner] = INVALID_HANDLE;

	// Beacon players
	if (gShadow_LR_Beacons && selection != LR_Rebel && selection != LR_RussianRoulette)
	{
		AddBeacon(LR_Player_Prisoner);
		AddBeacon(LR_Player_Guard);
	}
}

public Action:Timer_FarthestJumpDetector(Handle:timer)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_JumpContest)
			{
				new JumpContest:subType = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
				if (subType == Jump_Farthest)
				{								
					new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
					new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);					
					new Float:f_HeightOfGroundLevel = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global3);
					new bool:Prisoner_Jumped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
					new bool:Guard_Jumped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
					new bool:Prisoner_Landed = false;
					new bool:Guard_Landed = false;

					decl Float:Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					
					new Prisoner_Flags = GetEntityFlags(LR_Player_Prisoner);
					new Guard_Flags = GetEntityFlags(LR_Player_Guard);
					
					if (!Prisoner_Jumped && !(Prisoner_Flags & FL_ONGROUND))
					{	
						if ((Prisoner_Flags & FL_DUCKING))
						{
							if (Prisoner_Position[2] < (f_HeightOfGroundLevel - 60.0))
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, 1, _:Block_PrisonerData);
							}
						}
						else
						{
							if (Prisoner_Position[2] < f_HeightOfGroundLevel)
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, 1, _:Block_PrisonerData);
							}
						}
					}
					
					decl Float:Guard_Position[3];
					GetClientAbsOrigin(LR_Player_Guard, Guard_Position);						
					
					if (!Guard_Jumped && !(Guard_Flags & FL_ONGROUND))
					{
						if ((Guard_Flags & FL_DUCKING))
						{
							if (Guard_Position[2] < (f_HeightOfGroundLevel - 60.0))
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, 1, _:Block_GuardData);
							}
						}
						else
						{
							if (Guard_Position[2] < f_HeightOfGroundLevel)
							{
								SetArrayCell(gH_DArray_LR_Partners, idx, 1, _:Block_GuardData);
							}
						}
					}
					
					// check if they're back on the ground yet and freeze them
					if (Prisoner_Jumped && (GetEntityFlags(LR_Player_Prisoner) & FL_ONGROUND))
					{
						SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
						Prisoner_Landed = true;
					}
					
					if (Guard_Jumped && (GetEntityFlags(LR_Player_Guard) & FL_ONGROUND))
					{
						SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);
						Guard_Landed = true;
					}
					
					if (Prisoner_Landed && Guard_Landed)
					{
						new Handle:JumpPackPosition = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_DataPackHandle);
						decl Float:Prisoner_JumpPosition[3], Float:Guard_JumpPosition[3];
						ResetPack(JumpPackPosition);
						Prisoner_JumpPosition[0] = ReadPackFloat(JumpPackPosition);
						Prisoner_JumpPosition[1] = ReadPackFloat(JumpPackPosition);
						Prisoner_JumpPosition[2] = ReadPackFloat(JumpPackPosition);
						Guard_JumpPosition[0] = ReadPackFloat(JumpPackPosition);
						Guard_JumpPosition[1] = ReadPackFloat(JumpPackPosition);
						Guard_JumpPosition[2] = ReadPackFloat(JumpPackPosition);						

						// determine who is farthest from their start position
						new Float:Prisoner_Distance = GetVectorDistance(Prisoner_Position, Prisoner_JumpPosition);
						new Float:Guard_Distance = GetVectorDistance(Guard_Position, Guard_JumpPosition);
                  
						if (Prisoner_Distance > Guard_Distance)
						{
							PrintToChatAll(CHAT_BANNER, "Farthest Jump Won", LR_Player_Prisoner, LR_Player_Guard, Prisoner_Distance, Guard_Distance);
							ForcePlayerSuicide(LR_Player_Guard);
						}
						// award ties to the guard
						else if (Guard_Distance >= Prisoner_Distance)
						{
							PrintToChatAll(CHAT_BANNER, "Farthest Jump Won", LR_Player_Guard, LR_Player_Prisoner, Prisoner_Distance, Guard_Distance);
							ForcePlayerSuicide(LR_Player_Prisoner);
						}						
					}

				}
			}
		}
	}
	else
	{
		g_FarthestJumpTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:Timer_JumpContestOver(Handle:timer)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_JumpContest)
			{
				new jumptype = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);				
				switch (jumptype)
				{
					case Jump_TheMost:
					{						
						new Guard_JumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData);
						new Prisoner_JumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData);
						
						if (Prisoner_JumpCount > Guard_JumpCount)
						{
							PrintToChatAll(CHAT_BANNER, "Won Jump Contest", LR_Player_Prisoner);
							ForcePlayerSuicide(LR_Player_Guard);
						}
						else
						{
							PrintToChatAll(CHAT_BANNER, "Won Jump Contest", LR_Player_Guard);
							ForcePlayerSuicide(LR_Player_Prisoner);
						}
					}
					case Jump_BrinkOfDeath:
					{
						new Prisoner_Health = GetClientHealth(LR_Player_Prisoner);
						new Guard_Health = GetClientHealth(LR_Player_Guard);
						
						new loser = (Prisoner_Health > Guard_Health) ? LR_Player_Prisoner : LR_Player_Guard;
						new winner = (Prisoner_Health > Guard_Health) ? LR_Player_Guard : LR_Player_Prisoner;
						
						// TODO *** consider adding this as an option (random or abort)
						if (Prisoner_Health == Guard_Health)
						{
							new random = GetRandomInt(0,1);
							winner = (random) ? LR_Player_Prisoner : LR_Player_Guard;
							loser = (random) ? LR_Player_Guard : LR_Player_Prisoner;
						}
						
						ForcePlayerSuicide(loser);
						if (IsPlayerAlive(winner))
						{
							SetEntityHealth(winner, 100);
							if (!gShadow_NoBlock)
							{
								BlockEntity(winner, g_Offset_CollisionGroup);
							}
						}						
						
						PrintToChatAll(CHAT_BANNER, "Won Jump Contest", winner);
					}
				}
			}
		}
	}	
}

public Action:Timer_Beacon(Handle:timer)
{
	new iNumOfBeacons = GetArraySize(gH_DArray_Beacons);
	if (iNumOfBeacons <= 0)
	{
		g_BeaconTimer = INVALID_HANDLE; // TODO: Remove this because it doesn't make sense?
		return Plugin_Stop;
	}
	static iTimerCount = 1;
	if (iTimerCount > 99999)
	{
		iTimerCount = 1;
	}
	iTimerCount++;
	
	if (gShadow_LR_HelpBeams)
	{
		for (new LRindex = 0; LRindex < GetArraySize(gH_DArray_LR_Partners); LRindex++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, LRindex, _:Block_LRType);
			//new laserBeamSetting = GetArrayCell(gH_DArray_LR_Partners, LRindex, 10);
			new laserBeamSetting = -1;
			if (type != LR_Rebel && laserBeamSetting != 0)
			{
				if (laserBeamSetting > 0)
				{
					//SetArrayCell(gH_DArray_LR_Partners, LRindex, --laserBeamSetting, 10);
				}
				
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, LRindex, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, LRindex, _:Block_Guard);
				
				new clients[2];
				clients[0] = LR_Player_Prisoner;
				clients[1] = LR_Player_Guard;
				
				// setup beam
				decl Float:Prisoner_Pos[3], Float:Guard_Pos[3], Float:distance;
				GetClientEyePosition(LR_Player_Prisoner, Prisoner_Pos);
				Prisoner_Pos[2] -= 40.0;
				GetClientEyePosition(LR_Player_Guard, Guard_Pos);
				Guard_Pos[2] -= 40.0;
				distance = GetVectorDistance(Prisoner_Pos, Guard_Pos);
				if (distance < 340.0)
				{
					//SetArrayCell(gH_DArray_LR_Partners, LRindex, 0, 10);
				}
				TE_SetupBeamPoints(Prisoner_Pos, Guard_Pos, LaserSprite, LaserHalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, greyColor, 255);			
				TE_Send(clients, 2);
				TE_SetupBeamPoints(Guard_Pos, Prisoner_Pos, LaserSprite, LaserHalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, greyColor, 255);			
				TE_Send(clients, 2);
			}
		}
	}
	new modTime = RoundToCeil(10.0 * gShadow_LR_Beacon_Interval);
	if ((iTimerCount % modTime) == 0)
	{
		new iEntityIndex;
		for (new idx = 0; idx < iNumOfBeacons; idx++)
		{
			iEntityIndex = GetArrayCell(gH_DArray_Beacons, idx);
			if (IsValidEntity(iEntityIndex))
			{
				decl Float:f_Origin[3];
				GetEntPropVector(iEntityIndex, Prop_Data, "m_vecOrigin", f_Origin);
				f_Origin[2] += 10.0;
				TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 15, 0.5, 5.0, 0.0, greyColor, 10, 0);
				TE_SendToAll();
				// check if it's a weapon or player
				if (iEntityIndex < MaxClients+1)
				{
					new team = GetClientTeam(iEntityIndex);
					if (team == CS_TEAM_T)
					{
						TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, redColor, 10, 0);
						TE_SendToAll();
					}
					else if (team == CS_TEAM_CT)
					{
						TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
						TE_SendToAll();
					}
				}
				else
				{
					TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, yellowColor, 10, 0);
					TE_SendToAll();
				}
				EmitAmbientSound(gShadow_LR_Beacon_Sound, f_Origin, iEntityIndex, SNDLEVEL_RAIDSIREN);	
			}
			else
			{
				RemoveFromArray(gH_DArray_Beacons, idx);
			}
		}
	}
	
	return Plugin_Continue;
}

AddBeacon(entityIndex)
{
	if (IsValidEntity(entityIndex))
	{
		PushArrayCell(gH_DArray_Beacons, entityIndex);
	}
	if (g_BeaconTimer == INVALID_HANDLE)
	{
		g_BeaconTimer = CreateTimer(0.1, Timer_Beacon, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
	}
}

RemoveBeacon(entityIndex)
{
	new iBeaconIndex = FindValueInArray(gH_DArray_Beacons, entityIndex);
	if (iBeaconIndex != -1)
	{
		RemoveFromArray(gH_DArray_Beacons, iBeaconIndex);
	}
}

public OnEntityCreated(entity, const String:classname[])
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	new bool:bIsDodgeball = false;
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_Dodgeball)
			{
				bIsDodgeball = true;
			}
		}
	}
	if (bIsDodgeball && StrEqual(classname, "flashbang_projectile"))
	{
		SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
	}
}

public OnEntitySpawned(entity)
{
	new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
			new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
			
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				CreateTimer(0.0, Timer_RemoveThinkTick, entity, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action:Timer_RemoveThinkTick(Handle:timer, any:entity)
{
	SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	CreateTimer(gShadow_LR_Dodgeball_SpawnTime, Timer_RemoveFlashbang, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_RemoveFlashbang(Handle:timer, any:entity)
{
	if (IsValidEntity(entity))
	{
		new client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		AcceptEntityInput(entity, "Kill");
		
		if (IsClientInGame(client) && IsPlayerAlive(client) && Local_IsClientInLR(client))
		{
			new flash = CreateEntityByName("weapon_flashbang");
			DispatchSpawn(flash);
			EquipPlayerWeapon(client, flash);		
		}
	}
}

public Action:Timer_Countdown(Handle:timer)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize == 0)
	{
		g_CountdownTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	new bool:bCountdownUsed = false;
	
	for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
		
		if (type != LR_Race && type != LR_NoScope && type != LR_JumpContest)
		{
			continue;
		}
		
		new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
		new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
		new countdown = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
		if (countdown > 0)
		{
			bCountdownUsed = true;
			PrintCenterText(LR_Player_Prisoner, "LR begins in %i...", countdown);
			PrintCenterText(LR_Player_Guard, "LR begins in %i...", countdown);
			SetArrayCell(gH_DArray_LR_Partners, idx, --countdown, _:Block_Global1);		
		}
		else if (countdown == 0)
		{
			bCountdownUsed = true;
			SetArrayCell(gH_DArray_LR_Partners, idx, --countdown, _:Block_Global1);	
			switch (type)
			{
				case LR_Race:
				{
					SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_WALK);
					SetEntityMoveType(LR_Player_Guard, MOVETYPE_WALK);
					
					// make timer to check the race winner
					if (g_RaceTimer == INVALID_HANDLE)
					{
						g_RaceTimer = CreateTimer(0.1, Timer_Race, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}			
				}
				case LR_NoScope:
				{
					// grab weapon choice
					new NoScopeWeapon:NS_Selection;
					NS_Selection = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);					
					new NSW_Prisoner, NSW_Guard;
					switch (NS_Selection)
					{
						case NSW_AWP:
						{
							NSW_Prisoner = CreateEntityByName("weapon_awp");
							NSW_Guard = CreateEntityByName("weapon_awp");
						}
						case NSW_Scout:
						{
							NSW_Prisoner = CreateEntityByName("weapon_scout");
							NSW_Guard = CreateEntityByName("weapon_scout");
						}
						case NSW_SG550:
						{
							NSW_Prisoner = CreateEntityByName("weapon_sg550");
							NSW_Guard = CreateEntityByName("weapon_sg550");
						}
						case NSW_G3SG1:
						{
							NSW_Prisoner = CreateEntityByName("weapon_g3sg1");
							NSW_Guard = CreateEntityByName("weapon_g3sg1");
						}
						default:
						{
							LogError("hit default NS");
							NSW_Prisoner = CreateEntityByName("weapon_scout");
							NSW_Guard = CreateEntityByName("weapon_scout");
						}
					}
					
					DispatchSpawn(NSW_Prisoner);
					DispatchSpawn(NSW_Guard);
					EquipPlayerWeapon(LR_Player_Prisoner, NSW_Prisoner);
					EquipPlayerWeapon(LR_Player_Guard, NSW_Guard);
					SetEntData(NSW_Prisoner, g_Offset_Clip1, 99);
					SetEntData(NSW_Guard, g_Offset_Clip1, 99);		
					
					if ((strlen(gShadow_LR_NoScope_Sound) > 0) && !StrEqual(gShadow_LR_NoScope_Sound, "-1"))
					{
						EmitSoundToAll(gShadow_LR_NoScope_Sound);
					}
				}
				case LR_JumpContest:
				{
					CreateTimer(13.0, Timer_JumpContestOver, _, TIMER_FLAG_NO_MAPCHANGE);			
				}
			}
		}
	}
	if (bCountdownUsed == false)
	{
		g_CountdownTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:Timer_Race(Handle:timer)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	new bool:bIsRace = false;
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_Race)
			{
				bIsRace = true;
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				decl Float:LR_Prisoner_Position[3], Float:LR_Guard_Position[3], Float:f_EndLocation[3];
				new Handle:PositionPack = GetArrayCell(gH_DArray_LR_Partners, idx, 9);
				ResetPack(PositionPack);
				f_EndLocation[0] = ReadPackFloat(PositionPack);
				f_EndLocation[1] = ReadPackFloat(PositionPack);
				f_EndLocation[2] = ReadPackFloat(PositionPack);
				GetClientAbsOrigin(LR_Player_Prisoner, LR_Prisoner_Position);
				GetClientAbsOrigin(LR_Player_Guard, LR_Guard_Position);
				// check how close they are to the end point
				decl Float:f_PrisonerDistance, Float:f_GuardDistance;
				f_PrisonerDistance = GetVectorDistance(LR_Prisoner_Position, f_EndLocation, false);
				f_GuardDistance = GetVectorDistance(LR_Guard_Position, f_EndLocation, false);
				
				if (f_PrisonerDistance < Float:75.0 || f_GuardDistance < Float:75.0)
				{
					if (f_PrisonerDistance < f_GuardDistance)
					{
						ForcePlayerSuicide(LR_Player_Guard);
						PrintToChatAll(CHAT_BANNER, "Race Won", LR_Player_Prisoner);
					}
					else
					{
						ForcePlayerSuicide(LR_Player_Prisoner);
						PrintToChatAll(CHAT_BANNER, "Race Won", LR_Player_Guard);
					}
				}
				
				// update end location beam
				TE_SetupBeamRingPoint(f_EndLocation, 100.0, 110.0, BeamSprite, HaloSprite, 0, 15, 0.2, 7.0, 1.0, greenColor, 1, 0);
				TE_SendToAll();					
			}
		}
	}
	if (!bIsRace)
	{
		g_RaceTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public RPSmenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		// find out which LR this is for
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_RockPaperScissors)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);	
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					new RPS_Prisoner_Choice = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
					new RPS_Guard_Choice = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
					
					if (client == LR_Player_Prisoner)
					{
						RPS_Prisoner_Choice = param2;
						SetArrayCell(gH_DArray_LR_Partners, idx, RPS_Prisoner_Choice, 5);
					}
					else if (client == LR_Player_Guard)
					{
						RPS_Guard_Choice = param2;
						SetArrayCell(gH_DArray_LR_Partners, idx, RPS_Guard_Choice, _:Block_Global2);
					}
					
					if ((RPS_Guard_Choice != -1) && (RPS_Prisoner_Choice != -1))
					{
						// decide who wins -- rock 0 paper 1 scissors 2
						decl String:RPSr[64], String:RPSp[64], String:RPSs[64], String:RPSc1[64], String:RPSc2[64];
						Format(RPSr, sizeof(RPSr), "%T", "Rock", LANG_SERVER);
						Format(RPSp, sizeof(RPSp), "%T", "Paper", LANG_SERVER);
						Format(RPSs, sizeof(RPSs), "%T", "Scissors", LANG_SERVER);
		
						switch (RPS_Prisoner_Choice)
						{
							case 0:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSr);
							}
							case 1:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSp);
							}
							case 2:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSs);
							}
						}
						switch (RPS_Guard_Choice)
						{
							case 0:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSr);
							}
							case 1:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSp);
							}
							case 2:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSs);
							}
						}
		
						if (RPS_Prisoner_Choice == RPS_Guard_Choice) // tie
						{
							if (client == LR_Player_Prisoner)
							{
								if (gShadow_SendGlobalMsgs)
								{
									PrintToChatAll(CHAT_BANNER, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
								}
								else
								{
									PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
									PrintToChat(LR_Player_Guard, CHAT_BANNER, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
								}
							}
							else
							{
								if (gShadow_SendGlobalMsgs)
								{
									PrintToChatAll(CHAT_BANNER, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
								}
								else
								{
									PrintToChat(LR_Player_Guard, CHAT_BANNER, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
									PrintToChat(LR_Player_Prisoner, CHAT_BANNER, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
								}
							}
							
							// redo menu
							SetArrayCell(gH_DArray_LR_Partners, idx, -1, _:Block_Global1);
							SetArrayCell(gH_DArray_LR_Partners, idx, -1, _:Block_Global2);
							new Handle:rpsmenu1 = CreateMenu(RPSmenuHandler);
							SetMenuTitle(rpsmenu1, "%T", "Rock Paper Scissors", LR_Player_Prisoner);
							SetArrayCell(gH_DArray_LR_Partners, idx, rpsmenu1, _:Block_PrisonerData);
				
							decl String:r1[32], String:p1[64], String:s1[64];
							Format(r1, sizeof(r1), "%T", "Rock", LR_Player_Prisoner);
							Format(p1, sizeof(p1), "%T", "Paper", LR_Player_Prisoner);
							Format(s1, sizeof(s1), "%T", "Scissors", LR_Player_Prisoner);
							AddMenuItem(rpsmenu1, "0", r1);
							AddMenuItem(rpsmenu1, "1", p1);
							AddMenuItem(rpsmenu1, "2", s1);
				
							SetMenuExitButton(rpsmenu1, true);
							DisplayMenu(rpsmenu1, LR_Player_Prisoner, 20);
				
							new Handle:rpsmenu2 = CreateMenu(RPSmenuHandler);
							SetMenuTitle(rpsmenu2, "%T", "Rock Paper Scissors", LR_Player_Guard);
							SetArrayCell(gH_DArray_LR_Partners, idx, rpsmenu2, _:Block_GuardData);
				
							decl String:r2[32], String:p2[64], String:s2[64];
							Format(r2, sizeof(r2), "%T", "Rock", LR_Player_Guard);
							Format(p2, sizeof(p2), "%T", "Paper", LR_Player_Guard);
							Format(s2, sizeof(s2), "%T", "Scissors", LR_Player_Guard);
							AddMenuItem(rpsmenu2, "0", r2);
							AddMenuItem(rpsmenu2, "1", p2);
							AddMenuItem(rpsmenu2, "2", s2);
				
							SetMenuExitButton(rpsmenu2, true);
							DisplayMenu(rpsmenu2, LR_Player_Guard, 20);
						}
						// if THIS player has won
						else if ( (RPS_Guard_Choice == 0 && RPS_Prisoner_Choice == 2) || (RPS_Guard_Choice == 1 && RPS_Prisoner_Choice == 0) || (RPS_Guard_Choice == 2 && RPS_Prisoner_Choice == 1) )
						{
							if (client == LR_Player_Prisoner)
							{
								ForcePlayerSuicide(LR_Player_Guard);
								PrintToChatAll(CHAT_BANNER, "LR RPS Done", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1, LR_Player_Prisoner);
							}
							else
							{
								ForcePlayerSuicide(LR_Player_Prisoner);
								PrintToChatAll(CHAT_BANNER, "LR RPS Done", LR_Player_Prisoner, RPSc1, LR_Player_Guard, RPSc2, LR_Player_Guard);
							}
						}
						// otherwise THIS player has lost
						else
						{
							if (client == LR_Player_Guard)
							{
								ForcePlayerSuicide(LR_Player_Guard);
								PrintToChatAll(CHAT_BANNER, "LR RPS Done", LR_Player_Prisoner, RPSc1, LR_Player_Guard, RPSc2, LR_Player_Prisoner);
							}
							else
							{
								ForcePlayerSuicide(LR_Player_Prisoner);
								PrintToChatAll(CHAT_BANNER, "LR RPS Done", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1, LR_Player_Guard);
							}
						}				
					}				
				}		
			}			
		}

	}
	else if (action == MenuAction_Cancel)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_RockPaperScissors)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);	
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					if (IsClientInGame(client) && IsPlayerAlive(client))
					{
						ForcePlayerSuicide(client);
						PrintToChatAll(CHAT_BANNER, "LR RPS No Answer", client);
					}
				}	
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:Timer_DodgeballCheckCheaters(Handle:timer)
{
	// is there still a gun toss LR going on?
	new bool:bDodgeball = false;
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_Dodgeball)
			{
				bDodgeball = true;
				
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				if (IsValidEntity(LR_Player_Prisoner) && (GetClientHealth(LR_Player_Prisoner) > 1))
				{
					SetEntityHealth(LR_Player_Prisoner, 1);
				}
				if (IsValidEntity(LR_Player_Guard) && (GetClientHealth(LR_Player_Guard) > 1))
				{
					SetEntityHealth(LR_Player_Guard, 1);
				}
			}
		}
	}
	
	if (!bDodgeball)
	{
		g_DodgeballTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:Timer_HotPotatoDone(Handle:timer, any:HotPotato_ID)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			new thisHotPotato_ID = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global3);			
			if ((type == LR_HotPotato) && (HotPotato_ID == thisHotPotato_ID))
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				new HPloser = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
				new HPwinner = ((HPloser == LR_Player_Prisoner) ? LR_Player_Guard : LR_Player_Prisoner);
				
				ForcePlayerSuicide(HPloser);
				PrintToChatAll(CHAT_BANNER, "HP Win", HPwinner, HPloser);
				
				if (gShadow_LR_HotPotato_Mode != 2)
				{
					SetEntPropFloat(HPwinner, Prop_Data, "m_flLaggedMovementValue", 1.0);
				}
			}
		}
	}
	return Plugin_Stop;
}

public Action:Timer_ChickenFight(Handle:timer)
{
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	new bool:bIsChickenFight = false;
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_ChickenFight)
			{
				bIsChickenFight = true;
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				new p1EntityBelow = GetEntDataEnt2(LR_Player_Prisoner, g_Offset_GroundEnt);
				new p2EntityBelow = GetEntDataEnt2(LR_Player_Guard, g_Offset_GroundEnt);
				
				if (p1EntityBelow == LR_Player_Guard)
				{
					if (gShadow_LR_ChickenFight_Slay)
					{
						PrintToChatAll(CHAT_BANNER, "Chicken Fight Win And Slay", LR_Player_Prisoner, LR_Player_Guard);
						ForcePlayerSuicide(LR_Player_Guard);		
					}
					else
					{
						PrintToChatAll(CHAT_BANNER, "Chicken Fight Win", LR_Player_Prisoner);
						PrintToChat(LR_Player_Prisoner, "Chicken Fight Kill Loser", LR_Player_Guard);
						
						GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
						
						SetEntityRenderColor(LR_Player_Guard, gShadow_LR_ChickenFight_C_Red, gShadow_LR_ChickenFight_C_Green,
							gShadow_LR_ChickenFight_C_Blue, 255);
					}
				}
				else if (p2EntityBelow == LR_Player_Prisoner)
				{
					if (gShadow_LR_ChickenFight_Slay)
					{
						PrintToChatAll(CHAT_BANNER, "Chicken Fight Win And Slay", LR_Player_Guard, LR_Player_Prisoner);
						ForcePlayerSuicide(LR_Player_Prisoner);
					}
					else
					{
						PrintToChatAll(CHAT_BANNER, "Chicken Fight Win", LR_Player_Guard);
						PrintToChat(LR_Player_Guard, "Chicken Fight Kill Loser", LR_Player_Prisoner);
						
						GivePlayerItem(LR_Player_Guard, "weapon_knife");
						
						SetEntityRenderColor(LR_Player_Prisoner, gShadow_LR_ChickenFight_C_Red, gShadow_LR_ChickenFight_C_Green,
							gShadow_LR_ChickenFight_C_Blue, 255);
					}
				}
			}
		}
	}
	if (!bIsChickenFight)
	{
		g_ChickenFightTimer = INVALID_HANDLE;
		return Plugin_Stop;	
	}
	
	return Plugin_Continue;
}

// Gun Toss distance meter and BeamSprite application
public Action:Timer_GunToss(Handle:timer)
{
	// is there still a gun toss LR going on?
	new iNumGunTosses = 0;
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
			if (type == LR_GunToss)
			{
				iNumGunTosses++;
				
				new GTp1done, GTp2done, GTp1dropped, GTp2dropped, GTdeagle1, GTdeagle2;
				GTp1done = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global3);
				GTp2done = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global4);
				GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
				GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global2);
				GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_PrisonerData));
				GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_GuardData));
				decl Float:GTdeagle1pos[3], Float:GTdeagle2pos[3];
				decl Float:GTdeagle1lastpos[3], Float:GTdeagle2lastpos[3];
				new Handle:PositionDataPack = Handle:GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_DataPackHandle);
				ResetPack(PositionDataPack);
				GTdeagle1lastpos[0] = ReadPackFloat(PositionDataPack);
				GTdeagle1lastpos[1] = ReadPackFloat(PositionDataPack);
				GTdeagle1lastpos[2] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[0] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[1] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[2] = ReadPackFloat(PositionDataPack);
				decl Float:GTp1droppos[3], Float:GTp2droppos[3];
				GTp1droppos[0] = ReadPackFloat(PositionDataPack);
				GTp1droppos[1] = ReadPackFloat(PositionDataPack);
				GTp1droppos[2] = ReadPackFloat(PositionDataPack);
				GTp2droppos[0] = ReadPackFloat(PositionDataPack);
				GTp2droppos[1] = ReadPackFloat(PositionDataPack);
				GTp2droppos[2] = ReadPackFloat(PositionDataPack);				
			
				if (GTp1dropped && !GTp1done)
				{					
					GetEntPropVector(GTdeagle1, Prop_Data, "m_vecOrigin", GTdeagle1pos);
					if (GetVectorDistance(GTdeagle1lastpos, GTdeagle1pos) < 3.00)
					{
						GTp1done = true;
						SetArrayCell(gH_DArray_LR_Partners, idx, GTp1done, _:Block_Global3);
					}
					else
					{
						GTdeagle1lastpos[0] = GTdeagle1pos[0];
						GTdeagle1lastpos[1] = GTdeagle1pos[1];
						GTdeagle1lastpos[2] = GTdeagle1pos[2];
						SetPackPosition(PositionDataPack, 0);
						WritePackFloat(PositionDataPack, GTdeagle1lastpos[0]);
						WritePackFloat(PositionDataPack, GTdeagle1lastpos[1]);
						WritePackFloat(PositionDataPack, GTdeagle1lastpos[2]);
					}
				}
				else if (GTp1dropped && GTp1done)
				{
					switch (gShadow_LR_GunToss_MarkerMode)
					{
						case 0:
						{
							decl Float:beamStartP1[3];		
							new Float:f_SubtractVec[3] = {0.0, 0.0, -30.0};
							MakeVectorFromPoints(f_SubtractVec, GTdeagle1lastpos, beamStartP1);
							TE_SetupBeamPoints(beamStartP1, GTdeagle1lastpos, BeamSprite, 0, 0, 0, 0.1, 10.0, 10.0, 7, 0.0, redColor, 0);							
						}
						case 1:
						{
							TE_SetupBeamPoints(GTp1droppos, GTdeagle1lastpos, BeamSprite, 0, 0, 0, 0.1, 10.0, 10.0, 7, 0.0, redColor, 0);
						}
					}				
					TE_SendToAll();				
				}
				
				if (GTp2dropped && !GTp2done)
				{					
					GetEntPropVector(GTdeagle2, Prop_Data, "m_vecOrigin", GTdeagle2pos);
					if (GetVectorDistance(GTdeagle2lastpos, GTdeagle2pos) < 3.00)
					{
						GTp2done = true;
						SetArrayCell(gH_DArray_LR_Partners, idx, GTp2done, _:Block_Global4);						
					}
					else
					{
						GTdeagle2lastpos[0] = GTdeagle2pos[0];
						GTdeagle2lastpos[1] = GTdeagle2pos[1];
						GTdeagle2lastpos[2] = GTdeagle2pos[2];

						SetPackPosition(PositionDataPack, 24);
						WritePackFloat(PositionDataPack, GTdeagle2lastpos[0]);
						WritePackFloat(PositionDataPack, GTdeagle2lastpos[1]);
						WritePackFloat(PositionDataPack, GTdeagle2lastpos[2]);
					}
				}
				else if (GTp2dropped && GTp2done)
				{
					switch (gShadow_LR_GunToss_MarkerMode)
					{
						case 0:
						{
							decl Float:beamStartP2[3];
							new Float:f_SubtractVec[3] = {0.0, 0.0, -30.0};
							MakeVectorFromPoints(f_SubtractVec, GTdeagle2lastpos, beamStartP2);
							TE_SetupBeamPoints(beamStartP2, GTdeagle2lastpos, BeamSprite, 0, 0, 0, 0.1, 10.0, 10.0, 7, 0.0, blueColor, 0);
						}
						case 1:
						{
							TE_SetupBeamPoints(GTp2droppos, GTdeagle2lastpos, BeamSprite, 0, 0, 0, 0.1, 10.0, 10.0, 7, 0.0, blueColor, 0);
						}
					}
					
					TE_SendToAll();				
				}		
			}
		}
	}
	if (iNumGunTosses <= 0)
	{
		g_GunTossTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

DecideRebelsFate(rebeller, LRIndex, victim=0)
{
	new iClientWeapon = GetEntDataEnt2(rebeller, g_Offset_ActiveWeapon);
	decl String:sWeaponName[32];
	if (IsValidEntity(iClientWeapon))
	{
		GetEdictClassname(iClientWeapon, sWeaponName, sizeof(sWeaponName));
		ReplaceString(sWeaponName, sizeof(sWeaponName), "weapon_", "");
	}
	else
	{
		Format(sWeaponName, sizeof(sWeaponName), "unknown");
	}
	
	// grab the current LR and override default rebel action if requested (backward compatibility)
	new rebelAction;	
	new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, LRIndex, _:Block_LRType);
	switch (type)
	{
		case LR_KnifeFight:
		{
			rebelAction = gShadow_LR_KnifeFight_Rebel+1;
		}
		case LR_ChickenFight:
		{
			rebelAction = gShadow_LR_ChickenFight_Rebel+1;
		}
		case LR_HotPotato:
		{
			rebelAction = gShadow_LR_HotPotato_Rebel+1;
		}		
		default:
		{
			rebelAction = gShadow_RebelAction;
		}
	}
	
	switch (rebelAction)
	{
		case 0:
		{
			// take no action here (for now)
		}
		case 1:
		{
			if (IsPlayerAlive(rebeller))
			{
				StripAllWeapons(rebeller);
			}
			CleanupLastRequest(rebeller, LRIndex);
			RemoveFromArray(gH_DArray_LR_Partners, LRIndex);
			if (victim == 0)
			{
				PrintToChatAll(CHAT_BANNER, "LR Interference Abort - No Victim", rebeller, sWeaponName);
			}
			else if (victim == -1)
			{
				PrintToChatAll(CHAT_BANNER, "LR Cheating Abort", rebeller);
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "LR Interference Abort", rebeller, victim, sWeaponName);	
			}	
		}
		case 2:
		{
			if (IsPlayerAlive(rebeller))
			{
				ForcePlayerSuicide(rebeller);
			}
			if (victim == 0)
			{
				PrintToChatAll(CHAT_BANNER, "LR Interference Slay - No Victim", rebeller, sWeaponName);
			}
			else if (victim == -1)
			{
				PrintToChatAll(CHAT_BANNER, "LR Cheating Slay", rebeller);
			}
			else
			{
				PrintToChatAll(CHAT_BANNER, "LR Interference Slay", rebeller, victim, sWeaponName);	
			}		
		}
	}
}

public Action:Timer_BeerGoggles(Handle:timer)
{
	static timerCount = 1;
	timerCount++;
	if (timerCount > 160)
	{
		timerCount = 1;
	}
	
	decl Float:vecPunch[3];
	new Float:drunkMultiplier = float(gShadow_LR_KnifeFight_Drunk);
	
	new iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize == 0)
	{
		g_BeerGogglesTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	for (new idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		new LastRequest:type = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_LRType);
		if (type == LR_KnifeFight)
		{
			new KnifeType:KnifeChoice = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Global1);
			if (KnifeChoice == Knife_Drunk)
			{
				new LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Prisoner);
				new LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, _:Block_Guard);
				
				switch (timerCount % 4)
				{
					case 0:
					{
						vecPunch[0] = drunkMultiplier*5.0;
						vecPunch[1] = drunkMultiplier*5.0;
						vecPunch[2] = drunkMultiplier*-5.0;
					}
					case 1:
					{
						vecPunch[0] = drunkMultiplier*-5.0;
						vecPunch[1] = drunkMultiplier*-5.0;
						vecPunch[2] = drunkMultiplier*5.0;
					}
					case 2:
					{
						vecPunch[0] = drunkMultiplier*5.0;
						vecPunch[1] = drunkMultiplier*-5.0;
						vecPunch[2] = drunkMultiplier*5.0;
					}
					case 3:
					{
						vecPunch[0] = drunkMultiplier*-5.0;
						vecPunch[1] = drunkMultiplier*5.0;
						vecPunch[2] = drunkMultiplier*-5.0;
					}					
				}
				SetEntDataVector(LR_Player_Prisoner, g_Offset_PunchAngle, vecPunch, true);	
				SetEntDataVector(LR_Player_Guard, g_Offset_PunchAngle, vecPunch, true);
			}
		}
	}
	return Plugin_Continue;
}

UpdatePlayerCounts(&Prisoners, &Guards, &iNumGuardsAvailable)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				Prisoners++;
			}
			else if (GetClientTeam(i) == CS_TEAM_CT)
			{
				Guards++;
				if (!g_bInLastRequest[i])
				{
					iNumGuardsAvailable++;
				}
			}
		}
	}
}
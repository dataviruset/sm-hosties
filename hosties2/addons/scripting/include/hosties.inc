// Hosties Include

// Double include protection
#if defined _Hosties_Included_
	#endinput
#endif
#define _Hosties_Included_

enum MediaType
{
	type_Generic = 0,
	type_Sound,
	type_Material,
	type_Model,
	type_Decal
};

stock ShowOverlayToClient(client, const String:overlaypath[])
{
	ClientCommand(client, "r_screenoverlay \"%s\"", overlaypath);
}

stock ShowOverlayToAll(const String:overlaypath[])
{
	// x = client index.
	for (new x = 1; x <= MaxClients; x++)
	{
		// If client isn't in-game, then stop.
		if (IsClientInGame(x) && !IsFakeClient(x))
		{
			ShowOverlayToClient(x, overlaypath);
		}
	}
}

stock StripAllWeapons(client)
{
	new wepIdx;
	for (new i; i < 4; i++)
	{
		if ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			AcceptEntityInput(wepIdx, "Kill");
		}
	}
}

stock BlockEntity(client, cachedOffset)
{
	SetEntData(client, cachedOffset, 5, 4, true);
}

stock UnblockEntity(client, cachedOffset)
{
	SetEntData(client, cachedOffset, 2, 4, true);
}

stock BlockClientAll()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) && IsPlayerAlive(i) )
		{
			BlockEntity(i);
		}
	}
}

stock UnblockClientAll()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if ( IsClientInGame(i) && IsPlayerAlive(i) )
		{
			UnblockEntity(i);
		}
	}
}

stock MutePlayer(client)
{
	SetClientListeningFlags(client, VOICE_MUTED);
}

stock UnmutePlayer(client)
{
	SetClientListeningFlags(client, VOICE_NORMAL);
}

stock MuteTs()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if ( (IsClientInGame(i)) && (IsPlayerAlive(i)) ) // if player is in game and alive
		{
			// if player is a terrorist
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				MutePlayer(i);
			}
		}
	}
}

stock UnmuteAlive()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if ( (IsClientInGame(i)) && (IsPlayerAlive(i)) ) // if player is in game and alive
		{
			UnmutePlayer(i);
		}
	}
}

stock UnmuteAll()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i)) // if player is in game
		{
			UnmutePlayer(i);
		}
	}
}

stock CacheTheFile(const String:path[], MediaType:filetype)
{
	decl String:sDownloadPath[PLATFORM_MAX_PATH];
	switch (filetype)
	{
		case type_Sound:
		{
			PrecacheSound(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "sound/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		case type_Decal, type_Material:
		{
			PrecacheDecal(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "materials/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		case type_Model:
		{
			PrecacheModel(path, true);
			Format(sDownloadPath, PLATFORM_MAX_PATH, "models/%s", path);
			AddFileToDownloadsTable(sDownloadPath);
		}
		default:
		{
			PrecacheGeneric(path, true);
			AddFileToDownloadsTable(path);			
		}
	}
}

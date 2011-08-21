
[CS:S] SM Hosties (v2.0.0)
by: databomb & dataviruset

Description:

This is a re-write of SM_Hosties v1.x from dataviruset.  This allows support for multiple LRs occuring simultaneously as well as a plethora of additional last request games and new cvars for the most customizable Hosties yet.   It opens up a new API for other plugin developers to ask questions like if a player is a rebel as well as opens up the possibility to add 3rd party LRs for each server independent of the Hosties plugin.

Features:

34 Last Request Games:
Shotgun Wars
Drunken Boxing
Most Jumps
Farthest Jump
Race
Russian Roulette
Rebel
Inch of Death
Low-Grav Knife Fight
Hi-Speed Knife Fight
Third Person Knife Fight
Drugged Knife Fight
Vintage Knife Fight
Rock Paper Scissors
NoScope with any scoped weapon (4 choices)
Dodgeball
Hot Potato
Chicken Fight
Shot4Shot with any pistol (6 choices)
Mag4Mag with any pistol (6 choices)
Gun Toss

Hosties API:

For integration there are two natives provided: IsClientRebel and IsClientInLastRequest.
For adding custom LRs there are three natives provided: AddLastRequestToList, RemoveLastRequestFromList, and ProcessAllLastRequests.

New Cvars:

sm_hosties_lr_damage - Enables that players can not attack players in LR and players in LR can not attack players outside LR: 0 - disable, 1 - enable
sm_hosties_startweapons_on - Turns on giving weapons to CT & T at spawn
sm_hosties_lr_beams - Displays connecting beams between LR contestants
sm_lr_jumpcontest_on - Enables the LR
sm_lr_mag4mag_on - Enables the LR
sm_lr_race_on - Enables the LR
sm_lr_rebel_on - Enables the LR
sm_lr_russianroulette_on - Enables the LR
sm_lr_rebel_action - Decides what to do with those who rebel/interfere during an LR. 1 - Abort, 2 - Slay.
sm_lr_rebel_color - Turns on coloring rebels
sm_lr_send_global_msgs - Specifies if non-death related LR messages are sent to everyone or just the active participants in that LR. 0: participants, 1: everyone
sm_hosties_roundend_overlay_ct_vmt - Specifies the corresponding VMT to the overlay_ct VTF
sm_hosties_roundend_overlay_t_vmt - Specifies the corresponding VMT to the overlay_t VTF

General Chat Commands:
!rules
!lastrequest (also: !lr)
!checkplayers

Admin Commands:
!stoplr (also: !abortlr and !cancellr): Requires slay admin flag and will abort any and all active last requests.

Requirements:
SDKHooks v2

Installation:

Copy all files in the hosties\ directory to addons/sourcemod/scripting/hosties/
Copy the translation file to addons/sourcemod/translations/
Copy the hosties.inc and lastrequest.inc files to addons/sourcemod/scripting/include/
Copy sample-LR.sp and sm_hosties.sp to addons/sourcemod/scripting/
Compile sm_hosties and sample-LR and move SMX files to addons/sourcemod/plugins/

Upgrade Instructions:

Rename your original sm_hosties.cfg in cfg/sourcemod/ to sm_hosties.backup
Let the Hosties 2 plugin start for the first time and create the new cfg file.
Look at the sm_hosties.backup and merge your original settings with the new one.

Changes to Existing Cvars:

A few of the existing cvar settings in SM_Hosties v1.x have changed slighlty in v2.

sm_hosties_lr_ts_max: This now controls the number of Ts allowed to have LRs going at the same time.
sm_hosties_mute_immune: This now uses flag CHARACTERS instead of names. (E.g. use "z" instead of "root".)
sm_hosties_lr_hp_teleport: Added new option (2)- teleport and freeze players.
sm_hosties_ct_start and sm_hosties_t_start should now include "weapon_knife" in the list.
sm_hosties_lr_s4s_shot_taken now applies to Mag4Mag as well as Shot4Shot.
sm_hosties_roundend_overlay_ct & sm_hosties_roundend_overlay_t now must specify the VTF file only
sm_hosties_lr_ns_delay is now an integer instead of a float.
sm_hosties_lr_s4s_dblsht_action now determines if sm_lr_rebel_action is followed or not (0 - no punishment, 1 - follow rebel_action)
sm_hosties_lr_s4s_shot_taken now includes Mag4Mag announcement when magazines are emptied

Special Thanks:

dataviruset - Making the huge investment to port Hosties to SourceMod!
psychonic - This guy gets credit whenever I release a plugin because invariably he will have provided me with vital information or advice :-)
johan123jo - The blocking LR damage code and various bug fixes
MomemtumMori - Hosting the SVN for Hosties v2
Berni - For making SMLIB and helping with hull traces
dvander - Pointing out some architectural flaws with the API
Crosshair - 'Inspiration'

The servers willing to run beta versions of this (for all the problems you never had to deal with, thank them):
Groger, OnlyFriends
Silence, XenoGamers

Help The Cause:

Hosties v2 is over 5,000 lines of code and growing.  My server has been a target of DDoS 
attacks almost since beginning and without the continued support from my community, and 
now hopefully from yourselves, the server would be shutdown and active 
development would cease.  There are a couple ways you could help:  1) Consider thinking 
of an idea for a private last request especially for your server and ask databomb to make 
it for you. 2) Consider donating to Vintage Jailbreak to support the costs. (Please 
include that your donation is for Hosties. Half of all donations will go to dataviruset 
and his community while half will go to databomb and his community.)  3) Consider 
donating to Allied Modders for hosting all of this!

Translations:

The new translations file, lastrequest.phrases.txt is in need of translators! Send the
translation files to dataviruset or myself and we will make sure they're included in 
the next release.

Report bugs to databomb aka Starbuck {CO} through AM forums, Steam, or VintageJailbreak@gmail.com

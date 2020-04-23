# Show Damage
Will show the damage on the Hint (HUD).

- Will show you the damage, armor and the part of the body;
- For Molotov and Grenade you will get the total victim hurted with of course the damage and armor;
- If you make a double, triple, or whatever kills you will get total victim hurted with of course the damage and armor;
- The time ***(reset)*** between each kill is set by type of weapons(pistols, snipers, rifles...) and this timer can be set with cvars;

## Commands
- `sm_sd` - For the clients preferences;

## Cvars
- `show_damage_sniper_time` - SNIPERS Time Between shots;
- `show_damage_mg_time` - MACHINES GUNS Time Between shots;
- `show_damage_rifle_time` - RIFLES Time Between shots;
- `show_damage_mp_time` - MPS Time Between shots;
- `show_damage_pump_time` - PUMPS Time Between shots;
- `show_damage_pistol_time` - PISTOLS Time Between shots;

If you set a high value time the damage, armor and victim on the HUD will increase. 0.5s between it's enough to get double, triple... kills instant. If you shot the same victim twice it's count like one so don't worry if you set high value time.

## Configs
```
"ShowDamage"
{
	"ShowDamage"
	{

		"ShowDamageAccess"
		{
			"1"															//MOLOTOV
			{
				"flags"			"public"								// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"2"															//GRENADE
			{
				"flags"			"public"								// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"3"															//SNIPERS
			{
				"flags"			"admin"									// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"4"															//MACHINE GUNS
			{
				"flags"			"public"								// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"5"															//RIFLES
			{
				"flags"			"vip"									// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"6"															//PMs
			{
				"flags"			"vip"									// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"7"															//PUMP
			{
				"flags"			"admin"									// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"8"															//PISTOLS
			{
				"flags"			"admin"									// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
				}

			}

			"9"															//OTHERS
			{
				"flags"			"steamid"								// Flag for use the show damage (public, vip, admin, steamid)
				"SteamIDs" 												// Or steamids allowed to use the show damage(can be use with steamid, vip or admin flags)
				{
					"1"	"STEAM_0:1:64012428"
				}

			}

		}
	}
}
```
You can now give access to each type of weapons (pistols, rifles, snipers, etc...)
- ADMIN and/or Steam_ID;
- VIP and/or Steam_ID;
- Steam_ID;
- Public;

## Credits
- [Dr. API](https://forums.alliedmods.net/member.php?u=259137) - Modified from yours [Fork](https://forums.alliedmods.net/showthread.php?t=264427);

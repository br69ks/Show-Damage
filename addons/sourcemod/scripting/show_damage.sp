#pragma semicolon 1 
#pragma newdecls required
#include <sourcemod>
#include <clientprefs>

ArrayList Array_Victim[MAXPLAYERS + 1];

Cookie Cookie_ShowDamage;
Cookie Cookie_ShowDamageType;

Handle Timer_ShowDamage[MAXPLAYERS + 1];

float TimerDamage[MAXPLAYERS + 1];

char S_new_weapon[MAXPLAYERS + 1][64];
char S_old_weapon[MAXPLAYERS + 1][64];

int C_CountVictim[MAXPLAYERS + 1]	= 1;
int C_TotalDamage[MAXPLAYERS + 1];
int C_TotalDamageArmor[MAXPLAYERS + 1];
int C_ShowDamage[MAXPLAYERS + 1];
int C_ShowDamageType[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "[ZK Servidores™] Show Damage HUD",
	author = "Dr. Api, crashzk",
	description = "Show damage",
	version = "1.3",
	url = "https://github.com/zkservidores-clientes"
}

public void OnPluginStart()
{
	LoadTranslations("show_damage.phrases");
	
	HookEvent("player_hurt", Event_PlayerHurt);
	
	RegConsoleCmd("sm_sd", Command_BuildMenuShowDamage, "");
	RegConsoleCmd("sm_showdamage", Command_BuildMenuShowDamage, "");
	
	Cookie_ShowDamage = new Cookie("Cookie_ShowDamage", "Enable/Disable Show Damage", CookieAccess_Private);
	Cookie_ShowDamageType = new Cookie("Cookie_ShowDamageType", "Change Show Damage Type", CookieAccess_Private);
	
	int info;
	SetCookieMenuItem(ShowDamageCookieHandler, info, "Show Damage");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			Array_Victim[i] = new ArrayList(3);
			
			if (AreClientCookiesCached(i))
				OnClientCookiesCached(i);
		}
	}
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			Array_Victim[i].Close();
}

public void OnClientPutInServer(int client)
{
	Array_Victim[client] = new ArrayList(3);
}

public void OnClientDisconnect(int client)
{
	Array_Victim[client].Close();
}

public void OnClientCookiesCached(int client)
{
	char value[16];
	char value2[16];
	
	Cookie_ShowDamage.Get(client, value, sizeof(value));
	Cookie_ShowDamageType.Get(client, value2, sizeof(value2));
	
	if(value[0] == '\0')
	{
		Cookie_ShowDamage.Set(client, "1");
		C_ShowDamage[client] = 1;
	}
	else 
		C_ShowDamage[client] = StringToInt(value);
	
	if(value2[0] == '\0')
	{
		Cookie_ShowDamageType.Set(client, "1");
		C_ShowDamageType[client] = 1;
	}
	else 
		C_ShowDamageType[client] = StringToInt(value2);
}

public Action Command_BuildMenuShowDamage(int client, int args)
{
	BuildMenuShowDamage(client);
}

public void ShowDamageCookieHandler(int client, CookieMenuAction action, any info, char [] buffer, int maxlen)
{
	BuildMenuShowDamage(client);
} 

void BuildMenuShowDamage(int client)
{
	char buffer[64];
	
	Menu menu = new Menu(MenuShowDamageAction);
	
	Format(buffer, sizeof(buffer), "%T", "Menu Title");
	menu.SetTitle(buffer);
	
	Format(buffer, sizeof(buffer), "%T", "Option 1", C_ShowDamage[client] ? "Enabled" : "Disabled");
	menu.AddItem("1", buffer);
	
	Format(buffer, sizeof(buffer), "%T", "Option 2", C_ShowDamageType[client] ? "Center" : "HUD");
	if (C_ShowDamage[client] == 1)
		menu.AddItem("2", buffer);
		
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuShowDamageAction(Menu menu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_End:
		{
			menu.Close();
		}
		
		case MenuAction_Cancel:
		{
			if (item == MenuCancel_ExitBack)
				FakeClientCommand(client, "sm_settings");
		}
		
		case MenuAction_Select:
		{
			
			if (item == 0)
			{
				C_ShowDamage[client] = !C_ShowDamage[client];
				Cookie_ShowDamage.Set(client, C_ShowDamage[client] ? "1" : "0");
			}

			if (item == 1)
			{
				C_ShowDamageType[client] = !C_ShowDamageType[client];
				Cookie_ShowDamageType.Set(client, C_ShowDamageType[client] ? "1" : "0");
			}

			BuildMenuShowDamage(client);
		}
	}
}

public Action Event_PlayerHurt(Event event, char[] name, bool dontBroadcast)
{
	char S_weapon[64];

	int victim 			= GetClientOfUserId(event.GetInt("userid"));
	int attacker 		= GetClientOfUserId(event.GetInt("attacker"));
	int damage_health 	= event.GetInt("dmg_health");	
	int damage_armor 	= event.GetInt("dmg_armor");
	int hitgroup		= event.GetInt("hitgroup");
	int health			= event.GetInt("health");
	event.GetString("weapon", S_weapon, sizeof(S_weapon));
		
	if(!C_ShowDamage[attacker]) 
		return;
		
	if(IsClientInGame(attacker) && IsClientInGame(victim))
	{
		strcopy(S_new_weapon[attacker], 64, S_weapon);
			
		float time;
		
		if (StrEqual(S_weapon, "inferno", false))
			time = FindConVar("inferno_flame_lifetime").FloatValue;
			
		else if (StrEqual(S_weapon, "hegrenade", false))
			time = 1.0;

		else
			time = 0.5;

		float now = GetEngineTime();
		if(now >= TimerDamage[attacker] || !StrEqual(S_new_weapon[attacker], S_old_weapon[attacker], false))
		{
			C_CountVictim[attacker]			= 0;
			TimerDamage[attacker] 			= now + time;
			C_TotalDamage[attacker] 		= 0;
			C_TotalDamageArmor[attacker] 	= 0;
			S_old_weapon[attacker] 			= S_new_weapon[attacker];
			Array_Victim[attacker].Clear();
		}
			
		C_TotalDamage[attacker] 		+= damage_health;
		C_TotalDamageArmor[attacker] 	+= damage_armor;
			
		DataPack pack;
		KillTimer(Timer_ShowDamage[attacker]);
		Timer_ShowDamage[attacker] = CreateDataTimer(0.01, TimerData_ShowDamage, pack);
		pack.WriteString(S_weapon);
		pack.WriteCell(attacker);
		pack.WriteCell(victim);
		pack.WriteCell(hitgroup);
		pack.WriteCell(health);
				
		Array_Victim[attacker].Push(victim);
		Array_RemoveDuplicateInt(Array_Victim[attacker]);
		C_CountVictim[attacker] = Array_Victim[attacker].Length;
	}
}

public Action TimerData_ShowDamage(Handle timer, DataPack pack)
{
	pack.Reset();
	
	char S_weapon[64];
	pack.ReadString(S_weapon, sizeof(S_weapon));
	int attacker 		= pack.ReadCell();
	int victim 			= pack.ReadCell();
	int hitgroup 		= pack.ReadCell();
	int health 			= pack.ReadCell();
	
	Timer_ShowDamage[attacker] = INVALID_HANDLE;
	
	switch (C_ShowDamageType[attacker])
	{
		case 0:
			ShowDamageHud(attacker, victim, C_TotalDamage[attacker], health);
			
		case 1:
			ShowDamage(S_weapon, attacker, victim, hitgroup, C_CountVictim[attacker], C_TotalDamage[attacker], C_TotalDamageArmor[attacker]);
	}

} 

void ShowDamageHud(int attacker, int victim, int damage_health, int health)
{
	SetHudTextParams(0.019, 0.045, 5.0, 255, 0, 0, 255);
	ShowHudText(attacker, 1, " %N\n Damage: %i\n HP: %i", victim, damage_health, health);
	
	Timer_ShowDamage[attacker] = INVALID_HANDLE;
}

void ShowDamage(char[] weapon, int attacker, int victim, int hitgroup, int count, int damage_health, int damage_armor)
{	
	if (count > 1 || StrEqual(weapon, "inferno", false) || StrEqual(weapon, "hegrenade", false))
	{
		if (StrEqual(weapon, "inferno", false))
			PrintHintText(attacker, "%t", "Show damage inferno", count, damage_health, damage_armor);
			
		else if (StrEqual(weapon, "hegrenade", false))
			PrintHintText(attacker, "%t", "Show damage hegrenade", count, damage_health, damage_armor);
			
		else
			PrintHintText(attacker, "%t", "Show damage multiple", weapon, count, damage_health, damage_armor);
	}
	else
	{
		char S_hitgroup_message[256];
		switch (hitgroup)
		{
			case 0:
			{
				S_hitgroup_message = "";
			}
			case 1:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Head", attacker);
			}
			case 2:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Chest", attacker);
			}
			case 3:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Stomach", attacker);
			}
			case 4:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Left arm", attacker);
			}
			case 5:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Right arm", attacker);
			}
			case 6:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Left leg", attacker);
			}
			case 7:
			{
				Format(S_hitgroup_message, sizeof(S_hitgroup_message), "%T", "Right leg", attacker);
			}
		}
		
		if(IsClientInGame(attacker) && IsClientInGame(victim) && attacker != victim)
		{
			if (strlen(S_hitgroup_message))
				PrintHintText(attacker, "%t", "Show damage hit message body", S_hitgroup_message, damage_health, damage_armor);
			else
				PrintHintText(attacker, "%t", "Show damage hit message", damage_health, damage_armor);
		}
	}
	Timer_ShowDamage[attacker] = INVALID_HANDLE;	
}

stock void Array_RemoveDuplicateInt(ArrayList array, bool sorted = false)
{
    if (!sorted)
        array.Sort(Sort_Ascending, Sort_Integer);
    
    int len = array.Length;
    if (len < 2)
        return;
    
    int currentVal;
    int lastVal = array.Get(len - 1);
    
    for (int i = len - 2; i >= 0; i--)
    {
        currentVal = array.Get(i);
        if (lastVal == currentVal)
            array.Erase(i + 1);
            
        lastVal = currentVal;
    }
}

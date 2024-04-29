#include <sourcemod>
#include <sdkhooks>

static bool _late_load;
bool g_bEnabled;

public Plugin myinfo = {
	name = "Dys MK Instagib",
	description = "Dys MK Instagib",
	author = "bauxite, rain",
	version = "0.1.0",
	url = "https://github.com/bauxiteDYS/SM-DYS-Instagib",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	_late_load = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	RegAdminCmd("sm_instagib", CmdToggleInstagib, ADMFLAG_GENERIC);
	
	if (_late_load)
	{
		for (int client = 1; client <= MaxClients; ++client)
		{
			if (!IsClientInGame(client))
			{
				continue;
			}
			if (!SDKHookEx(client, SDKHook_OnTakeDamage, OnTakeDamage))
			{
				ThrowError("Failed to SDKHook");
			}
			else
			{
				PrintToServer("Hook ok!");
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!SDKHookEx(client, SDKHook_OnTakeDamage, OnTakeDamage))
	{
		ThrowError("Failed to SDKHook");
	}
}

public Action CmdToggleInstagib(int client, int args)
{
	g_bEnabled = !g_bEnabled;
	
	PrintToChatAll("MK instagib mode is %s", g_bEnabled ? "enabled" : "disabled");
	PrintToConsoleAll("MK instagib mode is %s", g_bEnabled ? "enabled" : "disabled");
	
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{	
	if(g_bEnabled == false)
	{
		return Plugin_Continue;
	}
	
	if (!IsValidEntity(inflictor))
	{
		return Plugin_Continue;
	}
	
	char sWeapon[12 + 1];

	if (!GetEntityClassname(inflictor, sWeapon, sizeof(sWeapon)))
	{
		return Plugin_Continue;
	}
	
	if (StrEqual(sWeapon,"weapon_mk808"))
	{
		damage = 500.0;
		
		return Plugin_Changed;
	}	
	
	return Plugin_Continue;
}

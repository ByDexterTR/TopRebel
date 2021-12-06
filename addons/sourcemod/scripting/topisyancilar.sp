#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

int g_iRebel[65] = { 0, ... };
bool g_bChecked[65] = { false, ... }, g_bIsMySQl = false, Block = false;
char g_sSQLBuffer[3096];
Handle g_hDB = null;

public Plugin myinfo = 
{
	name = "Top İsyancılar", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_toprebel", Command_Rebel, "");
	RegConsoleCmd("sm_topisyan", Command_Rebel, "");
	RegConsoleCmd("sm_isyancilar", Command_Rebel, "");
	
	RegAdminCmd("sm_toprebellog", Command_RebelLog, ADMFLAG_ROOT, "");
	RegAdminCmd("sm_topisyanlog", Command_RebelLog, ADMFLAG_ROOT, "");
	RegAdminCmd("sm_isyancilarlog", Command_RebelLog, ADMFLAG_ROOT, "");
	
	RegAdminCmd("sm_xtoprebel", Command_RebelDelete, ADMFLAG_ROOT, "");
	RegAdminCmd("sm_xtopisyan", Command_RebelDelete, ADMFLAG_ROOT, "");
	RegAdminCmd("sm_xisyancilar", Command_RebelDelete, ADMFLAG_ROOT, "");
	
	HookEvent("player_death", OnClientDead);
	SQL_TConnect(OnSQLConnect, "toprebel");
}

public void OnMapStart()
{
	char map[32];
	GetCurrentMap(map, sizeof(map));
	if (strncmp(map, "workshop/", 9, false) == 0)
	{
		if (StrContains(map, "/jb_", false) == -1 && StrContains(map, "/jail_", false) == -1 && StrContains(map, "/ba_jail", false) == -1)
			Block = true;
	}
	else if (strncmp(map, "jb_", 3, false) != 0 && strncmp(map, "jail_", 5, false) != 0 && strncmp(map, "ba_jail", 3, false) != 0)
		Block = true;
	else
	{
		Block = false;
	}
}

public void OnPluginEnd()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			OnClientDisconnect(client);
		}
	}
}

public void OnClientDisconnect(int client)
{
	if (!IsFakeClient(client) && g_bChecked[client])
		SaveSQLCookies(client);
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsFakeClient(client))
		CheckSQLSteamID(client);
	
}

public Action OnClientDead(Event event, const char[] name, bool dB)
{
	if (!Block)
	{
		int victim = GetClientOfUserId(event.GetInt("userid"));
		if (IsValidClient(victim) && GetClientTeam(victim) == 3)
		{
			int attacker = GetClientOfUserId(event.GetInt("attacker"));
			if (IsValidClient(attacker) && GetClientTeam(attacker) == 2)
			{
				g_iRebel[attacker]++;
				OnClientDisconnect(attacker);
				OnClientPostAdminCheck(attacker);
			}
		}
	}
}

public int OnSQLConnect(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		LogError("Database failure: %s", error);
		
		SetFailState("Databases dont work");
	}
	else
	{
		g_hDB = hndl;
		
		SQL_GetDriverIdent(SQL_ReadDriver(g_hDB), g_sSQLBuffer, sizeof(g_sSQLBuffer));
		g_bIsMySQl = StrEqual(g_sSQLBuffer, "mysql", false) ? true : false;
		
		if (g_bIsMySQl)
		{
			Format(g_sSQLBuffer, sizeof(g_sSQLBuffer), "CREATE TABLE IF NOT EXISTS `toprebel` (`playername` varchar(128) NOT NULL, `steamid` varchar(32) PRIMARY KEY NOT NULL, `total` INT( 16 ))");
			SQL_TQuery(g_hDB, OnSQLConnectCallback, g_sSQLBuffer);
			for (int client = 1; client <= MaxClients; client++)
			{
				if (IsValidClient(client))
				{
					OnClientPostAdminCheck(client);
				}
			}
		}
		else
		{
			Format(g_sSQLBuffer, sizeof(g_sSQLBuffer), "CREATE TABLE IF NOT EXISTS toprebel (playername varchar(128) NOT NULL, steamid varchar(32) PRIMARY KEY NOT NULL, total INTEGER)");
			SQL_TQuery(g_hDB, OnSQLConnectCallback, g_sSQLBuffer);
			for (int client = 1; client <= MaxClients; client++)
			{
				if (IsValidClient(client))
				{
					OnClientPostAdminCheck(client);
				}
			}
		}
	}
}

public int OnSQLConnectCallback(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		LogError("Query failure: %s", error);
		return;
	}
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			OnClientPostAdminCheck(client);
		}
	}
}

public void InsertSQLNewPlayer(int client)
{
	char query[255], steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	int userid = GetClientUserId(client);
	
	char Name[MAX_NAME_LENGTH + 1];
	char SafeName[(sizeof(Name) * 2) + 1];
	if (!GetClientName(client, Name, sizeof(Name)))
		Format(SafeName, sizeof(SafeName), "<noname>");
	else
	{
		TrimString(Name);
		SQL_EscapeString(g_hDB, Name, SafeName, sizeof(SafeName));
	}
	
	Format(query, sizeof(query), "INSERT INTO toprebel(playername, steamid, total) VALUES('%s', '%s', '0');", SafeName, steamid);
	SQL_TQuery(g_hDB, SaveSQLPlayerCallback, query, userid);
	g_iRebel[client] = 0;
	
	g_bChecked[client] = true;
}

public int SaveSQLPlayerCallback(Handle owner, Handle hndl, char[] error, any data)
{
	if (hndl == null)
	{
		LogError("Query failure: %s", error);
	}
}

public void CheckSQLSteamID(int client)
{
	char query[255], steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	Format(query, sizeof(query), "SELECT total FROM toprebel WHERE steamid = '%s'", steamid);
	SQL_TQuery(g_hDB, CheckSQLSteamIDCallback, query, GetClientUserId(client));
}

public int CheckSQLSteamIDCallback(Handle owner, Handle hndl, char[] error, any data)
{
	int client;
	
	if ((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}
	
	if (hndl == null)
	{
		LogError("Query failure: %s", error);
		return;
	}
	if (!SQL_GetRowCount(hndl) || !SQL_FetchRow(hndl))
	{
		InsertSQLNewPlayer(client);
		return;
	}
	
	g_iRebel[client] = SQL_FetchInt(hndl, 0);
	g_bChecked[client] = true;
}

public void SaveSQLCookies(int client)
{
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	char Name[MAX_NAME_LENGTH + 1];
	char SafeName[(sizeof(Name) * 2) + 1];
	if (!GetClientName(client, Name, sizeof(Name)))
		Format(SafeName, sizeof(SafeName), "<noname>");
	else
	{
		TrimString(Name);
		SQL_EscapeString(g_hDB, Name, SafeName, sizeof(SafeName));
	}
	
	char buffer[3096];
	Format(buffer, sizeof(buffer), "UPDATE toprebel SET playername = '%s', total = '%i' WHERE steamid = '%s';", SafeName, g_iRebel[client], steamid);
	SQL_TQuery(g_hDB, SaveSQLPlayerCallback, buffer);
	g_bChecked[client] = false;
}

public Action Command_Rebel(int client, int args)
{
	if (g_hDB != null)
	{
		char buffer[200];
		Format(buffer, sizeof(buffer), "SELECT playername, total, steamid FROM toprebel ORDER BY total DESC LIMIT 999");
		SQL_TQuery(g_hDB, ShowTotalCallback, buffer, client);
		
		char steamid[32];
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
		Format(buffer, sizeof(buffer), "SELECT total FROM toprebel WHERE steamid = '%s'", steamid);
		SQL_TQuery(g_hDB, ShowClientTotal, buffer, client);
		
		return Plugin_Handled;
	}
	else
	{
		PrintToChat(client, " \x03Top Rebel sistemi çalışmıyor");
		return Plugin_Handled;
	}
}

public int ShowClientTotal(Handle owner, Handle hndl, char[] error, int client)
{
	if (hndl == null)
	{
		if (StrContains(error, "Duplicate", false) != -1)
		{
			LogError("Query failure: %s", error);
			return;
		}
	}
	
	while (SQL_FetchRow(hndl))
	{
		PrintToChat(client, "[SM] Toplam \x05%d İsyan \x01atmışsın!", SQL_FetchInt(hndl, 0));
	}
	
	delete hndl;
}

public int ShowTotalCallback(Handle owner, Handle hndl, char[] error, any client)
{
	if (hndl == null)
	{
		LogError(error);
		PrintToServer("Last Connect SQL Error: %s", error);
		return;
	}
	
	
	Menu menu2 = CreateMenu(Menu_Callback);
	
	menu2.SetTitle("Top İsyancılar\n__________________________\n ");
	
	int order = 0;
	char number[64];
	char name[64];
	char textbuffer[128];
	
	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			order++;
			Format(number, 64, "option%i", order);
			SQL_FetchString(hndl, 0, name, sizeof(name));
			Format(textbuffer, 128, "| %i. %s - Isyan: %d", order, name, SQL_FetchInt(hndl, 1));
			menu2.AddItem("X", textbuffer, ITEMDRAW_DISABLED);
		}
	}
	if (order < 1)
	{
		menu2.AddItem("empty", "Kimse İsyan Atmamış.", ITEMDRAW_DISABLED);
	}
	
	menu2.ExitButton = true;
	menu2.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action Command_RebelDelete(int client, int args)
{
	if (g_hDB == null)
	{
		LogError("Databases dont work");
		return Plugin_Handled;
	}
	
	char buffer[200];
	Format(buffer, sizeof(buffer), "SELECT playername, total, steamid FROM toprebel ORDER BY total DESC LIMIT 999");
	SQL_TQuery(g_hDB, DeleteTotalCallback, buffer, client);
	
	PrintToChatAll("[SM] \x10%N \x0ETop Rebel\x01'i sıfırladı.", client);
	return Plugin_Handled;
}

public int DeleteTotalCallback(Handle owner, Handle hndl, char[] error, any client)
{
	if (hndl == null)
	{
		LogError(error);
		PrintToServer("Last Connect SQL Error: %s", error);
		return;
	}
	
	char Dosya[256];
	FormatTime(Dosya, 256, "%F", GetTime());
	Format(Dosya, 256, "addons/sourcemod/logs/toprebel_%s.log", Dosya);
	
	int order = 0;
	char number[64];
	char name[64];
	char textbuffer[128];
	
	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			order++;
			Format(number, 64, "option%i", order);
			SQL_FetchString(hndl, 0, name, sizeof(name));
			Format(textbuffer, 128, "%i %s - Isyan: %d", order, name, SQL_FetchInt(hndl, 1));
			LogToFileEx(Dosya, textbuffer);
		}
	}
	if (order < 1)
	{
		LogToFileEx(Dosya, "Kimse isyan atmamış...");
	}
	
	char buffer[3096];
	Format(buffer, sizeof(buffer), "DELETE FROM toprebel;");
	SQL_TQuery(g_hDB, SaveSQLPlayerCallback, buffer);
	for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i) && !IsFakeClient(i))
	{
		SaveSQLCookies(i);
		OnClientPostAdminCheck(i);
	}
}

public Action Command_RebelLog(int client, int args)
{
	if (g_hDB == null)
	{
		LogError("Databases dont work");
		return Plugin_Handled;
	}
	
	char buffer[200];
	Format(buffer, sizeof(buffer), "SELECT playername, total, steamid FROM toprebel ORDER BY total DESC LIMIT 999");
	SQL_TQuery(g_hDB, DeleteTotalCallback, buffer, client);
	
	char Dosya[256];
	FormatTime(Dosya, 256, "%F", GetTime());
	Format(Dosya, 256, "addons/sourcemod/logs/toprebel_%s.log", Dosya);
	
	PrintToChat(client, "[SM] \x10Panele Loglanıyor... \x01(\x05%s\x01)", Dosya);
	return Plugin_Handled;
}

public int LogTotalCallback(Handle owner, Handle hndl, char[] error, any client)
{
	if (hndl == null)
	{
		LogError(error);
		PrintToServer("Last Connect SQL Error: %s", error);
		return;
	}
	
	char Dosya[256];
	FormatTime(Dosya, 256, "%F", GetTime());
	Format(Dosya, 256, "addons/sourcemod/logs/toprebel_%s.log", Dosya);
	
	int order = 0;
	char number[64];
	char name[64];
	char textbuffer[128];
	
	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			order++;
			Format(number, 64, "option%i", order);
			SQL_FetchString(hndl, 0, name, sizeof(name));
			Format(textbuffer, 128, "| %i %s - Isyan: %d", order, name, SQL_FetchInt(hndl, 1));
			LogToFileEx(Dosya, textbuffer);
		}
	}
	if (order < 1)
	{
		LogToFileEx(Dosya, "Kimse isyan atmamış...");
	}
}

bool IsValidClient(int client, bool nobots = false)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 
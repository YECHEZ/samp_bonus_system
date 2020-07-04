#include <a_samp>

#include <streamer>

//==============================================================================
//                            Настройки скрипта
//==============================================================================

#define FS11INS 2 //тип сервера:
//                //FS11INS 1 - стандартный сервер
//                //FS11INS 2 - Drift + DM сервер от [Gn_R],
//                //            или Drift non-DM сервер от [Gn_R]
//                //FS11INS 3 - реновация RDS сервера от [Gn_R]

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#define BONUS_MAX 50 //максимум бонусов на сервере (от 1 до 100)

//   ВНИМАНИЕ !!! после изменения настроек ОБЯЗАТЕЛЬНО откомпилировать !!!

//==============================================================================

#if (FS11INS < 1)
	#undef FS11INS
	#define FS11INS 1
#endif
#if (FS11INS > 3)
	#undef FS11INS
	#define FS11INS 3
#endif
#if (BONUS_MAX < 1)
	#undef BONUS_MAX
	#define BONUS_MAX 1
#endif
#if (BONUS_MAX > 100)
	#undef BONUS_MAX
	#define BONUS_MAX 100
#endif

new Text3D:fantxt;//переменная для хранения 3D-текста с несущесвующим ИД
new bonusmoney[BONUS_MAX];//-600 - бонус не существует, ИЛИ: денежная сумма бонуса
new bonusvw[BONUS_MAX];//виртуальный мир бонуса
new bonusint[BONUS_MAX];//интерьер бонуса
new Float:corx[BONUS_MAX];//координаты бонуса
new Float:cory[BONUS_MAX];
new Float:corz[BONUS_MAX];
new PickupID[BONUS_MAX];//массив ИД пикапов
new Text3D:Nbonus[BONUS_MAX];//массив ИД 3D-текстов

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//создаём 3D-текст с несущесвующим ИД
	for(new i; i < BONUS_MAX; i++)//цикл для всех бонусов
	{
		bonusmoney[i] = -600;//убираем все бонусы
	}
	print(" ");
	print("--------------------------------------");
	print("     BonusSys успешно загружена! ");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//удаляем 3D-текст с несущесвующим ИД
	for(new i; i < BONUS_MAX; i++)//цикл для всех бонусов
	{
		if(bonusmoney[i] != -600)//выгружаем все бонусы
		{
			DestroyDynamicPickup(PickupID[i]);//удаляем пикап бонуса
			DestroyDynamic3DTextLabel(Nbonus[i]);//удаляем 3D-текст бонуса
		}
	}
	return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[30];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
#if (FS11INS == 2 || FS11INS == 3)
	if(GetPVarInt(playerid, "CComAc9") < 0)
	{
		new dopcis, sstr[256];
		dopcis = FCislit(GetPVarInt(playerid, "CComAc9"));
		switch(dopcis)
		{
			case 0: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунд !", GetPVarInt(playerid, "CComAc9") * -1);
			case 1: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунду !", GetPVarInt(playerid, "CComAc9") * -1);
			case 2: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунды !", GetPVarInt(playerid, "CComAc9") * -1);
		}
		SendClientMessage(playerid, 0xFF0000FF, sstr);
		return 1;
	}
	SetPVarInt(playerid, "CComAc9", GetPVarInt(playerid, "CComAc9") + 1);
#endif
	new idx;
	idx = 0;
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	new cmd[256];
	new tmp[256];
	cmd = strtok(cmdtext, idx);
	if(strcmp(cmd, "/bonhelp", true) == 0)
	{
#if (FS11INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS11INS == 2)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 4)
#endif
#if (FS11INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 10)
#endif
		{
			SendClientMessage(playerid, 0x00FFFFFF, " ------------------------ Система бонусов ------------------------ ");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonhelp - помощь по командам BonusSys");
			SendClientMessage(playerid, 0x00FFFFFF, "   /boncreate - создать бонус");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonremove - удалить бонус по его ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonremoveall - удалить все бонусы");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bongoto - телепортироваться к бонусу по его ID");
			SendClientMessage(playerid, 0x00FFFFFF, " --------------------------------------------------------------------------- ");
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/boncreate", true) == 0)
	{
#if (FS11INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS11INS == 2)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 4)
#endif
#if (FS11INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 10)
#endif
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /boncreate [денежная сумма(10-10000000 $)]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 10 || para1 > 10000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Денежная сумма от 10 $ до 10000000 $ !");
				return 1;
			}
			new para2 = 0;
			new para3 = 0;
			while(para2 < BONUS_MAX)
			{
				if(bonusmoney[para2] == -600)
				{
					para3 = 1;
					break;
				}
				para2++;
			}
			if(para3 == 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Превышен лимит создания бонусов !");
				SendClientMessage(playerid, 0xFF0000FF, " Для продолжения - увеличьте максимум бонусов на сервере !");
				return 1;
			}
			bonusmoney[para2] = para1;//создаём бонус
			bonusvw[para2] = GetPlayerVirtualWorld(playerid);
			bonusint[para2] = GetPlayerInterior(playerid);
			GetPlayerPos(playerid, corx[para2], cory[para2], corz[para2]);

			PickupID[para2] = CreateDynamicPickup(1240, 1, corx[para2], cory[para2], corz[para2],
			bonusvw[para2], bonusint[para2], -1, 100.0);//создаём пикап бонуса
			format(string, sizeof(string), "Бонус\nID: %d", para2);
			Nbonus[para2] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, corx[para2], cory[para2], corz[para2]+0.70, 25,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, bonusvw[para2], bonusint[para2], -1);//создаём 3D-текст бонуса
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//доработка для использования Русских ников
			format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
			printf("[BonusSys] Админ %s [%d] создал бонус ID: %d .", aa333, playerid, para2);//доработка для использования Русских ников
//			printf("[BonusSys] Админ %s [%d] создал бонус ID: %d .", sendername, playerid, para2);
			format(string, sizeof(string), " Бонус ID: %d успешно создан.", para2);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/bonremove", true) == 0)
	{
#if (FS11INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS11INS == 2)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 4)
#endif
#if (FS11INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 10)
#endif
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /bonremove [ID бонуса]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BONUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бонуса с таким ID не существует !");
				return 1;
			}
			if(bonusmoney[para1] != -600)//если бонус существует, то:
			{
				DestroyDynamicPickup(PickupID[para1]);//удаляем пикап бонуса
				DestroyDynamic3DTextLabel(Nbonus[para1]);//удаляем 3D-текст бонуса
				bonusmoney[para1] = -600;//удаляем бонус
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BonusSys] Админ %s [%d] удалил бонус ID: %d .", aa333, playerid, para1);//доработка для использования Русских ников
//				printf("[BonusSys] Админ %s [%d] удалил бонус ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " Бонус ID: %d успешно удалён.", para1);
				SendClientMessage(playerid, 0xFF0000FF, string);
			}
			else//если бонус НЕ существует, то:
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бонуса с таким ID не существует !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/bonremoveall", true) == 0)
	{
#if (FS11INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS11INS == 2)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 4)
#endif
#if (FS11INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 10)
#endif
		{
			new para1 = 0;
			for(new i; i < BONUS_MAX; i++)
			{
				if(bonusmoney[i] != -600)//если бонус существует, то:
				{
					para1 = 1;
					DestroyDynamicPickup(PickupID[i]);//удаляем пикап бонуса
					DestroyDynamic3DTextLabel(Nbonus[i]);//удаляем 3D-текст бонуса
					bonusmoney[i] = -600;//удаляем бонус
				}
			}
			if(para1 == 1)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BonusSys] Админ %s [%d] удалил все бонусы.", aa333, playerid);//доработка для использования Русских ников
//				printf("[BonusSys] Админ %s [%d] удалил все бонусы.", sendername, playerid);
				SendClientMessage(playerid, 0xFF0000FF, " Все бонусы были успешно удалены.");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000FF, " На сервере не создано ни одного бонуса !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/bongoto", true) == 0)
	{
#if (FS11INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS11INS == 2)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 4)
#endif
#if (FS11INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 10)
#endif
		{
#if (FS11INS == 2 || FS11INS == 3)
			if(GetPVarInt(playerid, "SecPris") > 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " В тюрьме команда не работает !");
				return 1;
			}
#endif
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /bongoto [ID бонуса]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BONUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бонуса с таким ID не существует !");
				return 1;
			}
			if(bonusmoney[para1] != -600)//если бонус существует, то:
			{
#if (FS11INS == 2 || FS11INS == 3)
				SetPVarInt(playerid, "PlCRTp", 1);
#endif
				SetPlayerVirtualWorld(playerid, bonusvw[para1]);
 				SetPlayerInterior(playerid, bonusint[para1]);
				SetPlayerPos(playerid, corx[para1], cory[para1], corz[para1]);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BonusSys] Админ %s [%d] телепортировался к бонусу ID: %d .", aa333, playerid, para1);//доработка для использования Русских ников
//				printf("[BonusSys] Админ %s [%d] телепортировался к бонусу ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " Вы телепортировались к бонусу ID: %d .", para1);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
			else//если бонус не существуют, то:
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бонуса с таким ID не существует !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	return 0;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		new para1 = 0;
		new para2 = 0;
		while(para1 < BONUS_MAX)
		{
			if(PickupID[para1] == pickupid)
			{
				para2 = 1;
				break;
			}
			para1++;
		}
#if (FS11INS == 1)
		if(para2 == 1 && IsPlayerAdmin(playerid) == 0)
#endif
#if (FS11INS == 2 || FS11INS == 3)
		if(para2 == 1 && IsPlayerAdmin(playerid) == 0 &&
		GetPVarInt(playerid, "AdmLvl") == 0 && GetPVarInt(playerid, "PlDeport") == 0)
#endif
		{
			DestroyDynamicPickup(PickupID[para1]);//удаляем пикап бонуса
			DestroyDynamic3DTextLabel(Nbonus[para1]);//удаляем 3D-текст бонуса
			new para3;
#if (FS11INS == 1)
			para3 = GetPlayerMoney(playerid);
			GivePlayerMoney(playerid, bonusmoney[para1]);//дать денеги игроку
#endif
#if (FS11INS == 2 || FS11INS == 3)
			para3 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") + bonusmoney[para1]);//дать денеги игроку
#endif
			new string[256];
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//доработка для использования Русских ников
			format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
			printf("[BonusSys] Игрок %s [%d] получил бонус %d $ (ID: %d).", aa333, playerid, bonusmoney[para1], para1);//доработка для использования Русских ников
//			printf("[BonusSys] Игрок %s [%d] получил бонус %d $ (ID: %d).", sendername, playerid, bonusmoney[para1], para1);
			format(string, sizeof(string), " Вы получил бонус %d $ !!!", bonusmoney[para1]);
			SendClientMessage(playerid, 0x00FF00FF, string);
			printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", aa333, playerid, para3);//доработка для использования Русских ников
//			printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", sendername, playerid, para3);
			PlayerPlaySound(playerid, 1133, 0.00, 0.00, 0.00);
			bonusmoney[para1] = -600;//удаляем бонус
		}
	}
	return 1;
}

#if (FS11INS == 2 || FS11INS == 3)
	forward FCislit(cislo);
	public FCislit(cislo)
	{
		new para, para22, string[256], string22[4], string33[4];
		strdel(string22, 0, 4);
		strdel(string33, 0, 4);
		format(string, sizeof(string), "%d", cislo);
		para22 = strlen(string);
		if(para22 == 1)
		{
			strmid(string22, string, para22-1, para22, sizeof(string22));
		}
		else
		{
	    	strmid(string22, string, para22-1, para22, sizeof(string22));
	    	strmid(string33, string, para22-2, para22-1, sizeof(string33));
		}
		para22 = strval(string33);
		if(para22 > 1) { para22 = 0; }
		para22 = para22 * 10 + strval(string22);
		switch(para22)
		{
			case 0,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19: para = 0;
			case 1: para = 1;
			case 2,3,4: para = 2;
		}
		return para;
	}
#endif


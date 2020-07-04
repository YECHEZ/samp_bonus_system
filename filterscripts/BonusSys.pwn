#include <a_samp>

#include <streamer>

//==============================================================================
//                            ��������� �������
//==============================================================================

#define FS11INS 2 //��� �������:
//                //FS11INS 1 - ����������� ������
//                //FS11INS 2 - Drift + DM ������ �� [Gn_R],
//                //            ��� Drift non-DM ������ �� [Gn_R]
//                //FS11INS 3 - ��������� RDS ������� �� [Gn_R]

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //�������� ������� �� ������� + 1 (���� 50 �������, �� ����� 51 !!!)

#define BONUS_MAX 50 //�������� ������� �� ������� (�� 1 �� 100)

//   �������� !!! ����� ��������� �������� ����������� ��������������� !!!

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

new Text3D:fantxt;//���������� ��� �������� 3D-������ � ������������� ��
new bonusmoney[BONUS_MAX];//-600 - ����� �� ����������, ���: �������� ����� ������
new bonusvw[BONUS_MAX];//����������� ��� ������
new bonusint[BONUS_MAX];//�������� ������
new Float:corx[BONUS_MAX];//���������� ������
new Float:cory[BONUS_MAX];
new Float:corz[BONUS_MAX];
new PickupID[BONUS_MAX];//������ �� �������
new Text3D:Nbonus[BONUS_MAX];//������ �� 3D-�������

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//������ 3D-����� � ������������� ��
	for(new i; i < BONUS_MAX; i++)//���� ��� ���� �������
	{
		bonusmoney[i] = -600;//������� ��� ������
	}
	print(" ");
	print("--------------------------------------");
	print("     BonusSys ������� ���������! ");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//������� 3D-����� � ������������� ��
	for(new i; i < BONUS_MAX; i++)//���� ��� ���� �������
	{
		if(bonusmoney[i] != -600)//��������� ��� ������
		{
			DestroyDynamicPickup(PickupID[i]);//������� ����� ������
			DestroyDynamic3DTextLabel(Nbonus[i]);//������� 3D-����� ������
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
			case 0: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������ !", GetPVarInt(playerid, "CComAc9") * -1);
			case 1: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc9") * -1);
			case 2: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc9") * -1);
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
			SendClientMessage(playerid, 0x00FFFFFF, " ------------------------ ������� ������� ------------------------ ");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonhelp - ������ �� �������� BonusSys");
			SendClientMessage(playerid, 0x00FFFFFF, "   /boncreate - ������� �����");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonremove - ������� ����� �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bonremoveall - ������� ��� ������");
			SendClientMessage(playerid, 0x00FFFFFF, "   /bongoto - ����������������� � ������ �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, " --------------------------------------------------------------------------- ");
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /boncreate [�������� �����(10-10000000 $)]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 10 || para1 > 10000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " �������� ����� �� 10 $ �� 10000000 $ !");
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
				SendClientMessage(playerid, 0xFF0000FF, " �������� ����� �������� ������� !");
				SendClientMessage(playerid, 0xFF0000FF, " ��� ����������� - ��������� �������� ������� �� ������� !");
				return 1;
			}
			bonusmoney[para2] = para1;//������ �����
			bonusvw[para2] = GetPlayerVirtualWorld(playerid);
			bonusint[para2] = GetPlayerInterior(playerid);
			GetPlayerPos(playerid, corx[para2], cory[para2], corz[para2]);

			PickupID[para2] = CreateDynamicPickup(1240, 1, corx[para2], cory[para2], corz[para2],
			bonusvw[para2], bonusint[para2], -1, 100.0);//������ ����� ������
			format(string, sizeof(string), "�����\nID: %d", para2);
			Nbonus[para2] = CreateDynamic3DTextLabel(string, 0xFFFFFFFF, corx[para2], cory[para2], corz[para2]+0.70, 25,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, bonusvw[para2], bonusint[para2], -1);//������ 3D-����� ������
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[BonusSys] ����� %s [%d] ������ ����� ID: %d .", aa333, playerid, para2);//��������� ��� ������������� ������� �����
//			printf("[BonusSys] ����� %s [%d] ������ ����� ID: %d .", sendername, playerid, para2);
			format(string, sizeof(string), " ����� ID: %d ������� ������.", para2);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /bonremove [ID ������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BONUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
				return 1;
			}
			if(bonusmoney[para1] != -600)//���� ����� ����������, ��:
			{
				DestroyDynamicPickup(PickupID[para1]);//������� ����� ������
				DestroyDynamic3DTextLabel(Nbonus[para1]);//������� 3D-����� ������
				bonusmoney[para1] = -600;//������� �����
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BonusSys] ����� %s [%d] ������ ����� ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[BonusSys] ����� %s [%d] ������ ����� ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " ����� ID: %d ������� �����.", para1);
				SendClientMessage(playerid, 0xFF0000FF, string);
			}
			else//���� ����� �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				if(bonusmoney[i] != -600)//���� ����� ����������, ��:
				{
					para1 = 1;
					DestroyDynamicPickup(PickupID[i]);//������� ����� ������
					DestroyDynamic3DTextLabel(Nbonus[i]);//������� 3D-����� ������
					bonusmoney[i] = -600;//������� �����
				}
			}
			if(para1 == 1)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BonusSys] ����� %s [%d] ������ ��� ������.", aa333, playerid);//��������� ��� ������������� ������� �����
//				printf("[BonusSys] ����� %s [%d] ������ ��� ������.", sendername, playerid);
				SendClientMessage(playerid, 0xFF0000FF, " ��� ������ ���� ������� �������.");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000FF, " �� ������� �� ������� �� ������ ������ !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0xFF0000FF, " � ������ ������� �� �������� !");
				return 1;
			}
#endif
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /bongoto [ID ������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BONUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
				return 1;
			}
			if(bonusmoney[para1] != -600)//���� ����� ����������, ��:
			{
#if (FS11INS == 2 || FS11INS == 3)
				SetPVarInt(playerid, "PlCRTp", 1);
#endif
				SetPlayerVirtualWorld(playerid, bonusvw[para1]);
 				SetPlayerInterior(playerid, bonusint[para1]);
				SetPlayerPos(playerid, corx[para1], cory[para1], corz[para1]);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BonusSys] ����� %s [%d] ���������������� � ������ ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[BonusSys] ����� %s [%d] ���������������� � ������ ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " �� ����������������� � ������ ID: %d .", para1);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
			else//���� ����� �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
			DestroyDynamicPickup(PickupID[para1]);//������� ����� ������
			DestroyDynamic3DTextLabel(Nbonus[para1]);//������� 3D-����� ������
			new para3;
#if (FS11INS == 1)
			para3 = GetPlayerMoney(playerid);
			GivePlayerMoney(playerid, bonusmoney[para1]);//���� ������ ������
#endif
#if (FS11INS == 2 || FS11INS == 3)
			para3 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") + bonusmoney[para1]);//���� ������ ������
#endif
			new string[256];
			new sendername[MAX_PLAYER_NAME];
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[BonusSys] ����� %s [%d] ������� ����� %d $ (ID: %d).", aa333, playerid, bonusmoney[para1], para1);//��������� ��� ������������� ������� �����
//			printf("[BonusSys] ����� %s [%d] ������� ����� %d $ (ID: %d).", sendername, playerid, bonusmoney[para1], para1);
			format(string, sizeof(string), " �� ������� ����� %d $ !!!", bonusmoney[para1]);
			SendClientMessage(playerid, 0x00FF00FF, string);
			printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", aa333, playerid, para3);//��������� ��� ������������� ������� �����
//			printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", sendername, playerid, para3);
			PlayerPlaySound(playerid, 1133, 0.00, 0.00, 0.00);
			bonusmoney[para1] = -600;//������� �����
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


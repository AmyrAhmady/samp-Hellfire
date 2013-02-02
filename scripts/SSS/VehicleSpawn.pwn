#include <YSI\y_hooks>

#define MAX_SPAWNED_VEHICLES		(400)
#define VEHICLE_INDEX_FILE			"vehicles/index.ini"
#define VEHICLE_DATA_FILE			"vehicles/%s.dat"
#define PLAYER_VEHICLE_DIRECTORY	"./scriptfiles/SSS/Vehicles/"
#define PLAYER_VEHICLE_FILE			"SSS/Vehicles/%s.dat"


enum
{
	VEHICLE_GROUP_NONE				= -1,
	VEHICLE_GROUP_CASUAL,			// 0
	VEHICLE_GROUP_CASUAL_DESERT,	// 1
	VEHICLE_GROUP_CASUAL_COUNTRY,	// 2
	VEHICLE_GROUP_SPORT,			// 3
	VEHICLE_GROUP_OFFROAD,			// 4
	VEHICLE_GROUP_BIKE,				// 5
	VEHICLE_GROUP_FASTBIKE,			// 6
	VEHICLE_GROUP_MILITARY,			// 7
	VEHICLE_GROUP_POLICE,			// 8
	VEHICLE_GROUP_BIGPLANE,			// 9
	VEHICLE_GROUP_SMALLPLANE,		// 10
	VEHICLE_GROUP_HELICOPTER,		// 11
	VEHICLE_GROUP_BOAT				// 12
}
enum (<<=1)
{
	v_Used = 1,
	v_Occupied,
	v_Player
}
enum E_PLAYER_VEHICLE_DATA
{
	Float:pv_health,
	pv_panels,
	pv_doors,
	pv_lights,
	pv_tires
}


new
			gTotalVehicles,
			gCurModelGroup,
			bVehicleSettings[MAX_VEHICLES],
Iterator:	gVehicleIndex<MAX_VEHICLES>,
Float:		gVehicleFuel[MAX_VEHICLES],
			gVehicleTrunkLocked[MAX_VEHICLES],
			gVehicleArea[MAX_VEHICLES],
			gVehicleContainer[MAX_VEHICLES],
			gCurrentContainerVehicle[MAX_VEHICLES],
			gVehicleOwner[MAX_VEHICLES][MAX_PLAYER_NAME],
			gVehicleColours[MAX_VEHICLES][2],
			gPlayerVehicleData[MAX_VEHICLES][E_PLAYER_VEHICLE_DATA];


new gModelGroup[13][78]=
{
	// VEHICLE_GROUP_CASUAL
	{
		404,442,479,549,600,496,496,401,
		410,419,436,439,517,518,401,410,
		419,436,439,474,491,496,517,518,
		526,527,533,545,549,580,589,600,
		602,400,404,442,458,479,489,505,
		579,405,421,426,445,466,467,492,
		507,516,529,540,546,547,550,551,
		566,585,587,412,534,535,536,567,
		575,576,509,481,510,462,448,463,
		586,468,471,0
	},
	// VEHICLE_GROUP_CASUAL_DESERT,
	{
	    404,479,445,542,466,467,549,540,
		424,400,500,505,489,499,422,600,
		515,543,554,443,508,525,509,481,
		510,462,448,463,586,468,471,0,...
	},
	// VEHICLE_GROUP_CASUAL_COUNTRY,
	{
	    499,422,498,609,455,403,414,514,
		600,413,515,440,543,531,478,456,
		554,445,518,401,527,542,546,410,
		549,508,525,509,481,510,462,448,
		463,586,468,471,0,...
	},
	// VEHICLE_GROUP_SPORT,
	{
		558,559,560,561,562,565,411,451,
		477,480,494,502,503,506,541,581,
		522,461,521,0,...
	},
	// VEHICLE_GROUP_OFFROAD,
	{
		400,505,579,422,478,543,554,468,
		586,0,...
	},
	// VEHICLE_GROUP_BIKE,
	{
	    509,481,510,462,448,463,586,468,
		471,0,...
	},
	// VEHICLE_GROUP_FASTBIKE,
	{
	    581,522,461,521,0,...
	},
	// VEHICLE_GROUP_MILITARY,
	{
	    433,432,601,470,0,...
	},
	// VEHICLE_GROUP_POLICE,
	{
	    523,596,598,597,599,490,528,427
	},
	// VEHICLE_GROUP_BIGPLANE,
	{
	    519,553,577,592,0,...
	},
	// VEHICLE_GROUP_SMALLPLANE,
	{
	    460,476,511,512,513,593,0,...
	},
	// VEHICLE_GROUP_HELICOPTER,
	{
	    548,487,417,487,488,487,497,487,
		563,477,469,487,0,...
	},
	// VEHICLE_GROUP_BOAT,
	{
	    472,473,493,595,484,430,453,452,
		446,454,0,...
	}
};


LoadVehicles(bool:prints = true)
{
	LoadPlayerVehicles(prints);
	LoadAllVehicles(prints);
	LoadStaticVehiclesFromFile("vehicles/special/trains.dat", prints);

	defer ApplyVehicleConditionToAll();

	if(prints)
		printf("Total Vehicles: %d", gTotalVehicles);
}
UnloadVehicles()
{
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			if(!isnull(gVehicleOwner[i]))
				SavePlayerVehicle(i, gVehicleOwner[i]);

			DestroyVehicle(i);
			DestroyContainer(gVehicleContainer[i]);
		}
	}

    gTotalVehicles = 0;
}
ReloadVehicles()
{
	UnloadVehicles();
	LoadVehicles(false);
}


LoadAllVehicles(bool:prints = true)
{
	new
	    File:f=fopen(VEHICLE_INDEX_FILE, io_read),
		line[128],
		str[128];

	while(fread(f, line))
	{
	    if(line[strlen(line)-2] == '\r')line[strlen(line) - 2] = EOS;
		format(str, 128, VEHICLE_DATA_FILE, line);
		LoadVehiclesFromFile(str, prints);
	}

	fclose(f);
}
LoadStaticVehiclesFromFile(file[], bool:prints = true)
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");

	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		count;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>ffffD(0)", posX, posY, posZ, rotZ, model))
		{
			new id;
			id = AddStaticVehicle(model, posX, posY, posZ, rotZ, -1, -1);

			if(model == 449)
			{
				Iter_Add(gVehicleIndex, id);
				ApplyVehicleData(id);
			}

			gTotalVehicles++;
			count++;
		}
	}
	fclose(f);

	if(prints)
		printf("\t-Loaded %d vehicles from %s", count, file);

	return 1;
}


LoadVehiclesFromFile(file[], bool:prints = true)
{
	if(!fexist(file))return print("VEHICLE FILE NOT FOUND");
	new
	    File:f=fopen(file, io_read),
		line[128],
		Float:posX,
		Float:posY,
		Float:posZ,
		Float:rotZ,
		model,
		tmpid;

	while(fread(f, line) && gTotalVehicles < MAX_SPAWNED_VEHICLES)
	{
		if(!sscanf(line, "p<,>ffffD(-1)", posX, posY, posZ, rotZ, model))
		{
			if(tmpid >= MAX_SPAWNED_VEHICLES)
				break;

		    if(random(100) < 80)continue;

			if(model == -1)
				model = PickRandomVehicleFromGroup(gCurModelGroup);

			else if(0 <= model <= 12)
				model = PickRandomVehicleFromGroup(model);

			if( model == 403 ||
				model == 443 ||
				model == 514 ||
				model == 515) posZ += 2.0;

			if(	gCurModelGroup == VEHICLE_GROUP_CASUAL ||
				gCurModelGroup == VEHICLE_GROUP_OFFROAD ||
				gCurModelGroup == VEHICLE_GROUP_SPORT ||
				gCurModelGroup == VEHICLE_GROUP_BIKE ||
				gCurModelGroup == VEHICLE_GROUP_FASTBIKE) rotZ += random(2) ? 0.0 : 180.0;


			tmpid = CreateVehicle(model, posX, posY, posZ, rotZ, -1, -1, 86400000);

			if(IsValidVehicle(tmpid))
			{
				Iter_Add(gVehicleIndex, tmpid);

				gVehicleColours[tmpid][0] = 128 + random(128);
				gVehicleColours[tmpid][1] = 128 + random(128);
				ChangeVehicleColor(tmpid, gVehicleColours[tmpid][0], gVehicleColours[tmpid][1]);
				gTotalVehicles++;
			}
		}
		else if(sscanf(line, "'MODELGROUP:'d", gCurModelGroup) && strlen(line) > 3)print("LINE ERROR");
	}
	fclose(f);

	if(prints)
		printf("\t-Loaded %d vehicles from %s", gTotalVehicles, file);

	return 1;
}
PickRandomVehicleFromGroup(group)
{
	new idx;
	while(gModelGroup[group][idx] != 0)idx++;
	return gModelGroup[group][random(idx)];
}

LoadPlayerVehicles(bool:prints = true)
{
	new
		dir:direc = dir_open(PLAYER_VEHICLE_DIRECTORY),
		item[28],
		type,
		File:file,
		filedir[64],
		vehicleid;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			new
				array[13 + (CNT_MAX_SLOTS * 2)],
				itemid;

			filedir = "SSS/Vehicles/";
			strcat(filedir, item);
			file = fopen(filedir, io_read);
			fblockread(file, array, sizeof(array));
			fclose(file);

			vehicleid = CreateVehicle(array[0], Float:array[3], Float:array[4], Float:array[5], Float:array[6], array[7], array[8], 86400000);

			sscanf(item, "p<.>s[24]{s[24]}", gVehicleOwner[vehicleid]);

			printf("Loading vehicle %d for %s", vehicleid, gVehicleOwner[vehicleid]);

			if(IsValidVehicle(vehicleid))
			{
				Iter_Add(gVehicleIndex, vehicleid);

				gVehicleFuel[vehicleid] = Float:array[2];
				gVehicleColours[vehicleid][0] = array[7];
				gVehicleColours[vehicleid][1] = array[8];
				gPlayerVehicleData[vehicleid][pv_health]	= Float:array[1];
				gPlayerVehicleData[vehicleid][pv_panels]	= array[9];
				gPlayerVehicleData[vehicleid][pv_doors]		= array[10];
				gPlayerVehicleData[vehicleid][pv_lights]	= array[11];
				gPlayerVehicleData[vehicleid][pv_tires]		= array[12];

				if(VehicleFuelData[array[0]-400][veh_trunkSize])
				{
					gVehicleContainer[vehicleid] = CreateContainer("Trunk", VehicleFuelData[array[0]-400][veh_trunkSize], .virtual = 1);
					for(new i, j; j < CNT_MAX_SLOTS; i += 2, j++)
					{
						if(IsValidItemType(ItemType:array[13 + i]))
						{
							itemid = CreateItem(ItemType:array[13 + i], 0.0, 0.0, 0.0);
							SetItemExtraData(itemid, array[13 + i + 1]);
							AddItemToContainer(gVehicleContainer[vehicleid], itemid);
						}
					}
				}

				t:bVehicleSettings[vehicleid]<v_Player>;
				gTotalVehicles++;
			}
		}
	}

	dir_close(direc);

	if(prints)
		printf("Loaded %d Player vehicles", gTotalVehicles);
}

SavePlayerVehicle(vehicleid, name[MAX_PLAYER_NAME])
{
	printf("Saving vehicle %d for %s", vehicleid, name);
	if(!IsValidVehicle(vehicleid))
		return 0;

	new
		File:file,
		filename[MAX_PLAYER_NAME + 18],
		array[13 + (CNT_MAX_SLOTS * 2)],
		itemid;

	array[0] = GetVehicleModel(vehicleid);
	GetVehicleHealth(vehicleid, Float:array[1]);
	array[2] = _:gVehicleFuel[vehicleid];
	GetVehiclePos(vehicleid, Float:array[3], Float:array[4], Float:array[5]);
	GetVehicleZAngle(vehicleid, Float:array[6]);
	array[7] = gVehicleColours[vehicleid][0];
	array[8] = gVehicleColours[vehicleid][1];
	GetVehicleDamageStatus(vehicleid, array[9], array[10], array[11], array[12]);

	if(IsValidContainer(gVehicleContainer[vehicleid]))
	{
		for(new i, j; j < CNT_MAX_SLOTS; i += 2, j++)
		{
			if(IsContainerSlotUsed(gVehicleContainer[vehicleid], j))
			{
				itemid = GetContainerSlotItem(gVehicleContainer[vehicleid], j);
				array[13 + i] = _:GetItemType(itemid);
				array[13 + i + 1] = GetItemExtraData(itemid);
			}
			else
			{
				array[13 + i] = -1;
				array[13 + i + 1] = 0;
			}
		}
	}

	if(!isnull(gVehicleOwner[vehicleid]))
	{
		format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", gVehicleOwner[vehicleid]);

		if(fexist(filename))
			fremove(filename);
	}

	gVehicleOwner[vehicleid] = name;

	for(new i; i < MAX_VEHICLES; i++)
	{
		if(i == vehicleid)
			continue;

		if(!strcmp(gVehicleOwner[i], gVehicleOwner[vehicleid]))
			gVehicleOwner[i][0] = EOS;
	}

	format(filename, sizeof(filename), "SSS/Vehicles/%s.dat", gVehicleOwner[vehicleid]);
	file = fopen(filename, io_write);

	fblockwrite(file, array, sizeof(array));

	fclose(file);

	return 1;
}

timer ApplyVehicleConditionToAll[1000]()
{
	foreach(new i : gVehicleIndex)
	{
		ApplyVehicleData(i);
	}
}

ApplyVehicleData(vehicleid)
{
	new
		model = GetVehicleModel(vehicleid),
		Float:sx,
		Float:sy,
		Float:sz;

	if(bVehicleSettings[vehicleid] & v_Player)
	{
		SetVehicleHealth(vehicleid, gPlayerVehicleData[vehicleid][pv_health]);

		if(GetVehicleType(GetVehicleModel(vehicleid)) == VTYPE_BMX)
			SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);

		else
			SetVehicleParamsEx(vehicleid, 0, 0, 0, 0, 0, 0, 0);

		UpdateVehicleDamageStatus(vehicleid,
			gPlayerVehicleData[vehicleid][pv_panels],
			gPlayerVehicleData[vehicleid][pv_doors],
			gPlayerVehicleData[vehicleid][pv_lights],
			gPlayerVehicleData[vehicleid][pv_tires]);
	}
	else
	{
		new
			chance = random(100),
			panels,
			doors,
			lights,
			tires;

		if(chance < 1)
			SetVehicleHealth(vehicleid, 700 + random(300));

		else if(chance < 5)
			SetVehicleHealth(vehicleid, 400 + random(300));

		else
			SetVehicleHealth(vehicleid, 300 + random(300));

		chance = random(100);

		if(chance < 1)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 2 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 2);

		else if(chance < 5)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 4 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 3);

		else if(chance < 10)
			gVehicleFuel[vehicleid] = VehicleFuelData[model-400][veh_maxFuel] / 8 + frandom(VehicleFuelData[model - 400][veh_maxFuel] / 4);

		else
			gVehicleFuel[vehicleid] = frandom(1.0);


		panels	= encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4));
		doors	= encode_doors(random(5), random(5), random(5), random(5), random(5), random(5));
		lights	= encode_lights(random(2), random(2), random(2), random(2));
		tires	= encode_tires(random(2), random(2), random(2), random(2));

		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

		if(VehicleFuelData[model - 400][veh_maxFuel] == 0.0)
		{
			SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
		}
		else
		{
			new locked;

			if(doors == 0)
				locked = random(2);

			if(panels == 0)
				gVehicleTrunkLocked[vehicleid] = random(2);

			SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);
		}


		if(VehicleFuelData[model - 400][veh_lootIndex] != -1 && 0 < VehicleFuelData[model - 400][veh_trunkSize] < CNT_MAX_SLOTS)
		{
			new
				itemid,
				ItemType:itemtype,
				Float:x,
				Float:y,
				Float:z,
				lootindex,
				exdata;

			GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, x, y, z);

			gVehicleContainer[vehicleid] = CreateContainer("Trunk", VehicleFuelData[model-400][veh_trunkSize], .virtual = 1);

			for(new i = 1; i <= 4; i++)
			{
				lootindex = VehicleFuelData[model-400][veh_lootIndex];

				if(random(100) < 100 / i )
				{
					itemtype = GenerateLoot(lootindex, exdata);
					itemid = CreateItem(itemtype, 0.0, 0.0, 0.0);
					AddItemToContainer(gVehicleContainer[vehicleid], itemid);

					if(0 < _:itemtype <= WEAPON_PARACHUTE)
						SetItemExtraData(itemid, (WepData[_:itemtype][MagSize] * (random(3))) + random(WepData[_:itemtype][MagSize]));

					if(exdata != -1)
						SetItemExtraData(itemid, exdata);

					if(itemtype == item_Satchel || itemtype == item_Backpack)
					{
						itemtype = GenerateLoot(lootindex, exdata);
						itemid = CreateItem(itemtype, 0.0, 0.0, 0.0);

						if(0 < _:itemtype <= WEAPON_PARACHUTE)
							SetItemExtraData(itemid, (WepData[_:itemtype][MagSize] * (random(3))) + random(WepData[_:itemtype][MagSize]));

						else
							SetItemExtraData(itemid, exdata);

						AddItemToContainer(GetItemExtraData(itemid), itemid);
					}
				}
			}
		}
		else
		{
			gVehicleContainer[vehicleid] = INVALID_CONTAINER_ID;
		}
	}

	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, sx, sy, sz);

	gVehicleArea[vehicleid] = CreateDynamicSphere(0.0, 0.0, 0.0, sy, 0);
	AttachDynamicAreaToVehicle(gVehicleArea[vehicleid], vehicleid);

	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());

	return 1;
}

public OnVehicleDeath(vehicleid)
{
	if(IsValidContainer(gVehicleContainer[vehicleid]))
	{
		for(new i; i < CNT_MAX_SLOTS; i++)
		{
			DestroyItem(GetContainerSlotItem(gVehicleContainer[vehicleid], i));
		}
		DestroyContainer(gVehicleContainer[vehicleid]);
	}

	DestroyDynamicArea(gVehicleArea[vehicleid]);
	DestroyVehicle(vehicleid);
	Iter_Remove(gVehicleIndex, vehicleid);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER)
	{
		SetCameraBehindPlayer(playerid);
		SavePlayerVehicle(gPlayerVehicleID[playerid], gPlayerName[playerid]);
	}
}

public OnPlayerAddedToContainer(playerid, containerid, itemid)
{
	if(0 <= playerid < MAX_PLAYERS)
	{
		if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
		{
			if(!isnull(gVehicleOwner[gCurrentContainerVehicle[playerid]]) && !strcmp(gVehicleOwner[gCurrentContainerVehicle[playerid]], gPlayerName[playerid]))
			{
				SavePlayerVehicle(gCurrentContainerVehicle[playerid], gPlayerName[playerid]);
			}
		}
	}

	return CallLocalFunction("veh_OnPlayerAddedToContainer", "dd", playerid, containerid, itemid);
}
#if defined _ALS_OnPlayerAddedToContainer
	#undef OnPlayerAddedToContainer
#else
	#define _ALS_OnPlayerAddedToContainer
#endif
#define OnPlayerAddedToContainer veh_OnPlayerAddedToContainer
forward veh_OnPlayerAddedToContainer(playerid, containerid, itemid);

public OnPlayerTakenFromContainer(playerid, containerid, slotid)
{
	if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
	{
		if(IsValidVehicle(gCurrentContainerVehicle[playerid]))
		{
			if(!isnull(gVehicleOwner[gCurrentContainerVehicle[playerid]]) && !strcmp(gVehicleOwner[gCurrentContainerVehicle[playerid]], gPlayerName[playerid]))
			{
				SavePlayerVehicle(gCurrentContainerVehicle[playerid], gPlayerName[playerid]);
			}
		}
	}

	return CallLocalFunction("veh_OnPlayerTakenFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakenFromContainer
	#undef OnPlayerTakenFromContainer
#else
	#define _ALS_OnPlayerTakenFromContainer
#endif
#define OnPlayerTakenFromContainer veh_OnPlayerTakenFromContainer
forward veh_OnPlayerTakenFromContainer(playerid, containerid, slotid);


IsPlayerInVehicleArea(playerid, vehicleid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
			return 0;

	if(!IsValidVehicle(vehicleid))
		return 0;

	return IsPlayerInDynamicArea(playerid, gVehicleArea[vehicleid]);
}

RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
	{
		if(c<4)str[c] = 'A' + random(26);
		else if(c>4)str[c] = '0' + random(10);
		str[4] = ' ';
	}
	return str;
}


CMD:reloadvehicles(playerid, params[])
{
	ReloadVehicles();
	Msg(playerid, YELLOW, " >  Reloading Vehicles...");
	return 1;
}



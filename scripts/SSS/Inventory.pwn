#include <YSI\y_hooks>


#define UI_ELEMENT_TITLE	(0)
#define UI_ELEMENT_TILE		(1)
#define UI_ELEMENT_ITEM		(2)


new
	PlayerText:GearSlot_Head[3],
	PlayerText:GearSlot_Hand[3],
	PlayerText:GearSlot_Tors[3],
	PlayerText:GearSlot_Back[3],
	PlayerText:GearSlot_Hols[3],
	PlayerText:GearSlot_Skin[3];


forward CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour);


hook OnPlayerConnect(playerid)
{
	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 490.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 560.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 490.0, 210.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 560.0, 210.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 490.0, 300.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Skin[0], GearSlot_Skin[1], GearSlot_Skin[2], 560.0, 300.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);

	PlayerTextDrawSetString(playerid, GearSlot_Head[0], "Head");
	PlayerTextDrawSetString(playerid, GearSlot_Hand[0], "Hand");
	PlayerTextDrawSetString(playerid, GearSlot_Tors[0], "Torso");
	PlayerTextDrawSetString(playerid, GearSlot_Back[0], "Back");
	PlayerTextDrawSetString(playerid, GearSlot_Hols[0], "Holster");
	PlayerTextDrawSetString(playerid, GearSlot_Skin[0], "Clothes");
}


CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour)
{
	title							=CreatePlayerTextDraw(playerid, x + width / 2.0, y - 12.0, "_");
	PlayerTextDrawAlignment			(playerid, title, 2);
	PlayerTextDrawBackgroundColor	(playerid, title, 255);
	PlayerTextDrawFont				(playerid, title, 2);
	PlayerTextDrawLetterSize		(playerid, title, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, title, -1);
	PlayerTextDrawSetOutline		(playerid, title, 1);
	PlayerTextDrawSetProportional	(playerid, title, 1);
	PlayerTextDrawTextSize			(playerid, title, height, width - 4);
	PlayerTextDrawUseBox			(playerid, title, true);

	tile							=CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont				(playerid, tile, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, tile, colour);
	PlayerTextDrawColor				(playerid, tile, overlaycolour);
	PlayerTextDrawTextSize			(playerid, tile, width, height);
	PlayerTextDrawSetSelectable		(playerid, tile, true);

	item							=CreatePlayerTextDraw(playerid, x + width / 2.0, y + height, "_");
	PlayerTextDrawAlignment			(playerid, item, 2);
	PlayerTextDrawBackgroundColor	(playerid, item, 255);
	PlayerTextDrawFont				(playerid, item, 2);
	PlayerTextDrawLetterSize		(playerid, item, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, item, -1);
	PlayerTextDrawSetOutline		(playerid, item, 1);
	PlayerTextDrawSetProportional	(playerid, item, 1);
}

ShowPlayerGear(playerid)
{
	for(new i; i < 3; i++)
	{
		PlayerTextDrawShow(playerid, GearSlot_Head[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hand[i]);
		PlayerTextDrawShow(playerid, GearSlot_Tors[i]);
		PlayerTextDrawShow(playerid, GearSlot_Back[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hols[i]);
		PlayerTextDrawShow(playerid, GearSlot_Skin[i]);
	}
}

HidePlayerGear(playerid)
{
	for(new i; i < 3; i++)
	{
		PlayerTextDrawHide(playerid, GearSlot_Head[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hand[i]);
		PlayerTextDrawHide(playerid, GearSlot_Tors[i]);
		PlayerTextDrawHide(playerid, GearSlot_Back[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hols[i]);
		PlayerTextDrawHide(playerid, GearSlot_Skin[i]);
	}
}

UpdatePlayerGear(playerid, show = 1)
{
	new
		tmp[ITM_MAX_NAME],
		itemid;


	itemid = INVALID_ITEM_ID;
	if(IsValidItem(itemid))
	{
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], "none");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 23);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Head[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		if(gPlayerArmedWeapon[playerid] != 0)
		{
			PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], WepData[gPlayerArmedWeapon[playerid]][WepName]);
			PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], WepData[gPlayerArmedWeapon[playerid]][WepModel]);
			PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
		}
		else
		{
			PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], "<Empty>");
			PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 19300);
		}
	}

	itemid = INVALID_ITEM_ID;
	if(IsValidItem(itemid))
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], "none");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 23);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Tors[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerBackpackItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Back[UI_ELEMENT_TILE], 0.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerHolsteredWeapon(playerid);
	if(0 < itemid < WEAPON_PARACHUTE)
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], "none");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], WepData[itemid][WepModel]);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hols[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerClothes(playerid);
	if(IsValidClothes(itemid))
	{
		GetClothesName(itemid, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Skin[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Skin[UI_ELEMENT_TILE], GetClothesModel(itemid));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Skin[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Skin[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Skin[UI_ELEMENT_TILE], 19300);
	}

	if(show)
		ShowPlayerGear(playerid);
}

public OnPlayerOpenInventory(playerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory app_OnPlayerOpenInventory
forward app_OnPlayerOpenInventory(playerid);

public OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerCloseInventory", "d", playerid);
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory app_OnPlayerCloseInventory
forward app_OnPlayerCloseInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer app_OnPlayerOpenContainer
forward app_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerCloseContainer(playerid, containerid)
{
	HidePlayerGear(playerid);

	return CallLocalFunction("app_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer app_OnPlayerCloseContainer
forward app_OnPlayerCloseContainer(playerid, containerid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		UpdatePlayerGear(playerid);
	}

	return CallLocalFunction("app_OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer app_OnPlayerTakeFromContainer
forward app_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerRemoveFromInventory(playerid, slotid)
{
	UpdatePlayerGear(playerid, 0);

	return CallLocalFunction("app_OnPlayerRemoveFromInventory", "dd", playerid, slotid);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnPlayerRemoveFromInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnPlayerRemoveFromInventory app_OnPlayerRemoveFromInventory
forward app_OnPlayerRemoveFromInventory(playerid, slotid);

public OnPlayerAddToInventory(playerid, itemid)
{
	UpdatePlayerGear(playerid, 0);

	return CallLocalFunction("app_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnPlayerAddToInventory app_OnPlayerAddToInventory
forward app_OnPlayerAddToInventory(playerid, itemid);

public OnItemRemovedFromPlayer(playerid, itemid)
{
	if(GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_CARRY)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	
	return CallLocalFunction("app_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnPlayerAddToInventory app_OnPlayerAddToInventory
forward app_OnPlayerAddToInventory(playerid, itemid);

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
	{
		Msg(playerid, YELLOW, "Head");
	}
	if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			new containerid = GetPlayerCurrentContainer(playerid);
			if(IsValidContainer(containerid))
			{
				AddItemToContainer(containerid, itemid);
				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
			else
			{
				if(GetItemTypeSize(GetItemType(itemid)) != ITEM_SIZE_SMALL)
				{
					ShowMsgBox(playerid, "That item is too big for your inventory", 3000, 140);
				}
				else
				{
					if(AddItemToInventory(playerid, itemid) == 1)
						ShowMsgBox(playerid, "Item added to inventory", 3000, 150);

					else
						ShowMsgBox(playerid, "Inventory full", 3000, 100);
				}
				UpdatePlayerGear(playerid);
				DisplayPlayerInventory(playerid);
			}
		}
		else if(gPlayerArmedWeapon[playerid] != 0)
		{
			new containerid = GetPlayerCurrentContainer(playerid);
			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					new str[CNT_MAX_NAME + 6];
					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowMsgBox(playerid, str, 3000, 150);
					return 1;
				}

				itemid = CreateItem(ItemType:gPlayerArmedWeapon[playerid], 0.0, 0.0, 0.0);

				SetItemExtraData(itemid, GetPlayerAmmo(playerid));
				AddItemToContainer(containerid, itemid);
				RemovePlayerWeapon(playerid, _:gPlayerArmedWeapon[playerid]);
				gPlayerArmedWeapon[playerid] = 0;

				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
			else
			{
				if(IsPlayerInventoryFull(playerid))
				{
					ShowMsgBox(playerid, "Inventory full", 3000, 150);
					return 1;
				}
				switch(gPlayerArmedWeapon[playerid])
				{
					case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
					{
						itemid = CreateItem(ItemType:gPlayerArmedWeapon[playerid], 0.0, 0.0, 0.0);

						SetItemExtraData(itemid, GetPlayerAmmo(playerid));
						AddItemToInventory(playerid, itemid);
						RemovePlayerWeapon(playerid, _:gPlayerArmedWeapon[playerid]);
						gPlayerArmedWeapon[playerid] = 0;

						ShowMsgBox(playerid, "Item added to inventory", 3000, 150);
					}
				}
				UpdatePlayerGear(playerid);
				DisplayPlayerInventory(playerid);
			}
		}
	}
	if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
	{
		Msg(playerid, YELLOW, "Torso");
	}
	if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerBackpackItem(playerid);

		if(IsValidItem(itemid))
		{
			if(GetPlayerCurrentContainer(playerid) == GetItemExtraData(itemid))
			{
				ClosePlayerContainer(playerid);
				DisplayPlayerInventory(playerid);
			}
			else
			{
				DisplayContainerInventory(playerid, GetItemExtraData(itemid));
			}
		}
	}
	if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
	{
		if(0 < GetPlayerHolsteredWeapon(playerid) < WEAPON_PARACHUTE)
		{
			new containerid = GetPlayerCurrentContainer(playerid);
			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					new str[CNT_MAX_NAME + 6];
					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowMsgBox(playerid, str, 3000, 150);
					return 1;
				}

				new itemid = CreateItem(ItemType:GetPlayerHolsteredWeapon(playerid), 0.0, 0.0, 0.0);

				SetItemExtraData(itemid, GetPlayerHolsteredWeaponAmmo(playerid));
				AddItemToContainer(containerid, itemid);
				RemoveHolsterWeapon(playerid);

				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
			else
			{
				if(IsPlayerInventoryFull(playerid))
				{
					ShowMsgBox(playerid, "Inventory full", 3000, 150);
					return 1;
				}
				switch(GetPlayerHolsteredWeapon(playerid))
				{
					case 2, 3, 5, 6, 7, 8, 15, 1, 4, 16..18, 22..24, 10..13, 26, 28, 32, 39..41, 43, 44, 45:
					{
						new itemid = CreateItem(ItemType:GetPlayerHolsteredWeapon(playerid), 0.0, 0.0, 0.0);

						SetItemExtraData(itemid, GetPlayerHolsteredWeaponAmmo(playerid));
						AddItemToInventory(playerid, itemid);
						RemoveHolsterWeapon(playerid);

						ShowMsgBox(playerid, "Item added to inventory", 3000, 150);
					}
				}
				UpdatePlayerGear(playerid);
				DisplayPlayerInventory(playerid);
			}
		}
	}
	if(playertextid == GearSlot_Skin[UI_ELEMENT_TILE])
	{
		Msg(playerid, YELLOW, "Clothes");
	}
	return 1;
}

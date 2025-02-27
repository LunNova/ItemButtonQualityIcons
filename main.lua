local addonName, addonTable = ...

---@class ItemButtonQualityIcons
ItemButtonQualityIcons = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0")

local EXPLORER, ADVENTURER, VETERAN, CHAMPION, HERO, MYTH, AWAKENED = 1, 2, 3, 4, 5, 6, 7
local AWAKENED_CRAFTED = -1

local bonusIdsToCategories = {}
local function assignRange(start, fin, track)
	for i = start, fin do
		bonusIdsToCategories[i] = track
	end
end

-- https://www.raidbots.com/static/data/live/bonuses.json
-- Dragonflight S4 bonus IDs
-- assignRange(10305, 10312, ADVENTURER)
-- assignRange(10313, 10320, CHAMPION)
-- assignRange(10321, 10328, EXPLORER)
-- assignRange(10329, 10334, HERO)
-- assignRange(10335, 10338, MYTH)
-- assignRange(10341, 10348, VETERAN)
-- assignRange(10407, 10418, AWAKENED) -- 12/12
-- assignRange(10490, 10503, AWAKENED) -- 14/14
-- assignRange(10951, 10964, AWAKENED) -- 14/14
-- assignRange(10249, 10249, AWAKENED_CRAFTED) -- awakened crafted
-- FIXME: figure out how to determine which crest type was used with a crafted item

-- The War Within S1 bonus IDs
-- assignRange(10290, 10297, ADVENTURER) -- 571-593
-- assignRange(10266, 10273, CHAMPION) -- 597-619
-- assignRange(10282, 10289, EXPLORER) -- 558-580
-- assignRange(10256, 10265, HERO) -- 610-626
-- assignRange(10257, 10260, MYTH) -- 623-639  //  10260 (623), 10259 (626), 10258 (629), 10257 (632), 10298 (636), 10299 (639)
-- assignRange(10298, 10299, MYTH) -- split up, big range
-- assignRange(10274, 10281, VETERAN) -- 584-606
-- Awakened: Not in raidbots export as of 20240913
-- I wonder how much of a PITA it would be to add most-recent past season as like. greyscaled icons.

-- The War Within S2 bonus IDs
assignRange(11950, 11957, ADVENTURER) -- 632, 610-629
assignRange(11977, 11984, CHAMPION) -- 636-658
assignRange(11942, 11949, EXPLORER) -- 597-619
assignRange(11985, 11990, HERO) -- 649-665
assignRange(11991, 11996, MYTH) -- 662-678
assignRange(11969, 11976, VETERAN) -- 623-645
assignRange(12071, 12084, AWAKENED) -- 636-678
-- TODO: (20250226) Add crafted gear? Maybe need to ask on Raidbots discord how to get info for this. Not blatantly obvious to me how to get the info needed.

local categoryEnum = {
	Explorer = "Explorer",
	Adventurer = "Adventurer",
	Veteran = "Veteran",
	Champion = "Champion",
	Hero = "Hero",
	Myth = "Myth",
	Awakened = "Awakened",
	Awakened_Crafted = "Awakened Crafted",
}

-- Item category data
-- depends on textures in ItemUpgradeQualityIcons
-- TODO: can it share data from that addon? it's in locals right now so I think it can't
local categoryDataTab = {
	[categoryEnum.Explorer] = {
		minLevel = 597,
		maxLevel = 619,
		color = ITEM_POOR_COLOR,
		icon = "|A:Professions-ChatIcon-Quality-Tier1:20:20|a ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons.tga:20:20:0:0:128:128:1:31:73:107|t ",
	},
	[categoryEnum.Adventurer] = {
		minLevel = 610,
		maxLevel = 632,
		color = WHITE_FONT_COLOR,
		icon = "|A:Professions-ChatIcon-Quality-Tier2:20:20|a ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons.tga:20:20:0:0:128:128:1:47:1:35|t ",
	},
	[categoryEnum.Veteran] = {
		minLevel = 623,
		maxLevel = 645,
		color = UNCOMMON_GREEN_COLOR,
		icon = "|A:Professions-ChatIcon-Quality-Tier3:20:20|a ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons.tga:20:20:0:0:128:128:49:85:1:35|t ",
	},
	[categoryEnum.Champion] = {
		minLevel = 636,
		maxLevel = 658,
		color = RARE_BLUE_COLOR,
		icon = "|A:Professions-ChatIcon-Quality-Tier4:20:20|a ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons.tga:20:20:0:0:128:128:87:121:1:35|t ",
	},
	[categoryEnum.Hero] = {
		minLevel = 649,
		maxLevel = 665,
		color = ITEM_EPIC_COLOR,
		icon = "|A:Professions-ChatIcon-Quality-Tier5:20:20|a ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons.tga:20:20:0:0:128:128:1:35:37:71|t ",
	},
	[categoryEnum.Myth] = {
		minLevel = 662,
		maxLevel = 678,
		color = ITEM_LEGENDARY_COLOR,
		icon = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons:20:20:0:0:128:128:86:122:42:78|t ",
		iconObsolete = "|TInterface\\AddOns\\ItemUpgradeQualityIcons\\ProfessionsQualityIcons:20:20:0:0:128:128:42:78:42:78|t ",
	},
	[categoryEnum.Awakened] = {
		minLevel = 636,
		maxLevel = 678,
		-- upgradeLevelBeeg = 14,
		-- maxLevelBeeg = 535,
		-- If there's no problems from commenting these, remove them next time this file is updated (>1 month from now)
		color = ITEM_LEGENDARY_COLOR,
		icon = "|A:ui-ej-icon-empoweredraid-large:20:20|a ",
		iconObsolete = "|A:ui-ej-icon-empoweredraid-large:20:20|a ",
	},
	-- [categoryEnum.Awakened_Crafted] = {
	-- 	minLevel = 489,
	-- 	maxLevel = 525,
	-- 	color = ITEM_LEGENDARY_COLOR,
	-- 	icon = "|A:ui-ej-icon-empoweredraid-large:20:20|a ",
	-- 	iconObsolete = "|A:ui-ej-icon-empoweredraid-large:20:20|a ",
	-- },
}

local categoryDataByIdx = {
	categoryDataTab[categoryEnum.Explorer],
	categoryDataTab[categoryEnum.Adventurer],
	categoryDataTab[categoryEnum.Veteran],
	categoryDataTab[categoryEnum.Champion],
	categoryDataTab[categoryEnum.Hero],
	categoryDataTab[categoryEnum.Myth],
	categoryDataTab[categoryEnum.Awakened],
}
local function GetUpgradeCategoryFromItemLink(itemLink)
	local itemLinkValues = StringSplitIntoTable(":", itemLink)
	local numBonusIDs = tonumber(itemLinkValues[14])

	if not numBonusIDs then
		return
	end
	for i = 1, numBonusIDs do
		local upgradeID = tonumber(itemLinkValues[14 + i])
		if upgradeID ~= nil then
			if bonusIdsToCategories[upgradeID] then
				return bonusIdsToCategories[upgradeID]
			end
		end
	end

	return nil
end

local itemSlotTable = {
	-- Source: http://wowwiki.wikia.com/wiki/ItemEquipLoc
	["INVTYPE_AMMO"] = { 0 },
	["INVTYPE_HEAD"] = { 1 },
	["INVTYPE_NECK"] = { 2 },
	["INVTYPE_SHOULDER"] = { 3 },
	["INVTYPE_BODY"] = { 4 },
	["INVTYPE_CHEST"] = { 5 },
	["INVTYPE_ROBE"] = { 5 },
	["INVTYPE_WAIST"] = { 6 },
	["INVTYPE_LEGS"] = { 7 },
	["INVTYPE_FEET"] = { 8 },
	["INVTYPE_WRIST"] = { 9 },
	["INVTYPE_HAND"] = { 10 },
	["INVTYPE_FINGER"] = { 11, 12 },
	["INVTYPE_TRINKET"] = { 13, 14 },
	["INVTYPE_CLOAK"] = { 15 },
	["INVTYPE_WEAPON"] = { 16, 17 },
	["INVTYPE_SHIELD"] = { 17 },
	["INVTYPE_2HWEAPON"] = { 16 },
	["INVTYPE_WEAPONMAINHAND"] = { 16 },
	["INVTYPE_WEAPONOFFHAND"] = { 17 },
	["INVTYPE_HOLDABLE"] = { 17 },
	["INVTYPE_RANGED"] = { 18 },
	["INVTYPE_THROWN"] = { 18 },
	["INVTYPE_RANGEDRIGHT"] = { 18 },
	["INVTYPE_RELIC"] = { 18 },
	["INVTYPE_TABARD"] = { 19 },
	["INVTYPE_BAG"] = { 20, 21, 22, 23 },
	["INVTYPE_QUIVER"] = { 20, 21, 22, 23 },
}

function PawnIsContainerItemAnUpgrade(bagID, slot)
	local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
	if not itemInfo or not itemInfo.stackCount then
		return false
	end -- If the stack count is 0, it's clearly not an upgrade
	if not itemInfo.hyperlink then
		return nil
	end -- If we didn't get an item link, but there's an item there, try again later

	--print("checking ", itemInfo.hyperlink)
	local _, _, _, invType = C_Item.GetItemInfoInstant(itemInfo.hyperlink)

	local invSlots = invType and itemSlotTable[invType] or nil
	if not invSlots then -- not equippable
		--print("not equippable with invType ", invType)
		return false
	end

	local category = GetUpgradeCategoryFromItemLink(itemInfo.hyperlink)
	--print("bag item ", itemInfo.hyperlink, " has category ", category)
	if not category or category < 0 then
		return false
	end

	for _, slot in ipairs(invSlots) do
		local equippedLink = GetInventoryItemLink("player", slot)
		local equippedCategory = equippedLink and GetUpgradeCategoryFromItemLink(equippedLink) or nil

		if equippedCategory == nil then
			if category ~= nil then
				return true
			end
		else
			--print("equipped item ", equippedLink, " has category ", equippedCategory)
			if equippedCategory < category then
				return true
			end
		end
	end

	return false
end

local UpdateButtonFromItem

local function CleanButton(button)
	if button.ibqi then
		button.ibqi:SetText("")
		button.ibqi:Hide()
	end
end
local function AddCategoryToButton(button, item)
	if not button or not item or not item.GetItemLink then
		return
	end

	-- local r, g, b = GetItemQualityColor(db.color and details.quality or 1)
	local category = GetUpgradeCategoryFromItemLink(item:GetItemLink())
	local message = nil
	if category and categoryDataByIdx[category] then
		message = categoryDataByIdx[category].icon:gsub("%s+", "")
	end
	if message then
		button.ibqi:SetText(message)
		button.ibqi:SetTextColor(1, 1, 1)
		button.ibqi:Show()
	else
		button.ibqi:Hide()
	end
end

local function fontBg(p, fs)
	local f = p:CreateTexture()
	f:SetTexture("Interface/BUTTONS/WHITE8X8")
	f:SetVertexColor(0, 0, 0.25)
	f:SetAlpha(0.5)
	f:SetAllPoints(fs)
end

local function PrepareItemButton(button)
	if not button.ibqi then
		local overlayFrame = CreateFrame("FRAME", nil, button)
		overlayFrame:SetAllPoints()
		overlayFrame:SetFrameLevel(button:GetFrameLevel() + 1)
		button.ibqioverlay = overlayFrame

		button.ibqi = overlayFrame:CreateFontString(nil, "OVERLAY")
		button.ibqi:SetFontObject(NumberFont_Outline_Med)
		button.ibqi:Hide()
		button.ibqi:ClearAllPoints()
		button.ibqi:SetPoint("TOPLEFT")
		button.ibqi:SetShadowColor(0.1, 0.1, 0.2)
		fontBg(overlayFrame, button.ibqi)
	end
	button.ibqioverlay:SetFrameLevel(button:GetFrameLevel() + 1)
end
function UpdateButtonFromItem(button, item, variant)
	if not item or item:IsItemEmpty() then
		return
	end
	item:ContinueOnItemLoad(function()
		PrepareItemButton(button)
		AddCategoryToButton(button, item)
	end)
	return true
end

local ignoredSlots = {
	[INVSLOT_TABARD] = true,
	[INVSLOT_BODY] = true,
}

local function UpdateItemSlotButton(button, unit)
	CleanButton(button)
	local slotID = button:GetID()

	if slotID >= INVSLOT_FIRST_EQUIPPED and slotID <= INVSLOT_LAST_EQUIPPED and not ignoredSlots[slotID] then
		local item
		if unit == "player" then
			item = Item:CreateFromEquipmentSlot(slotID)
		else
			local itemID = GetInventoryItemID(unit, slotID)
			local itemLink = GetInventoryItemLink(unit, slotID)
			if itemLink or itemID then
				item = itemLink and Item:CreateFromItemLink(itemLink) or Item:CreateFromItemID(itemID)
			end
		end
		UpdateButtonFromItem(button, item)
	end
end

local db = {
	loot = true,
	tooltip = false,
	flyout = true,
	bags = true,
}

local function pcall_log(wrapped)
	return wrapped
	-- return function(...)
	-- 	local args = { ... }
	-- 	local ok, err = pcall(function()
	-- 		wrapped(unpack(args))
	-- 	end)
	-- 	if not ok then
	-- 		print(err)
	-- 	end
	-- end
end

function ItemButtonQualityIcons:OnInitialize() end

function ItemButtonQualityIcons:OnEnable()
	-- Hook character frame item slot updates
	-- works for blizzard and elvui
	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		UpdateItemSlotButton(button, "player")
	end)

	-- Bags:
	local function UpdateContainerButton(button, bag, slot)
		CleanButton(button)
		if not db.bags then
			return
		end
		local item = Item:CreateFromBagAndSlot(bag, slot or button:GetID())
		UpdateButtonFromItem(button, item, "bags")
	end

	local update = function(frame)
		for _, itemButton in frame:EnumerateValidItems() do
			local ib, bag, slot = itemButton, itemButton:GetBagID(), itemButton:GetID()
			-- print("Updating ", ib, bag, slot)
			UpdateContainerButton(ib, bag, slot)
		end

		if ElvUI then
			local E, L, V, P, G = unpack(ElvUI)
			local B = E:GetModule("Bags")
			local bf = B.BagFrame
			for _, bagID in next, bf.BagIDs do
				if bagID and bf.Bags[bagID] and bf.ContainerHolderByBagID[bagID] then
					local holder = bf.ContainerHolderByBagID[bagID]

					local slotMax = C_Container.GetContainerNumSlots(bagID)
					for slotID = 1, slotMax do
						local bag = bf.Bags[bagID]
						local slot = bag and bag[slotID]
						if slot then
							UpdateContainerButton(slot, bagID, slotID)
						end
					end
				end
			end
		end
	end
	if _G.ContainerFrame_Update then
		hooksecurefunc(
			"ContainerFrame_Update",
			pcall_log(function(container)
				local bag = container:GetID()
				local name = container:GetName()
				for i = 1, container.size, 1 do
					local button = _G[name .. "Item" .. i]
					UpdateContainerButton(button, bag)
				end
			end)
		)
	else
		-- can't use ContainerFrameUtil_EnumerateContainerFrames because it depends on the combined bags setting
		hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", pcall_log(update))
		for _, frame in ipairs((ContainerFrameContainer or UIParent).ContainerFrames) do
			hooksecurefunc(frame, "UpdateItems", pcall_log(update))
		end
	end

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag then
			UpdateContainerButton(button, button:GetParent():GetID())
		end
	end)

	-- hook loot frame
	if _G.LootFrame_UpdateButton then
		-- Classic
		hooksecurefunc("LootFrame_UpdateButton", function(index)
			local button = _G["LootButton" .. index]
			if not button then
				return
			end
			CleanButton(button)
			if not db.loot then
				return
			end
			-- ns.Debug("LootFrame_UpdateButton", button:IsEnabled(), button.slot, button.slot and GetLootSlotLink(button.slot))
			if button:IsEnabled() and button.slot then
				local link = GetLootSlotLink(button.slot)
				if link then
					UpdateButtonFromItem(button, Item:CreateFromItemLink(link), "loot")
				end
			end
		end)
	else
		-- Dragonflight
		local function handleSlot(frame)
			if not frame.Item then
				return
			end
			CleanButton(frame.Item)
			if not db.loot then
				return
			end
			local data = frame:GetElementData()
			if not (data and data.slotIndex) then
				return
			end
			local link = GetLootSlotLink(data.slotIndex)
			if link then
				UpdateButtonFromItem(frame.Item, Item:CreateFromItemLink(link), "loot")
			end
		end
		LootFrame.ScrollBox:RegisterCallback("OnUpdate", function(...)
			LootFrame.ScrollBox:ForEachFrame(handleSlot)
		end)
	end

	-- Tooltip - maybe skip this since is already there?
	local OnTooltipSetItem = function(self)
		if not db.tooltip or not self or not self.GetItem then
			return
		end
		local _, itemLink = self:GetItem()
		if not itemLink then
			return
		end
		local item = Item:CreateFromItemLink(itemLink)
		if item:IsItemEmpty() then
			return
		end
		item:ContinueOnItemLoad(function()
			self:AddLine(ITEM_LEVEL:format(item:GetCurrentItemLevel()))
		end)
	end
	if _G.C_TooltipInfo then
		-- Cata-classic has TooltipDataProcessor, but doesn't actually use the new tooltips
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
	else
		GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
		ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
		-- This is mostly world quest rewards:
		if GameTooltip.ItemTooltip then
			GameTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
		end
	end

	-- Equipment flyout in character frame

	if _G.EquipmentFlyout_DisplayButton then
		local function ItemFromEquipmentFlyoutDisplayButton(button)
			local flyoutSettings = EquipmentFlyoutFrame.button:GetParent().flyoutSettings
			if flyoutSettings.useItemLocation then
				local itemLocation = button:GetItemLocation()
				if itemLocation then
					return Item:CreateFromItemLocation(itemLocation)
				end
			else
				local location = button.location
				if not location then
					return
				end
				if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
					return
				end
				local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
				if bags then
					return Item:CreateFromBagAndSlot(bag, slot)
				elseif not voidStorage then -- player or bank
					return Item:CreateFromEquipmentSlot(slot)
				else
					local itemID = EquipmentManager_GetItemInfoByLocation(location)
					if itemID then
						return Item:CreateFromItemID(itemID)
					end
				end
			end
		end
		hooksecurefunc("EquipmentFlyout_UpdateItems", function()
			local flyoutSettings = EquipmentFlyoutFrame.button:GetParent().flyoutSettings
			for i, button in ipairs(EquipmentFlyoutFrame.buttons) do
				CleanButton(button)
				if db.flyout and button:IsShown() then
					local item = ItemFromEquipmentFlyoutDisplayButton(button)
					if item then
						UpdateButtonFromItem(button, item, "character")
					end
				end
			end
		end)
	end

	if ElvUI then
		local E, L, V, P, G = unpack(ElvUI)
		local B = E:GetModule("Bags")
		hooksecurefunc(B, "UpdateSlot", function(self, frame, bagID, slotID)
			if frame.Bags[bagID] and frame.Bags[bagID][slotID] then
				UpdateContainerButton(frame.Bags[bagID][slotID], bagID, slotID)
			end
		end)

		hooksecurefunc(B, "Layout", function(self, isBank)
			--print("bag hook (bank: ", isBank, ")")

			hooksecurefunc(_G.ContainerFrameCombinedBags, "UpdateItems", update)
			for bagID = 1, NUM_CONTAINER_FRAMES do
				hooksecurefunc(_G["ContainerFrame" .. bagID], "UpdateItems", update)
			end
		end)
	end
end

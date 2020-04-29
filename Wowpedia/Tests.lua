-- no unit tests yet
local function DumpApiList(apiType)
	local apiTable = APIDocumentation:GetAPITableByTypeName(apiType)
	for i, apiInfo in ipairs(apiTable) do
		print(i, apiInfo.Name)
	end
end
-- DumpApiList("system")


local function TestFunction(name)
	for _, func in ipairs(APIDocumentation.functions) do
		-- print(func:GetFullName(false, false))
		local fullName
		if func.System.Namespace then
			fullName = format("%s.%s", func.System.Namespace, func.Name)
		else
			fullName = func.Name
		end
		if fullName == name then
			print(Wowpedia:GetPageText(func))
			break
		end
	end
end

-- TestFunction("C_Calendar.CanSendInvite") -- no arguments, one return value
-- TestFunction("C_Calendar.EventSetTitle") -- one argument, no return values
-- TestFunction("C_AuctionHouse.MakeItemKey") -- three optional args
-- TestFunction("C_Calendar.EventSetClubId") -- first argument optional
-- TestFunction("C_ArtifactUI.GetAppearanceInfo") -- two optional returns
-- TestFunction("C_Club.CreateClub") -- optional arguments in middle

-- TestFunction("C_ChatInfo.SendAddonMessage") -- string arguments
-- TestFunction("UnitPowerDisplayMod") -- enum transclude argument
-- TestFunction("C_Calendar.GetClubCalendarEvents") -- structure transclude arguments
-- TestFunction("C_AccountInfo.IsGUIDBattleNetAccountType") -- bool return
-- TestFunction("C_AuctionHouse.GetItemKeyInfo") -- struct inline returns
-- TestFunction("C_ActionBar.FindFlyoutActionButtons") -- number[] return
-- TestFunction("C_AuctionHouse.GetTimeLeftBandInfo") -- transclude argument
-- TestFunction("C_CovenantSanctumUI.GetSanctumType") -- inline enum return

-- TestFunction("C_AreaPoiInfo.GetAreaPOISecondsLeft") -- documentation
-- TestFunction("C_ArtifactUI.GetEquippedArtifactNumRelicSlots") -- argument documentation
-- TestFunction("C_ArtifactUI.GetMetaPowerInfo") -- StrideIndex
-- TestFunction("C_MapExplorationInfo.GetExploredMapTextures") -- structure in structure


local function TestEvent(name)
	for _, event in ipairs(APIDocumentation.events) do
		-- print(event:GetFullName(false, false))
		if event.LiteralName == name then
			print(Wowpedia:GetPageText(event))
			break
		end
	end
end

-- TestEvent("ACTIONBAR_SHOWGRID") -- no payload
-- TestEvent("ITEM_SEARCH_RESULTS_UPDATED") -- struct, nilable
-- TestEvent("TRACKED_ACHIEVEMENT_UPDATE") -- optional params
-- TestEvent("AUCTION_HOUSE_AUCTION_CREATED") -- documentation
-- TestEvent("CLUB_MESSAGE_HISTORY_RECEIVED") -- documentation in payload
-- TestEvent("CONTRIBUTION_CHANGED") -- StrideIndex
-- TestEvent("HONOR_XP_UPDATE") -- Unit system

local function TestTable(name)
	local apiTable = Wowpedia.complexTypes[name]
	-- print(Wowpedia:GetTableTransclude(apiTable))
	print(Wowpedia:GetTableText(apiTable, true))
end

-- enums
-- TestTable("UIWidgetVisualizationType")
-- TestTable("AuctionHouseTimeLeftBand") -- anonymous system
-- TestTable("PowerType") -- Unit system

-- structures
-- TestTable("BidInfo") -- struct and enum
-- TestTable("ArtifactArtInfo") -- mixins
-- TestTable("ItemKey") -- nilable, default
-- TestTable("AuctionHouseBrowseQuery") -- innertype enum
-- TestTable("ItemSearchResultInfo") -- innertype string
-- TestTable("ItemKeyInfo") -- nilable, bool
-- TestTable("ClubMessageIdentifier") -- documentation in field
-- TestTable("QuestWatchConsts") -- constants

-- missing
-- TestTable("CalendarTime")
-- TestTable("AppearanceSourceInfo")
-- TestTable("GuildTabardInfo")


local function CountKeys(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function GetComplexTypeStats()
	-- why not use this anyway
	local knownTypes = CreateFromMixins(Wowpedia.basicTypes, Wowpedia.complexTypes)
	local uniqueTypes, missingTypes = {}, {}
	local referencedTypes = {}

	for _, field in pairs(APIDocumentation.fields) do
		-- find unique types
		if not Wowpedia.basicTypes[field.Type] then
			uniqueTypes[field.Type] = true
		end
		-- find missing types
		if not knownTypes[field.Type] then
			missingTypes[field.Type] = true
		end
		-- find amount of times types are referenced
		local parent = field.Function or field.Event or field.Table
		if not Wowpedia.basicTypes[field.Type] and parent.Type ~= "Enumeration" then
			referencedTypes[field.Type] = (referencedTypes[field.Type] or 0) + 1
		end
	end

	print("# undocumented types:")
	for name in pairs(missingTypes) do
		print(name)
	end

	print("\n# referenced types:")
	for name, amount in pairs(referencedTypes) do
		if amount > 1 then
			print(amount, name)
		end
	end

	-- huh this is confusing
	print("\namount of unique complex types (via Fields):", CountKeys(uniqueTypes)) -- 285
	print("amount of unique complex types (via Tables):", CountKeys(Wowpedia.complexTypes)) -- 364
	print("amount of unique referenced types (via Fields):", CountKeys(referencedTypes)) -- 237
	print("amount of unknown types (via Fields):", CountKeys(missingTypes)) -- 4
end
-- GetComplexTypeStats()

-- APIDocumentation:HandleSlashCommand("stats")


local function PrintDocumentation(apiType)
	for _, apiTable in pairs(APIDocumentation[apiType]) do
		if apiTable.Documentation then
			if apiType == "fields" then
				local parent = apiTable.Function or apiTable.Event or apiTable.Table
				print(parent.Type, parent.Name, apiTable.Name, apiTable.Documentation[1])
			else
				print(apiTable.Name, apiTable.Documentation[1])
			end
		end
	end
end
-- PrintDocumentation("functions")
-- PrintDocumentation("events")
-- PrintDocumentation("fields")


local function FindSignaturesWithMiddleOptionals(apiType, paramTbl, apiName)
	for _, apiTable in ipairs(APIDocumentation[apiType]) do
		local optional
		if apiTable[paramTbl] then
			for _, param in ipairs(apiTable[paramTbl]) do
				if param.Nilable then
					optional = true
				else
					if optional then
						print(apiTable[apiName])
						break
					end
				end
			end
		end
	end
end
-- FindSignaturesWithMiddleOptionals("functions", "Arguments", "Name")
-- FindSignaturesWithMiddleOptionals("events", "Payload", "LiteralName")

-- CreateClub
-- GetInvitationCandidates
-- GetRuneforgeModifierInfo

-- BONUS_ROLL_RESULT
-- ENTITLEMENT_DELIVERED
-- RAF_ENTITLEMENT_DELIVERED
-- VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE


local function FindUnusedTables()
	for _, system in ipairs(APIDocumentation.systems) do
		for _, apiTable in pairs(system.Tables) do
			local isTransclude = Wowpedia.complexRefs[apiTable.Name]
			if not isTransclude then
				print(apiTable.Name)
			end
		end
	end
end
-- FindUnusedTables()

-- ClubFinderApplicationUpdateType
-- ClubFinderSettingFlags
-- ContributionAppearanceFlags
-- ItemTryOnReason
-- QuestTag
-- SuperTrackingType
-- TooltipSide
-- TooltipTextureAnchor
-- TooltipTextureRelativeRegion
-- TransmogSource
-- UIMapSystem
-- UiwIdgetFlag
-- WidgetCurrencyClass


local function FindMissingTables()
	local tbl = {}
	for _, field in ipairs(APIDocumentation.fields) do
		local apiType = field.InnerType or field.Type
		local isComplex = Wowpedia.complexTypes[apiType]
		if not Wowpedia.basicTypes[apiType] and not isComplex then
			tbl[apiType] = true
		end
	end
	for name in pairs(tbl) do
		print(name)
	end
end
-- FindMissingTables()

-- AppearanceSourceInfo
-- BountyInfo
-- CalendarTime
-- GarrisonTalentTreeInfo
-- GuildTabardInfo
-- ItemLevelTier
-- OptionalReagentInfo
-- QueueSpecificInfo
-- RuneforgeLegendaryCraftDescription
-- RuneforgePower


local function FindIncongruentSystemNames()
	for _, system in ipairs(APIDocumentation.systems) do
		if system.Namespace then
			if system.Namespace:gsub("C_", "") ~= system.Name then
				print(system.Namespace, system.Name)
			end
		end
	end
end
-- FindIncongruentSystemNames()

-- C_AnimaDiversion, AnimaDiversionInfo
-- C_CVar, CVarScripts
-- C_ChallengeMode, ChallengeModeInfo
-- C_ChromieTime, ChromieTimeInfo
-- C_ClubFinder, ClubFinderInfo
-- C_Commentator, CommentatorFrame
-- C_CurrencyInfo, CurrencySystem
-- C_Garrison, GarrisonInfo
-- C_Navigation, InGameNavigation
-- C_ItemInteraction, ItemInteractionUI
-- C_Mail, MailInfo
-- C_Map, MapUI
-- C_MythicPlus, MythicPlusInfo
-- C_PetJournal, PetJournalInfo
-- C_PlayerInfo, PlayerLocationInfo
-- C_PvP, PvpInfo
-- C_QuestLine, QuestLineUI
-- C_TaskQuest, QuestTaskInfo
-- C_Reputation, ReputationInfo
-- C_Social, SocialInfo
-- C_SuperTrack, SuperTrackManager
-- C_System, SystemInfo
-- C_Texture, TextureUtils
-- C_Transmog, Transmogrify
-- C_TransmogCollection, Transmogrify
-- C_TransmogSets, Transmogrify
-- C_Macro, UIMacros
-- C_VideoOptions, Video
-- C_VignetteInfo, Vignette
-- C_CampaignInfo, WarCampaign
-- Expansion
-- Unit

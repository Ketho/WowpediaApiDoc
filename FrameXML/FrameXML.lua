local m = {}

local missing = {
	-- ["CurrencyConstantsDocumentation.lua"] = true, -- 9.0.2 (36165)
}

-- maybe should just load all files in folder instead of TOC
-- these seems like old documentation, but the structures are still used in other docs
local not_in_toc = {
	["BountiesDocumentation.lua"] = true, -- 9.0.1 (34615); C_Bounties -> C_QuestLog
	["CharacterCustomizationDocumentation.lua"] = true, -- 9.0.1 (34615); C_CharacterCustomization -> C_BarberShop
}

-- these files share the same Namespace. they do have a different Name
-- apparently both Name and Namespace are not unique between files
local shared_namespaces = {
	["PlayerInfoDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerInfo"
	["PlayerLocationDocumentation.lua"] = "C_PlayerInfo", -- Name = "PlayerLocationInfo"
}

local function LoadApiDocFile(base, line)
	local file = assert(loadfile(base.."/Blizzard_APIDocumentation/"..line))
	file()
end

function m:LoadApiDocs(base)
	require(base.."/Compat")
	local toc = io.open(base.."/Blizzard_APIDocumentation/Blizzard_APIDocumentation.toc")
	for line in toc:lines() do
		if line:find("%.lua") and not missing[line] then
			LoadApiDocFile(base, line)
		end
	end
	for luaFile in pairs(not_in_toc) do
		LoadApiDocFile(base, luaFile)
	end
	toc:close()
	require(base.."/MissingDocumentation")
end

return m

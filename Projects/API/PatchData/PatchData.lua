local Util = require("Util/Util")
local PatchData = require("Projects/API/PatchData/LoadFiles")

local OUT = "out/lua/API_info__apipatch.lua"
local m = {}

local underscorePatterns = {
	"^C_",
	"^EJ_",
	"^KBArticle_",
	"^KBQuery_",
	"^KBSystem_",
	"^Sound_ChatSystem_",
}

local underscore = {
	CombatLog_Object_IsA = true,
	DeathRecap_GetEvents = true,
	DeathRecap_HasEvents = true,
	FrameXML_Debug = true,
}

-- 7.3.0, 7.3.2, 7.3.5, 8.0.1 dumps include framexml
-- also try to filter lua api and C_namespace tables
function m:IsFrameXML(s)
	if self.LuaAPI[s] then
		return true
	elseif underscore[s] then
		return false
	elseif s:find("^C_") and not s:find("%.") then
		return true
	elseif s:find("_") then
		for _, pattern in pairs(underscorePatterns) do
			if s:find(pattern) then
				return false
			end
		end
		return true
	end
end

function m:GetFirstSeen()
	local t = {}
	for _, patch in pairs(PatchData) do
		for name in pairs(patch.data) do
			if not t[name] then
				t[name] = patch.version
			end
		end
	end
	return t
end

function m:main()
	local firstSeen = self:GetFirstSeen()
	local file = io.open(OUT, "w")
	file:write("local data = {\n")
	for _, name in pairs(Util:SortTable(firstSeen)) do
		local patch = firstSeen[name]
		if not self:IsFrameXML(name) then
			file:write(string.format('\t["%s"] = "%s",\n', name, patch))
		end
	end
	file:write("}\n\nreturn data\n")
	file:close()
end

m.LuaAPI = {
	["abs"] = true,
	["acos"] = true,
	["asin"] = true,
	["assert"] = true,
	["atan"] = true,
	["atan2"] = true,
	["bit.arshift"] = true,
	["bit.band"] = true,
	["bit.bnot"] = true,
	["bit.bor"] = true,
	["bit.bxor"] = true,
	["bit.lshift"] = true,
	["bit.mod"] = true,
	["bit.rshift"] = true,
	["ceil"] = true,
	["collectgarbage"] = true,
	["coroutine.create"] = true,
	["coroutine.resume"] = true,
	["coroutine.running"] = true,
	["coroutine.status"] = true,
	["coroutine.wrap"] = true,
	["coroutine.yield"] = true,
	["cos"] = true,
	["date"] = true,
	["deg"] = true,
	["difftime"] = true,
	["error"] = true,
	["exp"] = true,
	["fastrandom"] = true,
	["floor"] = true,
	["foreach"] = true,
	["foreachi"] = true,
	["format"] = true,
	["frexp"] = true,
	["gcinfo"] = true,
	["getfenv"] = true,
	["getmetatable"] = true,
	["getn"] = true,
	["gmatch"] = true,
	["gsub"] = true,
	["ipairs"] = true,
	["ldexp"] = true,
	["loadstring"] = true,
	["log"] = true,
	["log10"] = true,
	["math.abs"] = true,
	["math.acos"] = true,
	["math.asin"] = true,
	["math.atan"] = true,
	["math.atan2"] = true,
	["math.ceil"] = true,
	["math.cos"] = true,
	["math.cosh"] = true,
	["math.deg"] = true,
	["math.exp"] = true,
	["math.floor"] = true,
	["math.fmod"] = true,
	["math.frexp"] = true,
	["math.ldexp"] = true,
	["math.log"] = true,
	["math.log10"] = true,
	["math.max"] = true,
	["math.min"] = true,
	["math.modf"] = true,
	["math.pow"] = true,
	["math.rad"] = true,
	["math.random"] = true,
	["math.sin"] = true,
	["math.sinh"] = true,
	["math.sqrt"] = true,
	["math.tan"] = true,
	["math.tanh"] = true,
	["max"] = true,
	["min"] = true,
	["mod"] = true,
	["newproxy"] = true,
	["next"] = true,
	["pairs"] = true,
	["pcall"] = true,
	["rad"] = true,
	["random"] = true,
	["rawequal"] = true,
	["rawget"] = true,
	["rawset"] = true,
	["select"] = true,
	["setfenv"] = true,
	["setmetatable"] = true,
	["sin"] = true,
	["sort"] = true,
	["sqrt"] = true,
	["strbyte"] = true,
	["strchar"] = true,
	["strcmputf8i"] = true,
	["strconcat"] = true,
	["strfind"] = true,
	["string.byte"] = true,
	["string.char"] = true,
	["string.find"] = true,
	["string.format"] = true,
	["string.gfind"] = true,
	["string.gmatch"] = true,
	["string.gsub"] = true,
	["string.join"] = true,
	["string.len"] = true,
	["string.lower"] = true,
	["string.match"] = true,
	["string.rep"] = true,
	["string.reverse"] = true,
	["string.split"] = true,
	["string.sub"] = true,
	["string.trim"] = true,
	["string.upper"] = true,
	["strjoin"] = true,
	["strlen"] = true,
	["strlenutf8"] = true,
	["strlower"] = true,
	["strmatch"] = true,
	["strrep"] = true,
	["strrev"] = true,
	["strsplit"] = true,
	["strsub"] = true,
	["strtrim"] = true,
	["strupper"] = true,
	["table.concat"] = true,
	["table.foreach"] = true,
	["table.foreachi"] = true,
	["table.getn"] = true,
	["table.insert"] = true,
	["table.maxn"] = true,
	["table.remove"] = true,
	["table.removemulti"] = true,
	["table.setn"] = true,
	["table.sort"] = true,
	["table.wipe"] = true,
	["tan"] = true,
	["time"] = true,
	["tinsert"] = true,
	["tonumber"] = true,
	["tostring"] = true,
	["tremove"] = true,
	["type"] = true,
	["unpack"] = true,
	["wipe"] = true,
	["xpcall"] = true,
}

m:main()

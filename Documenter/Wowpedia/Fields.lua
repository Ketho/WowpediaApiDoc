Wowpedia.basicTypes = {
	bool = "boolean",
	number = "number",
	string = "string",
	table = "table",
}

Wowpedia.complexTypes = {}
Wowpedia.complexRefs = {}
Wowpedia.subTables = {}

-- InitComplexTableTypes
for _, apiInfo in ipairs(APIDocumentation.tables) do
	Wowpedia.complexTypes[apiInfo.Name] = apiInfo
end

-- InitComplexFieldRefs
for _, field in ipairs(APIDocumentation.fields) do
	local parent = field.Function or field.Event or field.Table
	local typeName = field.InnerType or field.Type
	if not Wowpedia.basicTypes[typeName] and parent.Type ~= "Enumeration" then
		Wowpedia.complexRefs[typeName] = (Wowpedia.complexRefs[typeName] or 0) + 1
	end
end

-- InitSubtables
for _, apiTable in ipairs(APIDocumentation.tables) do
	if apiTable.Type == "Structure" then
		for _, field in pairs(apiTable.Fields) do
			Wowpedia.subTables[field.InnerType or field.Type] = true
		end
	end
end

local paramFs = ";%s : %s"
local colorFs = '<font color="#ecbc2a">%s</font>' -- from ddcorkum api template
local tooltipFs = '<span title="%s">%s</span>'

local function HasMiddleOptionals(paramTbl)
	local optional
	for _, param in ipairs(paramTbl) do
		if param.Nilable then
			optional = true
		else
			if optional then
				return true
			end
		end
	end
end

function Wowpedia:GetSignature(apiTable, apiType)
	local tbl = {}
	local paramTbl = apiTable[apiType]
	if HasMiddleOptionals(paramTbl) then
		for _, param in ipairs(paramTbl) do
			local name = param.Name
			if param:IsOptional() then
				name = format("[%s]", name)
			end
			tinsert(tbl, name)
		end
		return table.concat(tbl, ", ")
	else
		local optionalFound
		for _, param in ipairs(paramTbl) do
			local name = param.Name
			if param:IsOptional() and not optionalFound then
				optionalFound = true
				name = format("[%s", name)
			end
			tinsert(tbl, name)
		end
		local str = table.concat(tbl, ", ")
		return optionalFound and str:gsub(", %[", " [, ").."]" or str
	end
end

function Wowpedia:GetParameters(params, isArgument)
	local tbl = {}
	for _, param in ipairs(params) do
		if param:GetStrideIndex() == 1 then
			tinsert(tbl, format("(Variable %s)", isArgument and "arguments" or "returns"))
		end
		tinsert(tbl, paramFs:format(param.Name, self:GetPrettyType(param, isArgument)))
		local complexTable, isTransclude = self:GetComplexTypeInfo(param)
		if complexTable then
			if isTransclude then
				local transclude = format("{{:%s|nocaption=1}}", self:GetTranscludeBase(complexTable))
				tinsert(tbl, transclude)
			else
				tinsert(tbl, self:GetTableText(complexTable))
			end
		end
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetPrettyType(apiTable, isArgument)
	local complexType = self.complexTypes[apiTable.Type]
	local str
	if apiTable.Type == "table" then
		if apiTable.Mixin then
			str = format("[[%s]]", apiTable.Mixin) -- wiki link
		elseif apiTable.InnerType then
			local complexInnertype = self.complexTypes[apiTable.InnerType]
			if self.basicTypes[apiTable.InnerType] then
				str = colorFs:format(self.basicTypes[apiTable.InnerType]).."[]"
			elseif complexInnertype then
				str = colorFs:format(complexInnertype:GetFullName(false, false)).."[]"
			else
				error("Unknown InnerType: "..apiTable.InnerType)
			end
		else
			str = "Unknown"
		end
	elseif self.basicTypes[apiTable.Type] then
		str = colorFs:format(self.basicTypes[apiTable.Type])
	elseif complexType then
		str = colorFs:format(complexType:GetFullName(false, false))
	else
		error("Unknown Type: "..apiTable.Type)
	end
	if apiTable.Nilable then
		str = tooltipFs:format(isArgument and "optional" or "nilable", str.."?")
	end
	-- nilable can be false even if default is defined
	if apiTable.Default ~= nil then
		str = format("%s (Default = %s)", str, tostring(apiTable.Default))
	end
	if apiTable.Documentation then
		str = str.." - "..table.concat(apiTable.Documentation, "; ")
	end
	return str
end

function Wowpedia:GetComplexTypeInfo(apiTable)
	local typeName = apiTable.InnerType or apiTable.Type
	if not self.basicTypes[typeName] then
		local complexTable = self.complexTypes[typeName]
		local isTransclude = (self.complexRefs[typeName] or 0) > 1
		return complexTable, isTransclude
	end
end

function Wowpedia:FindMissingTypes()
	local missingTypes = {}
	for _, field in ipairs(APIDocumentation.fields) do
		local parent = field.Function or field.Event or field.Table
		local typeName = field.InnerType or field.Type
		if not self.basicTypes[typeName] and parent.Type ~= "Enumeration" then
			if not self.complexTypes[typeName] then
				missingTypes[typeName] = true
			end
		end
	end
	return missingTypes
end

function Wowpedia:HasMissingTypes()
	local missingTypes = self:FindMissingTypes()
	if next(missingTypes) then
		print("Found missing complex types, please add them to FrameXML\\MissingDocumentation.lua")
		for complexType in pairs(missingTypes) do
			print("Missing:", complexType)
		end
		return true
	end
end

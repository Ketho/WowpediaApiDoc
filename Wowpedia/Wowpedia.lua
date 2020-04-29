Wowpedia = {}
require "Wowpedia/Functions"
require "Wowpedia/Events"
require "Wowpedia/Tables"
require "Wowpedia/Fields"

local LATEST_PATCH = "9.0.1"

function Wowpedia:GetPageText(apiTable)
	local tbl = {}
	local params
	if apiTable.Type == "Function" then
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		params = self:GetEventText(apiTable)
	end
	local apiTemplate = self:GetTemplateInfo(apiTable)
	local sections = {
		apiTemplate,
		self:GetDescription(apiTable),
		params,
		self:GetPatchSection(),
		self:GetElinkSection(apiTable),
	}
	for _, v in pairs(sections) do
		tinsert(tbl, v)
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetDescription(apiTable)
	if apiTable.Documentation then
		return table.concat(apiTable.Documentation, "; ")
	end
	return "Needs summary."
end

function Wowpedia:GetPatchSection()
	return format("==Patch changes==\n* {{Patch %s|note=Added.}}\n", LATEST_PATCH)
end

function Wowpedia:GetElinkSection(apiTable)
	local templateInfo = self:GetTemplateInfo(apiTable, true)
	return "==External Links==\n{{subst:el}}\n"..templateInfo
end

function Wowpedia:GetTemplateInfo(apiTable, isElink)
	local tbl = {}
	if apiTable.Type == "Function" then
		tinsert(tbl, isElink and "Elinks-api" or "wowapi")
		tinsert(tbl, "t=a")
	elseif apiTable.Type == "Event" then
		tinsert(tbl, isElink and "Elinks-api" or "wowapievent")
		tinsert(tbl, "t=e")
	elseif apiTable.Type == "Enumeration" or apiTable.Type == "Structure" then
		tinsert(tbl, "wowapitype")
	end
	local system = apiTable.System
	if system then
		if system.Namespace then
			tinsert(tbl, "namespace="..system.Namespace)
		end
		if system.Name then
			tinsert(tbl, "system="..system.Name)
		end
	end
	return format("{{%s}}", table.concat(tbl, "|"))
end

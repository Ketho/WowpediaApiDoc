Wowpedia = {}
require "Wowpedia/Functions"
require "Wowpedia/Events"
require "Wowpedia/Tables"
require "Wowpedia/Fields"

function Wowpedia:GetPageText(apiTable)
	local tbl = {}
	local template, params
	if apiTable.Type == "Function" then
		template = "{{wowapi}}"
		params = self:GetFunctionText(apiTable)
	elseif apiTable.Type == "Event" then
		template = string.format("{{wowapievent|%s}}", apiTable.System.Namespace)
		params = self:GetEventText(apiTable)
	end
	local sections = {
		template,
		self:GetDescription(),
		params,
		self:GetPatchSection(),
		self:GetElinksSection(),
	}
	for _, v in pairs(sections) do
		table.insert(tbl, v)
	end
	return table.concat(tbl, "\n")
end

function Wowpedia:GetDescription()
	return "Needs summary."
end

function Wowpedia:GetPatchSection()
	return "==Patch changes==\n* {{Patch 9.0.1|note=Added.}}\n"
end

function Wowpedia:GetElinksSection()
	return "==External Links==\n{{subst:el}}\n{{Elinks-api}}"
end

require("Wowpedia/Tests")

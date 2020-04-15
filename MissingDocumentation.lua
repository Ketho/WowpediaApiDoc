local Missing =
{
	Tables =
	{
		{
			-- C_Calendar
			Name = "CalendarTime",
			Type = "Structure",
			Fields =
			{
				{ Name = "year", Type = "number" },
				{ Name = "month", Type = "number" },
				{ Name = "monthDay", Type = "number" },
				{ Name = "weekday", Type = "number" },
				{ Name = "hour", Type = "number" },
				{ Name = "minute", Type = "number" },
			},
		},
		{
			-- C_TransmogCollection
			Name = "AppearanceSourceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryID", Type = "number" },
				{ Name = "invType", Type = "number" },
				{ Name = "isCollected", Type = "number" },
				{ Name = "isHideVisual", Type = "number", Nilable = true },
				{ Name = "itemID", Type = "number" },
				{ Name = "itemModID", Type = "number" },
				{ Name = "name", Type = "number", Nilable = true  },
				{ Name = "quality", Type = "number", Nilable = true  },
				{ Name = "sourceID", Type = "number" },
				{ Name = "sourceType", Type = "number", Nilable = true  },
				{ Name = "visualID", Type = "number" },
			},
		},
		-- GarrisonTalentTreeInfo
		-- GuildTabardInfo
		-- QueueSpecificInfo
		-- RuneforgeLegendaryCraftDescription
		-- RuneforgePower
	},
}

APIDocumentation:AddDocumentationTable(Missing)

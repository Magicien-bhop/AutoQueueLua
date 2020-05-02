local js = panorama.open()
local lobbyapi = js.LobbyAPI
local localapi = js.MyPersonaAPI
local compapi = js.CompetitiveMatchAPI
local gameapi =  js.GameStateAPI
local partylistapi = js.PartyListAPI
local Active = false
local Loop = true

local gamemodes = {
	"Deathmatch",
	"War Games",
	"Casual",
	"Wingman",
	"Competitive",
	"Scrimmage",
	"Danger Zone"
}

local gamemodeMaps = {
	["Deathmatch"] = {	
		"mg_casualsigma",
		"mg_casualdelta",
		"mg_dust247",
		"mg_hostage"
	},
	["War Games"]  = {
		"mg_skirmish_armsrace",
		"mg_skirmish_demolition",
		"mg_skirmish_flyingscoutsman"
	},
	["Casual"] = {
		"mg_casualsigma",
		"mg_casualdelta",
		"mg_dust247",
		"mg_hostage"
	},
	["Wingman"] = {
		"mg_de_vertigo",
		"mg_de_inferno",
		"mg_de_overpass",
		"mg_de_cbble",
		"mg_de_train",
		"mg_de_shortnuke",
		"mg_de_shortdust",
		"mg_gd_rialto",
		"mg_de_lake"
	},
	["Competitive"] = {
		"mg_de_mirage",
		"mg_de_inferno",
		"mg_de_overpass",
		"mg_de_vertigo",
		"mg_de_nuke",
		"mg_de_train",
		"mg_de_dust2",
		"mg_de_anubis",
		"mg_de_cache",
		"mg_cs_agency",
		"mg_cs_office",
	},
	["Scrimmage"] = {
		"mg_de_chlorine",
		"mg_de_mirage_scrimmagemap"
	}
}

local settings = {
	update = {
		Options = {
			action = "private",
		},
		Game =  {
			ark = 10,
			nby =  0,
			clantag = "",
			mode = "",
			type = "classic",
			mapgroupname = ""
		}
	}
}

local gamemodesCombo = ui.new_combobox("LUA", "A", "GameType", gamemodes)
local CompMulti = ui.new_multiselect("LUA", "A", "Competitive Maps", gamemodeMaps["Competitive"])
local CasualMulti = ui.new_combobox("LUA", "A", "Casual Maps", gamemodeMaps["Casual"])
local WingmanMulti = ui.new_multiselect("LUA", "A", "Wingman Maps", gamemodeMaps["Wingman"])
local WarMulti = ui.new_multiselect("LUA", "A", "WarGames Maps", gamemodeMaps["War Games"]	)
local DeathMulti = ui.new_combobox("LUA", "A", "Deathmatch Maps", gamemodeMaps["Deathmatch"])
local ScrimMulti = ui.new_multiselect("LUA", "A", "Scrimmage Maps", gamemodeMaps["Scrimmage"])
local FullLobby = ui.new_checkbox("LUA", "A", "Wait for Full lobby")

local function HandleMenu()
	ui.set_visible(CompMulti, false)
	ui.set_visible(WarMulti, false)
	ui.set_visible(CasualMulti, false)
	ui.set_visible(WingmanMulti, false)
	ui.set_visible(DeathMulti, false)
	ui.set_visible(ScrimMulti, false)
	if ui.get(gamemodesCombo) == "Competitive" then
		ui.set_visible(CompMulti, true)
	elseif ui.get(gamemodesCombo) == "Scrimmage" then
		ui.set_visible(ScrimMulti, true)
	elseif ui.get(gamemodesCombo) == "Casual" then
		ui.set_visible(CasualMulti, true)
	elseif ui.get(gamemodesCombo) == "Wingman" then
		ui.set_visible(WingmanMulti, true)
	elseif ui.get(gamemodesCombo) == "War Games" then
		ui.set_visible(WarMulti, true)
	elseif ui.get(gamemodesCombo) == "Deathmatch" then
		ui.set_visible(DeathMulti, true)
	end
end
ui.set_callback(gamemodesCombo, HandleMenu)
HandleMenu()

local function on_paint_ui(ctx)	
	if Active then
		if Loop then
			Loop = false
			client.delay_call(1	, function()  
				if not (gameapi.IsConnectedOrConnectingToServer() == true) then
					if lobbyapi.GetMatchmakingStatusString() == "" then
						if not compapi.HasOngoingMatch() then		
							if not lobbyapi.IsSessionActive() then
								lobbyapi.CreateSession()
							end
							if ui.get(gamemodesCombo) == "Competitive" then
								settings["update"]["Game"]["mode"] = "competitive"
								settings["update"]["Game"]["type"] = "classic"
								settings["update"]["Game"]["mapgroupname"] = table.concat(ui.get(CompMulti), ",")
								lobbyapi.UpdateSessionSettings( settings );
								

							end
							if ui.get(gamemodesCombo) == "Scrimmage" then
								settings["update"]["Game"]["mode"] = "competitive"
								settings["update"]["Game"]["type"] = "classic"
								settings["update"]["Game"]["mapgroupname"] = table.concat(ui.get(ScrimMulti), ",")
								lobbyapi.UpdateSessionSettings( settings );
								
							end
							if ui.get(gamemodesCombo) == "Casual" then
								settings["update"]["Game"]["mode"] = "casual"
								settings["update"]["Game"]["type"] = "classic"
								settings["update"]["Game"]["mapgroupname"] = ui.get(CasualMulti)
								lobbyapi.UpdateSessionSettings( settings );
							end
							if ui.get(gamemodesCombo) == "Wingman" then
								settings["update"]["Game"]["mode"] = "scrimcomp2v2"
								settings["update"]["Game"]["type"] = "classic"
								settings["update"]["Game"]["mapgroupname"] = table.concat(ui.get(WingmanMulti), ",")
								lobbyapi.UpdateSessionSettings( settings );
								
							end
							if ui.get(gamemodesCombo) == "Deathmatch" then
								settings["update"]["Game"]["mode"] = "deathmatch"
								settings["update"]["Game"]["type"] = "gungame"
								settings["update"]["Game"]["mapgroupname"] = ui.get(DeathMulti)
								lobbyapi.UpdateSessionSettings( settings );
								
							end
							if ui.get(gamemodesCombo) == "War Games" then
								settings["update"]["Game"]["mode"] = "skirmish"
								settings["update"]["Game"]["type"] = "skirmish"
								settings["update"]["Game"]["mapgroupname"] = table.concat(ui.get(WarMulti), ",")
								lobbyapi.UpdateSessionSettings( settings );
		
							end
							
							if ui.get(gamemodesCombo) == "Danger Zone" then
								settings["update"]["Game"]["mode"] = "survival"
								settings["update"]["Game"]["type"] = "freeforall"
								settings["update"]["Game"]["mapgroupname"] = "mg_dz_blacksite,mg_dz_sirocco,mg_dz_junglety"
								lobbyapi.UpdateSessionSettings( settings );
							end
							if ui.get(FullLobby) then
								if (ui.get(gamemodesCombo) == "Competitive" or ui.get(gamemodesCombo) == "Scrimmage") then
									if partylistapi.GetCount() == 5 then
										lobbyapi.StartMatchmaking("", "ct", "t", "")
									end
								elseif ui.get(gamemodesCombo) == "Wingman" then
									if partylistapi.GetCount() == 2 then
										lobbyapi.StartMatchmaking("", "ct", "t", "")
									end
								else
									lobbyapi.StartMatchmaking("", "ct", "t", "")
								end
							else
								lobbyapi.StartMatchmaking("","ct","t","")
							end
						end
					end
				end
				Loop = true
			end)
		end
	end
end
client.set_event_callback("paint_ui", on_paint_ui)

local enable_button = ui.new_button("LUA", "A", "Start auto queue", function() Active = true
	client.log("Started")
end)

local function stop_auto_queue()
	client.delay_call(1, function() lobbyapi.StopMatchmaking() end)
	Active = false
end
local disable_button = ui.new_button("LUA", "A", "Stop auto queue", stop_auto_queue)

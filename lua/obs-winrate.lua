-- OBS 勝率カウンター
-- ツール > スクリプト で読み込み、テキストソースを選択して使う。
-- ホットキー（設定 > ホットキー）はゲーム中でも有効。

obs = obslua

local source_name = ""
local format = ""
local decimals = 1
local wins, losses, draws = 0, 0, 0
local draws_in_rate = false
local history = {}
local my_settings = nil
local hotkeys = {}

local function win_rate()
  local denom = wins + losses
  if draws_in_rate then denom = denom + draws end
  if denom == 0 then
    return string.format("%." .. decimals .. "f", 0)
  end
  return string.format("%." .. decimals .. "f", wins / denom * 100)
end

local function render()
  local text = format
  text = text:gsub("{W}", tostring(wins))
  text = text:gsub("{L}", tostring(losses))
  text = text:gsub("{D}", tostring(draws))
  text = text:gsub("{T}", tostring(wins + losses + draws))
  text = text:gsub("{R}", win_rate())
  return text
end

local function update_text()
  if my_settings ~= nil then
    obs.obs_data_set_int(my_settings, "wins", wins)
    obs.obs_data_set_int(my_settings, "losses", losses)
    obs.obs_data_set_int(my_settings, "draws", draws)
  end
  local src = obs.obs_get_source_by_name(source_name)
  if src == nil then return end
  local s = obs.obs_data_create()
  obs.obs_data_set_string(s, "text", render())
  obs.obs_source_update(src, s)
  obs.obs_data_release(s)
  obs.obs_source_release(src)
end

local function add_win()
  wins = wins + 1
  table.insert(history, "w")
  update_text()
end

local function add_loss()
  losses = losses + 1
  table.insert(history, "l")
  update_text()
end

local function add_draw()
  draws = draws + 1
  table.insert(history, "d")
  update_text()
end

local function undo()
  local last = table.remove(history)
  if last == "w" and wins > 0 then wins = wins - 1 end
  if last == "l" and losses > 0 then losses = losses - 1 end
  if last == "d" and draws > 0 then draws = draws - 1 end
  update_text()
end

local function reset()
  wins, losses, draws, history = 0, 0, 0, {}
  update_text()
end

local actions = {
  { id = "win",   label = "勝ち +1",  fn = add_win },
  { id = "loss",  label = "負け +1",  fn = add_loss },
  { id = "draw",  label = "引き分け +1", fn = add_draw },
  { id = "undo",  label = "取り消し", fn = undo },
  { id = "reset", label = "リセット", fn = reset },
}

function script_description()
  return [[<b>勝率カウンター</b><br>
テキストソースに勝敗と勝率を表示します。<br>
ホットキーは 設定 &gt; ホットキー の「勝率: 〜」で割り当て。<br>
表示形式: {W}=勝ち {L}=負け {D}=引き分け {T}=試合数 {R}=勝率<br>
表示したくない項目は表示形式から消してください。]]
end

function script_defaults(settings)
  obs.obs_data_set_default_string(settings, "format", "{W}勝 {L}敗 {D}分  勝率 {R}%")
  obs.obs_data_set_default_int(settings, "decimals", 1)
end

function script_properties()
  local p = obs.obs_properties_create()

  local list = obs.obs_properties_add_list(p, "source", "テキストソース",
    obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
  local sources = obs.obs_enum_sources()
  if sources ~= nil then
    for _, src in ipairs(sources) do
      local id = obs.obs_source_get_unversioned_id(src)
      if id == "text_gdiplus" or id == "text_ft2_source" then
        local name = obs.obs_source_get_name(src)
        obs.obs_property_list_add_string(list, name, name)
      end
    end
  end
  obs.source_list_release(sources)

  obs.obs_properties_add_text(p, "format", "表示形式", obs.OBS_TEXT_MULTILINE)
  obs.obs_properties_add_int(p, "decimals", "勝率の小数桁", 0, 3, 1)
  obs.obs_properties_add_bool(p, "draws_in_rate", "勝率の計算に引き分けを含める")
  obs.obs_properties_add_int(p, "wins", "勝ち", 0, 1000000, 1)
  obs.obs_properties_add_int(p, "losses", "負け", 0, 1000000, 1)
  obs.obs_properties_add_int(p, "draws", "引き分け", 0, 1000000, 1)

  for _, a in ipairs(actions) do
    obs.obs_properties_add_button(p, "btn_" .. a.id, a.label, function()
      a.fn()
      return true
    end)
  end
  return p
end

function script_update(settings)
  my_settings = settings
  source_name = obs.obs_data_get_string(settings, "source")
  format = obs.obs_data_get_string(settings, "format")
  decimals = obs.obs_data_get_int(settings, "decimals")
  wins = obs.obs_data_get_int(settings, "wins")
  losses = obs.obs_data_get_int(settings, "losses")
  draws = obs.obs_data_get_int(settings, "draws")
  draws_in_rate = obs.obs_data_get_bool(settings, "draws_in_rate")
  update_text()
end

function script_load(settings)
  my_settings = settings
  for _, a in ipairs(actions) do
    local name = "winrate_" .. a.id
    local id = obs.obs_hotkey_register_frontend(name, "勝率: " .. a.label, function(pressed)
      if pressed then a.fn() end
    end)
    local arr = obs.obs_data_get_array(settings, name)
    obs.obs_hotkey_load(id, arr)
    obs.obs_data_array_release(arr)
    hotkeys[name] = id
  end
end

function script_save(settings)
  for name, id in pairs(hotkeys) do
    local arr = obs.obs_hotkey_save(id)
    obs.obs_data_set_array(settings, name, arr)
    obs.obs_data_array_release(arr)
  end
end

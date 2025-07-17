-- List all alternate recipe names you want to unlock this way
local ALT_RECIPES = {
  "iron-plate-pure-iron",
  "iron-plate-iron-alloy",
  "iron-plate-inferior-iron-plate",
  "iron-plate-leeched-iron-plate",
  "copper-plate-pure-copper",
  "copper-plate-copper-alloy",
  "copper-plate-crappy-copper-plate",
  "copper-plate-leeched-copper-plate",
  "steel-plate-carbonized-steel",
  "steel-plate-steel-alloy",
  "iron-stick-steel-stick",
  "copper-cable-iron-cable",
  "copper-cable-steel-cable",
  "concrete-dry-concrete",
  "refined-concrete-ultra-processed-concrete",
  "concrete-fine-concrete",
  "engine-unit-lightweight-engine",
  "electronic-circuit-cheap-circuitry",
  "electronic-circuit-optical-circuitry",
  "engine-unit-electric-rotor",
  "engine-unit-cheap-quality-engine",
  "engine-unit-diesel-engines",
  "plastic-bar-crude-plastic",
  "plastic-bar-microplastic-filtering",
  "battery-lithium-cell",
  "battery-inefficient-battery",
  "battery-smart-battery",
  "electronic-circuit-etched-circuits",
  "advanced-circuit-etched-adv-circuits"
}

-- Helper: Safe deep copy
local function deep_copy(tbl)
  local result = {}
  for k, v in pairs(tbl) do
    result[k] = type(v) == "table" and deep_copy(v) or v
  end
  return result
end

-- Helper: Get the per-force persistent list of remaining recipes
local function get_remaining(force)
  storage.sars_remaining = storage.sars_remaining or {}
  if not storage.sars_remaining[force.name] then
    storage.sars_remaining[force.name] = deep_copy(ALT_RECIPES)
  end
  return storage.sars_remaining[force.name]
end

-- Unlock all alternates (guaranteed, e.g., on rocket-silo)
local function unlock_all_alt_recipes(force)
  local remaining = get_remaining(force)
  for _, name in pairs(ALT_RECIPES) do
    local recipe = force.recipes[name]
    if recipe then
      recipe.enabled = true
	  storage.sars_unlocked = storage.sars_unlocked or {}
	  storage.sars_unlocked[force.name] = storage.sars_unlocked[force.name] or {}
	  storage.sars_unlocked[force.name][recipe.name] = true
    end
  end
  storage.sars_remaining[force.name] = {}
  force.print({"", "[SARS] ", {"sars-alt-all-unlocked"}})
end

-- Unlock a random alternate (used for per-tech unlock)
local function unlock_random_alt_recipe(force)
  local remaining = get_remaining(force)
  if #remaining == 0 then
    force.print({"", "[SARS] ", {"sars-no-alt-remaining"}})
    return
  end

  local idx = math.random(#remaining)
  local name = remaining[idx]
  local recipe = force.recipes[name]
  if recipe then
    recipe.enabled = true
	storage.sars_unlocked = storage.sars_unlocked or {}
	storage.sars_unlocked[force.name] = storage.sars_unlocked[force.name] or {}
	storage.sars_unlocked[force.name][recipe.name] = true
    force.print({"[SARS] Alternate Recipe Unlocked: ", recipe.localised_name or name})
  end
  table.remove(remaining, idx)
end

-- Sanity check: Remove any already-unlocked recipes from remaining list
local function restore_unlocked_recipes(force)
  -- Ensure per-force unlocked table exists
  storage.sars_unlocked = storage.sars_unlocked or {}
  local unlocked = storage.sars_unlocked[force.name] or {}
  for recipe, was_unlocked in pairs(unlocked) do
    if was_unlocked and force.recipes[recipe] then
      force.recipes[recipe].enabled = true
    end
  end
end

-- On new game/save
script.on_init(function()
  storage.sars_remaining = {}
end)

-- On mod update/config change: restore persistent unlocks
script.on_configuration_changed(function()
  for _, force in pairs(game.forces) do
    restore_unlocked_recipes(force)
  end
end)

-- Per-tech unlock logic
script.on_event(defines.events.on_research_finished, function(event)
  local force = event.research.force
  local tech_name = event.research.name
  local remaining = get_remaining(force)

  -- Unlock all if rocket-silo is researched
  if tech_name == "rocket-silo" then
    unlock_all_alt_recipes(force)
    return
  end

  if #remaining == 0 then return end

  local base_chance = settings.global["sars-base-unlock-chance"].value / 100
  local increase = settings.global["sars-unlock-chance-increase"].value / 100
  local techs_done = 0
  for _, t in pairs(force.technologies) do
    if t.researched then techs_done = techs_done + 1 end
  end

  local chance = base_chance + (techs_done - 1) * increase
  if chance > 1 then chance = 1 end

  if math.random() < chance then
    unlock_random_alt_recipe(force)
  end
end)

-- Remote for manual unlock (for testing)
remote.add_interface("sars", {
  unlock_random_alt_recipe = function(force)
    unlock_random_alt_recipe(force or game.player.force)
  end,
  unlock_all_alt_recipes = function(force)
    unlock_all_alt_recipes(force or game.player.force)
  end
})

-- Custom input handler (optional, if you use a custom keybind)
script.on_event("sars-force-unlock", function(event)
  local player = game.get_player(event.player_index)
  unlock_random_alt_recipe(player.force)
end)

script.on_init(function()
  log("=== S.A.R.S INIT DEBUG ===")

  if not storage then
    log("ERROR: storage table missing")
  else
    log("storage exists")
  end

  if not storage.sars_alt_recipes then
    log("storage.sars_alt_recipes is nil")
  else
    log("storage.sars_alt_recipes count: " .. tostring(#storage.sars_alt_recipes))
    for _, name in pairs(storage.sars_alt_recipes) do
      log(" - alt recipe: " .. name)
    end
  end

  for name, recipe in pairs(game.forces["player"].recipes) do
    if name:find("iron") or name:find("steel") then
      log("recipe exists: " .. name .. " | enabled: " .. tostring(recipe.enabled))
    end
  end
end)

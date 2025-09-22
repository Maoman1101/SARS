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
  "iron-gear-wheel-cast-iron-gear",
  "iron-gear-wheel-alloyed-gear",
  "engine-unit-electric-rotor",
  "engine-unit-cheap-quality-engine",
  "engine-unit-diesel-engines",
  "plastic-bar-crude-plastic",
  "battery-inefficient-battery",
  "battery-smart-battery",
  "electronic-circuit-etched-circuits",
  "advanced-circuit-etched-adv-circuits",
  "coal-charcoal",
  "electronic-circuit-plastic-circuits",
  "lubricant-water-based-lubricant",
  "low-density-structure-quick-and-dirty-structure",
  "uranium-fuel-cell-trace-uranium-filtering",
  "rocket-fuel-electrolysis-fuel",
  "explosives-nitroglycerin",
  "explosives-plastic-c4",
  "flying-robot-frame-lightweight-robot-frame",
  "electric-engine-unit-dry-electric-engine",
  "concrete-fine-concrete",
  "engine-unit-lightweight-engine",
  "electronic-circuit-cheap-circuitry",
  "electronic-circuit-optical-circuitry",
  "battery-lithium-cell",
  "plastic-bar-microplastic-filtering",
  "silicon-wafer-trace-silicon-filtering",
  "heavy-oil-biodiesel",
  "coal-biocoal"
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
  force.print({"", "[SARS] Unlocked all recipes."})
end

-- Unlock a random alternate (used for per-tech unlock)
local function unlock_random_alt_recipe(force)
  local remaining = get_remaining(force)
  if #remaining == 0 then
    force.print({"", "[SARS] All recipes unlocked."})
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
  storage.sars_unlocked[force.name] = storage.sars_unlocked[force.name] or {}
  local unlocked = storage.sars_unlocked[force.name]
  for recipe, was_unlocked in pairs(unlocked) do
    if was_unlocked and force.recipes[recipe] then
      force.recipes[recipe].enabled = true
    end
  end
end

-- Rebuild unlocked/remaining from current force state
local function rebuild_indexes_for_force(force)
    storage.sars_unlocked = storage.sars_unlocked or {}
    local unlocked = storage.sars_unlocked[force.name] or {}

    -- If we have no record (or it's empty), infer from the live recipe flags
    if next(unlocked) == nil then
        for _, name in pairs(ALT_RECIPES) do
            local r = force.recipes[name]
            if r and r.enabled then
                unlocked[name] = true
            end
        end
    end
    storage.sars_unlocked[force.name] = unlocked

    -- Recompute remaining = ALT_RECIPES - unlocked
    storage.sars_remaining = storage.sars_remaining or {}
    local remaining = {}
    for _, name in pairs(ALT_RECIPES) do
        if not unlocked[name] then
            table.insert(remaining, name)
        end
    end
    storage.sars_remaining[force.name] = remaining
end

-- On mod update/config change: restore persistent unlocks
script.on_configuration_changed(function(e)
    storage.sars_deferred_restore = true
end)

script.on_event(defines.events.on_tick, function(e)
    if storage.sars_deferred_restore then
        storage.sars_deferred_restore = nil
        for _, force in pairs(game.forces) do
            rebuild_indexes_for_force(force)
            restore_unlocked_recipes(force)  -- re-enable according to sars_unlocked
        end
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

local function unlock_alt_recipe(recipe_name, force)
	force = force or game.player.force
	local recipe = force.recipes[recipe_name]
	if recipe then
		recipe.enabled = true
		storage.sars_unlocked = storage.sars_unlocked or {}
		storage.sars_unlocked[force.name] = storage.sars_unlocked[force.name] or {}
		storage.sars_unlocked[force.name][recipe.name] = true
		force.print({"[SARS] Unlocked alt recipe: " .. recipe_name})
	else
		force.print({"[SARS] No such alt recipe: " .. recipe_name .. ". See control.lua for a list of valid recipe names."})
	end
end

-- Remote for manual unlock (for testing)
remote.add_interface("sars", {
  unlock_random_alt_recipe = function(force)
    unlock_random_alt_recipe(force or game.player.force)
  end,
  unlock_all_alt_recipes = function(force)
    unlock_all_alt_recipes(force or game.player.force)
  end, 
  unlock_alt_recipe = function(recipe_name, force)
    unlock_alt_recipe(recipe_name, force or game.player.force)
  end
})

-- Custom input handler (optional, if you use a custom keybind)
script.on_event("sars-force-unlock", function(event)
  local player = game.get_player(event.player_index)
  unlock_random_alt_recipe(player.force)
end)

local function reset_alt_recipes(force)
  storage.sars_remaining = storage.sars_remaining or {}
  storage.sars_remaining[force.name] = deep_copy(ALT_RECIPES)

  -- Optional: wipe unlock record so re-researching can unlock again
  if storage.sars_unlocked then
    storage.sars_unlocked[force.name] = {}
  end

  for _, name in pairs(ALT_RECIPES) do
    local recipe = force.recipes[name]
    if recipe then
      recipe.enabled = false
    end
  end

  force.print({"", "[SARS] ", "Alternate recipe unlocks have been reset."})
end

script.on_event("sars-reset-alt-recipes", function(event)
  local player = game.get_player(event.player_index)
  reset_alt_recipes(player.force)
end)

script.on_init(function()
  storage.sars_remaining = {}
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

script.on_event("sars-open-manual-unlock", function(event)
  local player = game.get_player(event.player_index)
  if player.gui.screen.sars_manual_unlock_frame then player.gui.screen.sars_manual_unlock_frame.destroy() end
  local frame = player.gui.screen.add{type="frame", name="sars_manual_unlock_frame", caption="Manual Recipe Unlock"}
  local flow = frame.add{type="flow", direction="horizontal"}
  flow.add{type="textfield", name="sars_manual_unlock_text"}
  flow.add{type="button", name="sars_manual_unlock_submit", caption="Unlock"}
  frame.auto_center = true
  player.opened = frame
end)

-- Handle Unlock via button
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  if event.element.name == "sars_manual_unlock_submit" then
    local frame = player.gui.screen.sars_manual_unlock_frame
    if not frame then return end
    local recipe_name = frame.flow.sars_manual_unlock_text.text
    if recipe_name and recipe_name:match("%S") then  -- not empty or whitespace only
      unlock_alt_recipe(recipe_name, player.force)
    else
      player.print{"[SARS] Please enter a valid recipe name."}
    end
    frame.destroy()
  end
end)

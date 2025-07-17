-- data.lua

-- Create a custom category for identifying alt recipes if needed later
local SARS_ALT_RECIPE_TAG = "__sars_alt"

-- Template alt recipe
local function make_alt_recipe(base_name, alt_suffix, ingredients, results, energy, category)
  local base_recipe = data.raw.recipe[base_name]
  local recipe = {
    type = "recipe",
    name = base_name .. "-" .. alt_suffix,
    localised_name = {"sars-recipe-name." .. base_name .. "-" .. alt_suffix},
    category = category or "crafting",
    enabled = false,
    hidden = false,
    ingredients = ingredients,
    results = results,
    energy_required = energy or 0.5,
    allow_decomposition = false,
    allow_as_intermediate = true,
    group = "sars",
    subgroup = "sars-alt-recipes",
    order = base_recipe and base_recipe.order,
    sars_alt = true
  }

  if base_recipe then
    if base_recipe.icons then
      recipe.icons = base_recipe.icons
    elseif base_recipe.icon then
      recipe.icon = base_recipe.icon
      recipe.icon_size = base_recipe.icon_size
      recipe.icon_mipmaps = base_recipe.icon_mipmaps
    end
  end

  return recipe
end

-- Define custom recipe subgroup for SARS alt recipes
data:extend({
  {
    type = "item-group",
    name = "sars",
    order = "zzz",
    inventory_order = "zzz",
    icon = "__SARS__/graphics/icon.png",
    icon_size = 64,
    icon_mipmaps = 1
  },
  {
    type = "item-subgroup",
    name = "sars-alt-recipes",
    group = "sars",
    order = "a"
  }
})

local recipes = {}

table.insert(recipes, make_alt_recipe("iron-plate", "pure-iron",
  { {type = "item", name = "iron-ore", amount = 2}, {type = "fluid", name = "water", amount = 1} },
  { {type = "item", name = "iron-plate", amount = 3} },
  1.6, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("iron-plate", "iron-alloy",
  { {type = "item", name = "iron-ore", amount = 8}, {type = "item", name = "copper-ore", amount = 2} },
  { {type = "item", name = "iron-plate", amount = 15} },
  0.32, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("iron-plate", "inferior-iron-plate",
  { {type = "item", name = "iron-plate", amount = 3}, {type = "item", name = "plastic-bar", amount = 1} },
  { {type = "item", name = "iron-plate", amount = 5} },
  0.8, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("iron-plate", "leeched-iron-plate",
  { {type = "item", name = "iron-ore", amount = 5}, {type = "fluid", name = "sulfuric-acid", amount = 1} },
  { {type = "item", name = "iron-plate", amount = 10} },
  0.4, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("copper-plate", "pure-copper",
  { {type = "item", name = "copper-ore", amount = 2}, {type = "fluid", name = "water", amount = 1} },
  { {type = "item", name = "copper-plate", amount = 3} },
  1.6, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("copper-plate", "copper-alloy",
  { {type = "item", name = "copper-ore", amount = 8}, {type = "item", name = "iron-ore", amount = 2} },
  { {type = "item", name = "copper-plate", amount = 15} },
  0.32, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("copper-plate", "crappy-copper-plate",
  { {type = "item", name = "copper-plate", amount = 3}, {type = "item", name = "plastic-bar", amount = 1} },
  { {type = "item", name = "copper-plate", amount = 5} },
  0.8, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("copper-plate", "leeched-copper-plate",
  { {type = "item", name = "copper-ore", amount = 5}, {type = "fluid", name = "sulfuric-acid", amount = 1} },
  { {type = "item", name = "copper-plate", amount = 10} },
  0.4, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("steel-plate", "carbonized-steel",
  { {type = "item", name = "iron-plate", amount = 4}, {type = "item", name = "coal", amount = 1} },
  { {type = "item", name = "steel-plate", amount = 1} },
  16, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("steel-plate", "steel-alloy",
  { {type = "item", name = "iron-plate", amount = 8}, {type = "item", name = "copper-plate", amount = 2} },
  { {type = "item", name = "steel-plate", amount = 2} },
  8.0, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("iron-stick", "steel-stick",
  { {type = "item", name = "steel-plate", amount = 1} },
  { {type = "item", name = "iron-stick", amount = 12} },
  0.1))

table.insert(recipes, make_alt_recipe("copper-cable", "iron-cable",
  { {type = "item", name = "iron-plate", amount = 5} },
  { {type = "item", name = "copper-cable", amount = 2} },
  0.5))

table.insert(recipes, make_alt_recipe("copper-cable", "steel-cable",
  { {type = "item", name = "steel-plate", amount = 1} },
  { {type = "item", name = "copper-cable", amount = 12} },
  0.1, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("concrete", "dry-concrete",
  { {type = "item", name = "stone", amount = 3} },
  { {type = "item", name = "concrete", amount = 1} },
  5.0, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("refined-concrete", "ultra-processed-concrete",
  { {type = "item", name = "concrete", amount = 1} },
  { {type = "item", name = "refined-concrete", amount = 1} },
  25.0, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("iron-gear-wheel", "cast-iron-gear",
  { {type = "item", name = "steel-plate", amount = 1} },
  { {type = "item", name = "iron-gear-wheel", amount = 10} },
  0.1))

table.insert(recipes, make_alt_recipe("iron-gear-wheel", "alloyed-gear",
  { {type = "item", name = "iron-plate", amount = 3}, {type = "item", name = "copper-plate", amount = 1} },
  { {type = "item", name = "iron-gear-wheel", amount = 2} },
  1.0))
  
table.insert(recipes, make_alt_recipe("engine-unit", "electric-rotor",
  { {type = "item", name = "iron-stick", amount = 1}, {type = "item", name = "copper-cable", amount = 8}, {type = "item", name = "pipe", amount = 2} },
  { {type = "item", name = "engine-unit", amount = 1} },
  1, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("engine-unit", "cheap-quality-engine",
  { {type = "item", name = "iron-gear-wheel", amount = 1}, {type = "item", name = "pipe", amount = 2}, {type = "item", name = "plastic-bar", amount = 2}, {type = "item", name = "copper-plate", amount = 1} },
  { {type = "item", name = "engine-unit", amount = 1} },
  0.5, "advanced-crafting"))

table.insert(recipes, make_alt_recipe("engine-unit", "diesel-engines",
  { {type = "fluid", name = "heavy-oil", amount = 1}, {type = "item", name = "pipe", amount = 2}, {type = "item", name = "steel-plate", amount = 3}, {type = "item", name = "iron-gear-wheel", amount = 2} },
  { {type = "item", name = "engine-unit", amount = 2} },
  0.5, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("plastic-bar", "crude-plastic",
  { {type = "fluid", name = "crude-oil", amount = 1}, {type = "item", name = "coal", amount = 2} },
  { {type = "item", name = "plastic-bar", amount = 1} },
  0.25, "chemistry"))

table.insert(recipes, make_alt_recipe("plastic-bar", "microplastic-filtering",
  { {type = "item", name = "raw-fish", amount = 10} },
  { {type = "item", name = "plastic-bar", amount = 1}, {type = "item", name = "spoilage", amount = 10} },
  5.0, "chemistry"))

recipes[#recipes].icon = "__base__/graphics/icons/plastic-bar.png"
recipes[#recipes].icon_size = 64

table.insert(recipes, make_alt_recipe("battery", "inefficient-battery",
  { {type = "item", name = "sulfur", amount = 1}, {type = "item", name = "iron-plate", amount = 3}, {type = "item", name = "copper-plate", amount = 2} },
  { {type = "item", name = "battery", amount = 1} },
  1.0))

table.insert(recipes, make_alt_recipe("battery", "smart-battery",
  { {type = "item", name = "iron-plate", amount = 1}, {type = "item", name = "copper-plate", amount = 1}, {type = "fluid", name = "sulfuric-acid", amount = 10}, {type = "item", name = "advanced-circuit", amount = 1} },
  { {type = "item", name = "battery", amount = 3} },
  3.0, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("electronic-circuit", "etched-circuits",
  { {type = "item", name = "iron-plate", amount = 1}, {type = "fluid", name = "sulfuric-acid", amount = 10} },
  { {type = "item", name = "electronic-circuit", amount = 1} },
  0.5, "crafting-with-fluid"))

table.insert(recipes, make_alt_recipe("advanced-circuit", "etched-adv-circuits",
  { {type = "item", name = "electronic-circuit", amount = 2}, {type = "item", name = "plastic-bar", amount = 2}, {type = "fluid", name = "sulfuric-acid", amount = 10} },
  { {type = "item", name = "advanced-circuit", amount = 1} },
  1, "crafting-with-fluid"))

data:extend(recipes)

data:extend({
  {
    type = "custom-input",
    name = "sars-force-unlock",
    key_sequence = "CONTROL + ALT + U",
    consuming = "none"
  }
})
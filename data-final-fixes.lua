-- Create a custom category for identifying alt recipes if needed later
local SARS_ALT_RECIPE_TAG = "__sars_alt"

local recipes = {}

-- Template alt recipe
local function make_alt_recipe(base_name, alt_suffix, ingredients, results, energy, category)
  local recipe = {
    type = "recipe",
    name = base_name .. "-" .. alt_suffix,
    localised_name = {"sars-recipe-name." .. base_name .. "-" .. alt_suffix},
    category = category or "crafting", -- adjust per base item if needed
    enabled = false,
    hidden = false,
    ingredients = ingredients,
    results = results,
    energy_required = energy or 0.5,
    allow_decomposition = false,
    allow_as_intermediate = true,
    -- Tag it so control.lua can find and track these
    icons = data.raw.recipe[base_name] and data.raw.recipe[base_name].icons,
	group = "sars",
    subgroup = "sars-alt-recipes",
    order = data.raw.recipe[base_name] and data.raw.recipe[base_name].order,
    -- Custom field used by control.lua to detect SARS recipes
    sars_alt = true
  }

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

if data.raw.item["sand-ore"] then
  table.insert(recipes, make_alt_recipe("concrete", "fine-concrete", {
    {type = "item", name = "sand-ore", amount = 3},
    {type = "item", name = "stone", amount = 12}
  }, {
    {type = "item", name = "concrete", amount = 10}
  }, 3.3, "crafting-with-fluid"))
end

if data.raw.item["aluminium-plate"] then
  table.insert(recipes, make_alt_recipe("engine-unit", "lightweight-engine", {
    {type = "item", name = "aluminium-plate", amount = 2},
    {type = "item", name = "iron-gear-wheel", amount = 1},
    {type = "item", name = "pipe", amount = 2}
  }, {
    {type = "item", name = "engine-unit", amount = 1}
  }, 1, "crafting-with-fluid"))
end

if data.raw.item["aluminium-plate"] then
  table.insert(recipes, make_alt_recipe("electronic-circuit", "cheap-circuitry", {
    {type = "item", name = "aluminium-plate", amount = 1},
    {type = "item", name = "copper-cable", amount = 3}
  }, {
    {type = "item", name = "electronic-circuit", amount = 1}
  }, 1))
end

if data.raw.item["glass-plate"] then
  table.insert(recipes, make_alt_recipe("electronic-circuit", "optical-circuitry", {
    {type = "item", name = "glass-plate", amount = 1},
    {type = "fluid", name = "sulfuric-acid", amount = 10}
  }, {
    {type = "item", name = "electronic-circuit", amount = 1}
  }, 1, "crafting-with-fluid"))
end

if data.raw.item["lithium"] then
	table.insert(recipes, make_alt_recipe("battery", "lithium-cell", { 
	  {type = "item", name = "lithium", amount = 1}, 
	  {type = "item", name = "plastic-bar", amount = 1}, 
	  {type = "fluid", name = "sulfuric-acid", amount = 10} 
	}, { 
	  {type = "item", name = "battery", amount = 1} 
	}, 1, "chemistry"))
end

if data.raw.item["spoilage"] then
	local recipe = make_alt_recipe("plastic-bar", "microplastic-filtering", { 
		{type = "item", name = "raw-fish", amount = 10} 
	}, { 
		{type = "item", name = "plastic-bar", amount = 1}, 
		{type = "item", name = "spoilage", amount = 10} 
	}, 5.0, "chemistry")

	-- Assign icon manually to avoid crash from missing spoilage icon
	recipe.icon = data.raw.item["plastic-bar"].icon or "__base__/graphics/icons/plastic-bar.png"
	recipe.icon_size = data.raw.item["plastic-bar"].icon_size or 64
	if recipe.auto_recycle == false then return end
	table.insert(recipes, recipe)
end

if data.raw.item["sand-ore"] then
  table.insert(recipes, make_alt_recipe("silicon-wafer", "trace-silicon-filtering", {
    {type = "item", name = "stone", amount = 25},
    {type = "item", name = "sand-ore", amount = 1}
  }, {
    {type = "item", name = "silicon-wafer", amount = 1}
  }, 1.0))
end

if data.raw.item["meaty-chunks"] then
  table.insert(recipes, make_alt_recipe("heavy-oil", "biodiesel", {
    {type = "item", name = "meaty-chunks", amount = 10},
    {type = "fluid", name = "water", amount = 10},
    {type = "item", name = "coal", amount = 1}
  }, {
    {type = "fluid", name = "heavy-oil", amount = 10}
  }, 3.0))
end

if data.raw.item["spoilage"] then
  table.insert(recipes, make_alt_recipe("coal", "biocoal", {
    {type = "item", name = "spoilage", amount = 5}
  }, {
    {type = "item", name = "coal", amount = 1}
  }, 2.0))
end

if #recipes > 0 then
  data:extend(recipes)
end
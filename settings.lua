data:extend({
  {
    type = "double-setting",
    name = "sars-base-unlock-chance",
    setting_type = "runtime-global",
    default_value = 5.0, -- 5%
    minimum_value = 0,
    maximum_value = 100,
    order = "a",
	localised_name = {"mod-setting-name.sars-base-unlock-chance"},
	localised_description = {"mod-setting-description.sars-base-unlock-chance"},
  },
  {
    type = "double-setting",
    name = "sars-unlock-chance-increase",
    setting_type = "runtime-global",
    default_value = 0.1, -- 0.5% per tech
    minimum_value = 0,
    maximum_value = 100,
    order = "b",
	localised_name = {"mod-setting-name.sars-unlock-chance-increase"},
	localised_description = {"mod-setting-description.sars-unlock-chance-increase"},
  }
})

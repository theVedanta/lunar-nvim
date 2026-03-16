-- Configuration management for Lunar LSP

local M = {}

-- Store the current configuration
local current_config = {}

--- Merge user configuration with defaults
--- @param defaults table Default configuration values
--- @param user_config table User-provided configuration
--- @return table Merged configuration
function M.merge(defaults, user_config)
  local merged = {}

  -- Start with defaults
  for key, value in pairs(defaults) do
    merged[key] = value
  end

  -- Override with user config
  if user_config then
    for key, value in pairs(user_config) do
      merged[key] = value
    end
  end

  -- Store the merged config
  current_config = merged

  return merged
end

--- Validate configuration
--- @param conf table Configuration to validate
--- @return boolean True if valid, false otherwise
function M.validate(conf)
  if not conf then
    return false
  end

  -- Validate model
  if conf.model then
    local valid_models = {
      "gpt-4.1-mini",
    }
    local model_valid = false
    for _, m in ipairs(valid_models) do
      if conf.model == m then
        model_valid = true
        break
      end
    end
    if not model_valid then
      vim.notify(
        string.format("Invalid model: %s. Valid options: %s", conf.model, table.concat(valid_models, ", ")),
        vim.log.levels.ERROR
      )
      return false
    end
  end

  -- Validate maxIssues
  if conf.maxIssues and (type(conf.maxIssues) ~= "number" or conf.maxIssues < 1) then
    vim.notify("maxIssues must be a positive number", vim.log.levels.ERROR)
    return false
  end

  -- Validate maxProblems
  if conf.maxProblems and (type(conf.maxProblems) ~= "number" or conf.maxProblems < 1) then
    vim.notify("maxProblems must be a positive number", vim.log.levels.ERROR)
    return false
  end

  -- Validate cmd
  if conf.cmd and type(conf.cmd) ~= "string" then
    vim.notify("cmd must be a string", vim.log.levels.ERROR)
    return false
  end

  return true
end

--- Get the current configuration
--- @return table The current merged configuration
function M.get()
  return current_config
end

return M

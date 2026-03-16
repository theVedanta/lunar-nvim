-- Lunar LSP Client for Neovim
-- Main entry point for the plugin

local config = require("lunar.config")
local lsp = require("lunar.lsp")

local M = {}

-- Track if setup has been called
M._setup_complete = false

-- Default configuration
local default_config = {
  model = "gpt-4.1-mini",
  maxIssues = 5,
  maxProblems = 100,
  cmd = "lunar-lsp",
}

--- Setup the Lunar LSP client
--- @param opts table|nil Optional configuration overrides
function M.setup(opts)
  if M._setup_complete then
    vim.notify("Lunar LSP already set up", vim.log.levels.WARN)
    return
  end

  opts = opts or {}

  -- Merge user config with defaults
  local merged_config = config.merge(default_config, opts)

  -- Validate configuration
  if not config.validate(merged_config) then
    vim.notify("Invalid Lunar configuration", vim.log.levels.ERROR)
    return
  end

  -- Check if lunar-lsp binary is available
  if vim.fn.executable(merged_config.cmd) == 0 then
    vim.notify(
      string.format(
        "Lunar LSP: '%s' not found in PATH. Install it or set 'cmd' option to the full path.",
        merged_config.cmd
      ),
      vim.log.levels.ERROR
    )
    return
  end

  -- Check for OPENAI_API_KEY environment variable
  if not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "" then
    vim.notify(
      "Lunar LSP: OPENAI_API_KEY environment variable is not set. Set it before using Lunar.",
      vim.log.levels.ERROR
    )
    return
  end

  -- Initialize the LSP client
  local client_id = lsp.setup(merged_config)

  if client_id then
    M._setup_complete = true
    vim.notify("Lunar LSP initialized successfully", vim.log.levels.INFO)
  else
    vim.notify("Failed to initialize Lunar LSP", vim.log.levels.ERROR)
  end
end

--- Get the current configuration
--- @return table The merged configuration
function M.get_config()
  return config.get()
end

return M

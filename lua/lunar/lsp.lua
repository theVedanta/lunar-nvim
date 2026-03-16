-- LSP client initialization for Lunar

local util = require("lunar.util")

local M = {}

-- Track LSP client ID
local lunar_client_id = nil

-- Define file types to attach to
local DEFAULT_FILETYPES = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  "python",
  "rust",
  "go",
  "java",
  "c",
  "cpp",
  "csharp",
  "ruby",
  "php",
  "kotlin",
  "swift",
  "scala",
  "haskell",
  "clojure",
  "elixir",
  "lua",
  "shell",
  "bash",
  "zsh",
  "r",
  "julia",
  "perl",
}

--- Find the project root directory
--- @return string|nil The project root directory or nil if not found
local function find_project_root()
  local markers = { ".git", ".gitignore", "package.json", "Makefile", "CMakeLists.txt", "pyproject.toml", "Cargo.toml",
    "go.mod", ".hg" }

  local current_dir = vim.fn.getcwd()

  while current_dir ~= "/" do
    for _, marker in ipairs(markers) do
      local marker_path = current_dir .. "/" .. marker
      if vim.fn.glob(marker_path) ~= "" then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end

  return nil
end

--- Initialize the Lunar LSP client
--- @param config table Configuration table
--- @return number|nil Client ID if successful, nil otherwise
function M.setup(config)
  if lunar_client_id then
    return lunar_client_id
  end

  local project_root = find_project_root()
  if not project_root then
    project_root = vim.fn.getcwd()
  end

  local client_config = {
    name = "lunar",
    cmd = { config.cmd, "--stdio" },
    root_dir = project_root,
    filetypes = DEFAULT_FILETYPES,
    single_file_support = true,
    on_init = function(client, result)
      return M.on_init(client, result, config)
    end,
    on_attach = function(client, bufnr)
      return M.on_attach(client, bufnr, config)
    end,
    on_exit = function(code, signal, client_id)
      return M.on_exit(code, signal, client_id, config)
    end,
    init_options = {
      model = config.model,
      maxIssues = config.maxIssues,
    },
    settings = {
      ["lunar-lsp"] = {
        maxNumberOfProblems = config.maxProblems,
      },
    },
  }

  -- Start the LSP client (eagerly, without requiring a buffer)
  local client_id = vim.lsp.start_client(client_config)

  if client_id then
    lunar_client_id = client_id

    -- Attach to any already-open buffers with a matching filetype
    local filetype_set = {}
    for _, ft in ipairs(DEFAULT_FILETYPES) do
      filetype_set[ft] = true
    end
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        local ft = vim.bo[bufnr].filetype
        if filetype_set[ft] then
          vim.lsp.buf_attach_client(bufnr, client_id)
        end
      end
    end

    -- Attach to future buffers via FileType autocmd
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("LunarLSPAttach", { clear = true }),
      pattern = DEFAULT_FILETYPES,
      callback = function(args)
        -- Re-check client is still alive
        local client = vim.lsp.get_client_by_id(lunar_client_id)
        if client and not client.is_stopped() then
          vim.lsp.buf_attach_client(args.buf, lunar_client_id)
        end
      end,
    })

    return client_id
  end

  return nil
end

--- Called when the LSP client initializes
--- @param client table The LSP client
--- @param result table The initialization result
--- @param config table The plugin configuration
function M.on_init(client, result, config)
  if result and result.capabilities then
    client.server_capabilities = result.capabilities
  end

  return true
end

--- Called when the LSP client attaches to a buffer
--- @param client table The LSP client
--- @param bufnr number The buffer number
--- @param config table The plugin configuration
function M.on_attach(client, bufnr)
  -- Configure diagnostic display
  vim.diagnostic.config({
    virtual_text = {
      prefix = "● ",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }, vim.diagnostic.get_namespace(client.name))

  -- Set up keymaps for this buffer
  util.setup_keymaps(bufnr, client)
end

--- Called when the LSP client exits
--- @param code number The exit code
--- @param signal number The signal that terminated the client
--- @param client_id number The client ID
--- @param config table The plugin configuration
function M.on_exit(code, signal, client_id, config)
  if client_id == lunar_client_id then
    lunar_client_id = nil
    vim.notify("Lunar LSP client exited", vim.log.levels.INFO)
  end
end

--- Get the current client ID
--- @return number|nil The current client ID or nil if not initialized
function M.get_client_id()
  return lunar_client_id
end

return M

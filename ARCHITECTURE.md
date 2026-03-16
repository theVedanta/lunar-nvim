# Lunar Neovim Plugin Architecture

## Overview

The Lunar Neovim plugin provides a simple, zero-configuration way for users to integrate the Lunar LSP server into their Neovim setup. It handles all the complexity of LSP client initialization, file type detection, and project root discovery.

## Design Philosophy

**For End Users:** One-line setup with sensible defaults
```lua
require('lunar').setup()
```

**For Developers:** Modular, testable architecture with clear separation of concerns

## Architecture

### Directory Structure

```
nvim-plugin/
├── plugin/
│   └── lunar.lua              # Auto-loaded entry point
├── lua/
│   └── lunar/
│       ├── init.lua           # Main API and setup orchestration
│       ├── config.lua         # Configuration validation and merging
│       ├── lsp.lua            # LSP client initialization
│       └── util.lua           # Utility functions
├── README.md                  # User documentation
├── INSTALLATION.md            # Installation guide
└── ARCHITECTURE.md            # This file
```

### Module Breakdown

#### `plugin/lunar.lua` - Auto-load Entry Point

- **Responsibility:** Automatically loaded by Neovim on startup
- **Purpose:** Sets up the runtime path for the plugin so Lua modules can be required
- **Key Feature:** Prevents double-loading with `vim.g.lunar_loaded` flag
- **Called by:** Neovim's plugin loader (automatic)
- **Calls:** Nothing (pure setup)

#### `lua/lunar/init.lua` - Public API

- **Responsibility:** Main user-facing module
- **Public API:**
  - `setup(opts)` - Initialize the LSP client with optional config overrides
  - `get_config()` - Retrieve current configuration
- **Internal Functions:**
  - Configuration merging with defaults
  - Validation of user options
  - Pre-flight checks (binary availability, environment variables)
  - LSP client initialization delegation
- **Called by:** User's Neovim config (`require('lunar').setup()`)
- **Calls:** `config.merge()`, `config.validate()`, `lsp.setup()`

#### `lua/lunar/config.lua` - Configuration Management

- **Responsibility:** Configuration validation and merging
- **Public API:**
  - `merge(defaults, user_config)` - Merge user config with defaults
  - `validate(conf)` - Validate configuration object
  - `get()` - Retrieve current merged configuration
- **Validation Rules:**
  - `model` must be one of: `gpt-4.1-mini`, `gpt-4o`, `gpt-4-turbo`, `gpt-4`
  - `maxIssues` must be a positive number
  - `maxProblems` must be a positive number
  - `cmd` must be a string
- **Error Handling:** Uses `vim.notify()` for user-facing error messages
- **Called by:** `init.lua`
- **Calls:** Nothing (pure validation and merging)

#### `lua/lunar/lsp.lua` - LSP Client Initialization

- **Responsibility:** Manages LSP server lifecycle and attachment
- **Key Functions:**
  - `setup(config)` - Initialize and start the LSP client
  - `find_project_root()` - Auto-detect project root directory
  - `on_init()` - LSP initialization callback
  - `on_attach()` - Called when LSP attaches to a buffer
  - `on_exit()` - Cleanup when LSP exits
  - `get_client_id()` - Get the current client ID
- **Supported File Types:** 25+ language types (JavaScript, Python, Rust, Go, etc.)
- **Project Root Detection:** Searches for markers (`.git`, `package.json`, `Cargo.toml`, etc.)
- **LSP Configuration:**
  - Uses `init_options` to pass model and maxIssues to the server
  - Uses `settings` for per-document configuration
  - Enables `single_file_support` for files outside projects
- **Diagnostic Configuration:**
  - Virtual text prefix: `● `
  - Signs enabled for severity levels
  - Underline for visual emphasis
  - No in-insert updates (avoids distraction while typing)
  - Severity-based sorting
- **Called by:** `init.lua`
- **Calls:** `util.setup_keymaps()`

#### `lua/lunar/util.lua` - Utility Functions

- **Responsibility:** Reusable helper functions
- **Functions:**
  - `setup_keymaps(bufnr, client)` - Configure buffer-local keymaps
    - `]d` - Next diagnostic
    - `[d` - Previous diagnostic
    - `<leader>ll` - Show line diagnostics
    - `<leader>lq` - Show all diagnostics in quickfix
  - `format_table(tbl, indent)` - Format tables for display (future use)
- **Called by:** `lsp.lua`
- **Calls:** Nothing (pure utilities)

## Data Flow

### Initialization Flow

```
User calls require('lunar').setup(opts)
    ↓
init.lua validates opts (or uses defaults)
    ↓
init.lua calls config.merge(defaults, opts)
    ↓
config.lua returns merged config
    ↓
init.lua calls config.validate(merged_config)
    ↓
config.lua returns validation result
    ↓
init.lua checks: lunar-lsp binary exists?
    ↓
init.lua checks: OPENAI_API_KEY environment variable set?
    ↓
init.lua calls lsp.setup(merged_config)
    ↓
lsp.lua finds project root
    ↓
lsp.lua builds LSP client config
    ↓
lsp.lua calls vim.lsp.start(client_config)
    ↓
Neovim starts LSP server process
    ↓
LSP attaches to open buffers
    ↓
lsp.on_attach() is called
    ↓
util.setup_keymaps() configures keymaps
    ↓
User sees diagnostics inline and in Problems panel
```

### File Review Flow (Runtime)

```
User opens or modifies a code file
    ↓
LSP client detects file change
    ↓
1-second debounce (handled by server)
    ↓
File sent to lunar-lsp server
    ↓
Server calls OpenAI API with GPT-4.1-mini
    ↓
GPT reviews code and returns issues
    ↓
Server converts issues to LSP Diagnostics
    ↓
LSP publishes diagnostics to client
    ↓
Neovim renders squiggly lines in editor
    ↓
Issues appear in Problems panel
```

## Configuration Flow

### Default Configuration

```lua
local default_config = {
  model = "gpt-4.1-mini",      -- Use smaller, faster model by default
  maxIssues = 5,              -- Limit issues to avoid overwhelming user
  maxProblems = 100,          -- Cap total diagnostics shown
  cmd = "lunar-lsp",          -- Assume binary is in PATH
}
```

### User Override

```lua
require('lunar').setup({
  model = 'gpt-4o',           -- User wants better quality
  maxIssues = 10,             -- User wants more feedback
  maxProblems = 150,          -- User has a large monitor
})
```

### Merged Result

```lua
{
  model = "gpt-4o",           -- User override applied
  maxIssues = 10,             -- User override applied
  maxProblems = 150,          -- User override applied
  cmd = "lunar-lsp",          -- Default used
}
```

## Error Handling Strategy

The plugin follows a **fail-fast with helpful messages** approach:

### At Setup Time

1. **Check 1:** Is `lunar-lsp` in PATH?
   - If no: Show error with suggestion to install or set `cmd` option
   - If yes: Continue

2. **Check 2:** Is `OPENAI_API_KEY` environment variable set?
   - If no: Show error with instructions on how to set it
   - If yes: Continue

3. **Check 3:** Is configuration valid?
   - If no: Show validation error for specific field
   - If yes: Continue

### At Runtime

- LSP crashes are logged but don't crash Neovim
- File review failures are silent (user just doesn't see diagnostics for that pass)
- Project root discovery fails gracefully (uses current working directory)

## Extension Points

### Adding Support for New File Types

Edit the `DEFAULT_FILETYPES` table in `lua/lunar/lsp.lua`:

```lua
local DEFAULT_FILETYPES = {
  -- ... existing types ...
  "newlanguage",
}
```

### Adding New Configuration Options

1. Add to `default_config` in `lua/lunar/init.lua`
2. Add validation rule in `lua/lunar/config.lua`
3. Pass to `init_options` or `settings` in `lua/lunar/lsp.lua`
4. Update documentation in `README.md`

### Customizing Keymaps

Users can override keymaps in their config:

```lua
require('lunar').setup()

-- Custom keymaps after setup
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, opts)
```

Or modify `util.setup_keymaps()` to accept configuration.

## Performance Considerations

1. **Lazy Initialization:** LSP client only starts when `setup()` is called
2. **Debouncing:** Server-side debouncing (1 second) prevents excessive API calls
3. **Stale Result Guard:** Server discards results if file changes during review
4. **Single Client:** Only one LSP client instance per Neovim session
5. **Per-Document Caching:** Settings are cached by document URI

## Testing Strategy

Each module should be independently testable:

### `config.lua`
- Test `merge()` with various inputs
- Test `validate()` with valid and invalid configs

### `lsp.lua`
- Test `find_project_root()` with various directory structures
- Test client config generation

### `init.lua`
- Test pre-flight checks
- Test setup with and without user config

### `util.lua`
- Test keymap generation

## Future Improvements

1. **Configuration per-workspace:** Support different settings in different projects
2. **Disable per-file type:** Allow users to disable for specific file types
3. **Custom rules configuration:** Pass custom review rules to the server
4. **Statistics:** Show review statistics (issues found, issues fixed)
5. **Quick fixes:** Integrate with Neovim's code action system
6. **Custom keymaps:** Accept user-provided keymap configuration in setup()

## Security Considerations

1. **API Key in Environment:** We never store the API key in config files
2. **No Credential Logging:** The plugin doesn't log API keys even in debug mode
3. **Workspace Isolation:** Each LSP client is isolated to its workspace root
4. **Standard LSP Protocol:** We use standard LSP, which is protocol-level secure

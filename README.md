# Lunar Neovim Plugin

An AI-powered code review LSP client for Neovim. Lunar surfaces real issues (clarity, security, error handling, complexity, and more) as standard LSP diagnostics — inline, as you write.

## Features

- **AI-Powered Review** - Uses GPT-4.1-mini to flag issues in your code
- **Automatic Attachment** - Works on all code-related file types with zero configuration
- **Project Root Detection** - Automatically finds your project root using `.git`, `.gitignore`, and other markers
- **Sensible Defaults** - Works out of the box with `require('lunar').setup()`
- **Customizable** - Override model, max issues, and other settings as needed
- **Production Ready** - Complete error handling and helpful error messages

## Installation

### Using `lazy.nvim`

```lua
{
  'theVedanta/lunar-nvim',
  cond = function()
    return vim.fn.executable('lunar-lsp') == 1
  end,
  config = function()
    require('lunar').setup()
  end,
}
```

### Using `packer.nvim`

```lua
use {
  'theVedanta/lunar-nvim',
  config = function()
    require('lunar').setup()
  end,
  cond = function()
    return vim.fn.executable('lunar-lsp') == 1
  end,
}
```

### Using `vim-plug`

```vim
Plug 'theVedanta/lunar-nvim'

" In your init.lua:
lua require('lunar').setup()
```

## Requirements

- **Neovim** 0.9+
- **lunar-lsp** binary (install via `npm install -g lunar-lsp` after publishing)
- **OPENAI_API_KEY** environment variable set with a valid OpenAI API key

## Setup

### Minimal Setup

No configuration needed — just call `setup()`:

```lua
require('lunar').setup()
```

This will:

- Use `gpt-4.1-mini` as the default model
- Allow up to 5 issues per file per review pass
- Automatically attach to code-related file types
- Look for the `lunar-lsp` binary in your PATH

### Custom Configuration

```lua
require('lunar').setup({
  model = 'gpt-4o',
  maxIssues = 10,
  maxProblems = 100,
  -- Optional: override the lunar-lsp path if not in PATH
  cmd = '/path/to/lunar-lsp',
})
```

### Configuration Options

| Option        | Type   | Default         | Description                                  |
| ------------- | ------ | --------------- | -------------------------------------------- |
| `model`       | string | `"gpt-4.1-mini"` | OpenAI model to use for code review          |
| `maxIssues`   | number | `5`             | Max issues per file per review pass          |
| `maxProblems` | number | `100`           | Hard cap on total diagnostics shown per file |
| `cmd`         | string | `"lunar-lsp"`   | Path to the lunar-lsp binary                 |

## Usage

Once set up, Lunar automatically reviews every file you open. Issues appear as LSP diagnostics in:

- The Problems panel
- Inline as virtual text (depending on your configuration)
- Hover information

### Keyboard Shortcuts

- `]d` - Go to next diagnostic
- `[d` - Go to previous diagnostic
- `<leader>ll` - Show line diagnostics in a floating window
- `<leader>lq` - Show all diagnostics in quickfix list

### Severity Levels

- **Error** - High-impact issue (security, data loss risk)
- **Warning** - Should be fixed (logic smell, missing error handling)
- **Info** - Worth considering (maintainability, documentation)
- **Hint** - Low-priority suggestion (naming, minor clarity)

### Issue Types

Lunar checks against these rules:

- `review/clarity` - Unclear intent, confusing control flow
- `review/naming` - Misleading or overly generic names
- `review/error-handling` - Swallowed exceptions, missing error paths
- `review/security-footgun` - Injection risks, exposed secrets
- `review/api-contract` - Type mismatches, broken invariants
- `review/complexity` - Deep nesting, functions needing decomposition
- `review/perf-hotpath` - Redundant work in loops, unnecessary allocations
- `review/maintainability` - Tight coupling, implicit dependencies
- `review/testing-gap` - Logic that is likely untested
- `review/docs-mismatch` - Comments contradicting code, missing docs

## Troubleshooting

### `lunar-lsp` not found

Ensure that the `lunar-lsp` binary is in your PATH:

```bash
which lunar-lsp
```

If not found, either:

1. Build it from source: `npm install -g /path/to/lunar/server`
2. Specify the path explicitly in setup:

```lua
require('lunar').setup({
  cmd = '/path/to/lunar-lsp',
})
```

### No diagnostics appearing

Check that:

1. `OPENAI_API_KEY` environment variable is set:
   ```bash
   echo $OPENAI_API_KEY
   ```
2. You've saved the file (diagnostics appear after a 1-second pause in typing)
3. LSP is properly attached: `:LspInfo` in Neovim

### LSP Server Crashes

Check the LSP logs:

```lua
:lua vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
```

Then check the log file at `~/.cache/nvim/lsp.log`

## Project Structure

```
nvim-plugin/
├── plugin/
│   └── lunar.lua              # Auto-loaded plugin initialization
├── lua/
│   └── lunar/
│       ├── init.lua           # Main setup() function
│       ├── config.lua         # Configuration management
│       ├── lsp.lua            # LSP client initialization
│       └── util.lua           # Utility functions
└── README.md
```

## License

MIT License - see the [LICENSE](../LICENSE) file for details.

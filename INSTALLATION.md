# Installation Guide for Lunar Neovim Plugin

Welcome! This guide will walk you through setting up Lunar for your Neovim editor.

## Prerequisites

Before you begin, make sure you have:

1. **Neovim 0.9 or later**

   ```bash
   nvim --version
   ```

2. **The `lunar-lsp` binary installed globally**

   ```bash
   npm install -g lunar-lsp
   ```

   Or build from source:

   ```bash
   cd /path/to/lunar/server
   npm install
   npm run compile
   npm install -g .
   ```

3. **An OpenAI API key**
   - Get one at [platform.openai.com/api/keys](https://platform.openai.com/api/keys)
   - Set it as an environment variable (see below)

## Step 1: Set Your OpenAI API Key

The plugin reads the `OPENAI_API_KEY` environment variable. Set it in your shell profile:

### For macOS/Linux (Bash/Zsh)

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
export OPENAI_API_KEY="sk-proj-..."
```

Then reload your shell:

```bash
source ~/.zshrc
```

### For Fish

Add to `~/.config/fish/config.fish`:

```fish
set -gx OPENAI_API_KEY "sk-proj-YOUR-API-KEY-HERE"
```

### For Windows (PowerShell)

```powershell
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-proj-YOUR-API-KEY-HERE", "User")
```

## Step 2: Install the Neovim Plugin

Choose your package manager:

### Using `lazy.nvim` (Recommended)

Add this to your lazy.nvim config:

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

### Manual Installation

If you're not using a plugin manager:

1. Clone or copy the `nvim-plugin` directory to your Neovim config:

   ```bash
   cp -r /path/to/lunar/nvim-plugin ~/.config/nvim/pack/lunar/start/lunar
   ```

2. Add to your `init.lua`:
   ```lua
   require('lunar').setup()
   ```

## Step 3: Verify Installation

After restarting Neovim:

1. Open any code file (`.js`, `.py`, `.go`, etc.)
2. Run `:LspInfo` to see if "lunar" is listed as an active client
3. After 1 second of inactivity, you should see diagnostics appear as squiggly lines

## Step 4 (Optional): Customize Configuration

By default, Lunar uses:

- Model: `gpt-4o-mini` (fast and cheap)
- Max issues: 5 per file
- Max problems: 100 total

To customize:

```lua
require('lunar').setup({
  model = 'gpt-4o',           -- Use GPT-4o for better quality (costs more)
  maxIssues = 10,             -- Show up to 10 issues per review
  maxProblems = 150,          -- Allow up to 150 total diagnostics
})
```

## Keyboard Shortcuts

Once installed, you'll have these keymaps automatically:

| Keymap       | Action                                |
| ------------ | ------------------------------------- |
| `]d`         | Jump to next diagnostic               |
| `[d`         | Jump to previous diagnostic           |
| `<leader>ll` | Show diagnostics for current line     |
| `<leader>lq` | Show all diagnostics in quickfix list |

## Troubleshooting

### Issue: "lunar-lsp not found in PATH"

Make sure you've installed the binary globally:

```bash
npm install -g lunar-lsp
```

Or specify the full path in your config:

```lua
require('lunar').setup({
  cmd = '/path/to/lunar-lsp',
})
```

### Issue: "OPENAI_API_KEY environment variable is not set"

Verify your key is set:

```bash
echo $OPENAI_API_KEY
```

Make sure you've reloaded your shell after editing `.zshrc` or `.bash_profile`:

```bash
source ~/.zshrc
```

### Issue: No diagnostics appearing

1. Check that LSP is attached: `:LspInfo`
2. Make sure you've saved the file (diagnostics appear after 1 second of inactivity)
3. Check the LSP logs:
   ```lua
   :lua vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
   ```
   Then check `~/.cache/nvim/lsp.log`

### Issue: "Invalid model" error

Make sure you're using a valid model name:

- `gpt-4o-mini` (recommended - fast and cheap)
- `gpt-4o` (high quality, higher cost)
- `gpt-4-turbo` (balance of quality and cost)
- `gpt-4` (legacy, not recommended)

## Getting Help

If you encounter issues:

1. Check the [main README](./README.md) for more information
2. Run `:messages` to see recent Neovim notifications
3. Enable debug logging as shown in the troubleshooting section
4. Open an issue on the [Lunar Neovim Plugin repository](https://github.com/theVedanta/lunar-nvim)

## Next Steps

- Read the [README](./README.md) to learn about all features
- Check out the [Lunar server documentation](../README.md) for how code review works
- Customize your LSP experience with Neovim's diagnostic configuration

Happy reviewing! 🌙

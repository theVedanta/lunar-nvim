-- Lunar Neovim Plugin
-- Auto-loaded on startup, delegates to lua/lunar/init.lua for the actual setup
--
-- Users should call require('lunar').setup() in their config.

if vim.g.lunar_loaded then
  return
end
vim.g.lunar_loaded = true

-- Ensure the module can be required
vim.opt.rtp:append(vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h"))

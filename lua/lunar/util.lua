-- Utility functions for Lunar LSP

local M = {}

--- Setup keymaps for a buffer
--- @param bufnr number The buffer number
--- @param client table The LSP client
function M.setup_keymaps(bufnr, client)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Go to next diagnostic
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- Go to previous diagnostic
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

  -- Show line diagnostics
  vim.keymap.set("n", "<leader>ll", vim.diagnostic.open_float, opts)

  -- Show all diagnostics in quickfix
  vim.keymap.set("n", "<leader>lq", vim.diagnostic.setqflist, opts)
end

--- Format a table for display
--- @param tbl table The table to format
--- @param indent number The indentation level
--- @return string The formatted table
function M.format_table(tbl, indent)
  indent = indent or 0
  local result = {}
  local indent_str = string.rep(" ", indent)

  for key, value in pairs(tbl) do
    if type(value) == "table" then
      table.insert(result, string.format("%s%s:", indent_str, key))
      table.insert(result, M.format_table(value, indent + 2))
    else
      table.insert(result, string.format("%s%s: %s", indent_str, key, tostring(value)))
    end
  end

  return table.concat(result, "\n")
end

return M

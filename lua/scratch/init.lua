local M = {}

local api = vim.api
local fn = vim.fn

local config = {
  -- The command to use for opening the scratchpad.
  -- e.g., 'edit', 'split', 'vsplit', 'tabnew'
  open_command = "edit",

  -- File extension for the notes.
  file_extension = "md",
  storage = {
    -- If true, store notes in a subdirectory of the current workspace.
    -- If false, store all notes globally in a single directory.
    use_workspace = true,
    -- The name of the subdirectory for workspace notes (e.g., '.scratchpad').
    workspace_subdir = ".scratchpad",
    -- The path for global notes (used when use_workspace is false).
    global_path = fn.stdpath("data") .. "/scratchpad",
  }
}

local function get_base_notes_dir()
  if config.storage.use_workspace then
    return fn.getcwd() .. "/" .. config.storage.workspace_subdir
  else
    return config.storage.global_path
  end
end

local function open_note(period_type, date_string, header_text)
  local base_dir = get_base_notes_dir()
  local dir = base_dir .. "/" .. period_type
  local filename = date_string .. "." .. config.file_extension
  local filepath = dir .. "/" .. filename

  if fn.isdirectory(dir) == 0 then
    pcall(fn.mkdir, dir, "p")
  end

  vim.cmd(string.format("%s %s", config.open_command, fn.fnameescape(filepath)))
  api.nvim_set_option_value("filetype", "markdown", { win = 0 })

  if api.nvim_buf_line_count(0) == 1 and api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" then
    api.nvim_buf_set_lines(0, 0, 0, false, { header_text, "" })
    api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(0), 0 })
  end
end

function M.open_daily()
  local date_str = os.date("%Y-%m-%d")
  open_note("daily", date_str, "# Scratchpad for " .. date_str)
end

function M.open_weekly()
  local date_str = os.date("%Y-W%V")
  open_note("weekly", date_str, "# Weekly Scratchpad for " .. date_str)
end

function M.open_monthly()
  local date_str = os.date("%Y-%m")
  open_note("monthly", date_str, "# Monthly Scratchpad for " .. date_str)
end

function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end

  api.nvim_create_user_command("Scratch", M.open_daily, {
    nargs = 0,
    desc = "Open the daily markdown scratchpad",
  })

  api.nvim_create_user_command("ScratchWeekly", M.open_weekly, {
    nargs = 0,
    desc = "Open the weekly markdown scratchpad",
  })

  api.nvim_create_user_command("ScratchMonthly", M.open_monthly, {
    nargs = 0,
    desc = "Open the monthly markdown scratchpad",
  })
end

return M

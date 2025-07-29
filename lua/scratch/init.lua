local M = {}

local api = vim.api
local fn = vim.fn
local temp_bufnr = nil

local config = {
  -- How to open the scratchpad. Can be 'float' or a command like
  -- 'edit', 'split', 'vsplit', 'tabnew'.
  open_mode = "float",

  -- Configuration for the floating window (only used if open_mode is 'float').
  float = {
    relative = 'editor',
    border = 'rounded',
    width = 0.8,
    height = 0.8,
  },

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

local function get_float_config()
  local float_conf = vim.deepcopy(config.float)
  local editor_width = api.nvim_get_option_value("columns", {})
  local editor_height = api.nvim_get_option_value("lines", {})

  if float_conf.width and float_conf.width <= 1.0 then
    float_conf.width = math.floor(editor_width * float_conf.width)
  end
  if float_conf.height and float_conf.height <= 1.0 then
    float_conf.height = math.floor(editor_height * float_conf.height)
  end

  if float_conf.relative == 'editor' then
    float_conf.row = math.floor((editor_height - float_conf.height) / 2)
    float_conf.col = math.floor((editor_width - float_conf.width) / 2)
  end
  return float_conf
end

local function display_buffer(bufnr)
  if config.open_mode == 'float' then
    local float_config = get_float_config()
    api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
    api.nvim_open_win(bufnr, true, float_config)
    vim.keymap.set('n', '<Esc>', function()
      api.nvim_win_close(0, false)
    end, { buffer = bufnr, silent = true, noremap = true, nowait = true, desc = "Close scratchpad window" })
  else
    vim.cmd(config.open_mode)
    api.nvim_win_set_buf(0, bufnr)
    api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
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

  local bufnr = fn.bufnr(filepath, true)

  display_buffer(bufnr)
  if api.nvim_buf_line_count(bufnr) == 1 and api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == "" then
    api.nvim_buf_set_lines(bufnr, 0, 0, false, { header_text, "" })
  end

  api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(bufnr), 0 })
end

function M.open_daily()
  local date_str = os.date("%d-%m-%Y")
  open_note("daily", date_str, "# Scratchpad for " .. date_str)
end

function M.open_weekly()
  local date_str = os.date("W%V-%Y")
  open_note("weekly", date_str, "# Weekly Scratchpad for " .. date_str)
end

function M.open_monthly()
  local date_str = os.date("%m-%Y")
  open_note("monthly", date_str, "# Monthly Scratchpad for " .. date_str)
end

function M.open_temp()
  if not (temp_bufnr and api.nvim_buf_is_valid(temp_bufnr)) then
    temp_bufnr = api.nvim_create_buf(false, true)
    api.nvim_set_option_value('bufhidden', 'hide', { buf = temp_bufnr })
    api.nvim_set_option_value('swapfile', false, { buf = temp_bufnr })
    api.nvim_buf_set_lines(temp_bufnr, 0, 0, false, { "# Temporary Scratchpad", "" })
  end

  display_buffer(temp_bufnr)
  api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(temp_bufnr), 0 })
end

function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end

  api.nvim_create_user_command("Scratch", M.open_temp, {
    nargs = 0,
    desc = "Open a temporary (ephemeral) scratchpad",
  })

  api.nvim_create_user_command("ScratchDaily", M.open_daily, {
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

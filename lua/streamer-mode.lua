M = {}

-- Set up default paths.
M.paths = {
  venv = '*/venv/*',
  virtualenv = '*/virtualenv/*',
  dotenv = '*/.env',
  config = '*/.config/*',
  aliases = '*/.bash_aliases',
  dotfiles = '*/.dotfiles/*',
  nodotdot = '*/dotfiles/*',
  powershell = '*.ps1',
  gitconfig = '*/.gitconfig',
}

-- regex lol.
M._PowerShellConcealPattern = [[\($env:\s\{-\}\)\@<=.*$]]
M._BashConcealPattern = [[\(export \s\{-\}\)\@<=\S*]]

-- Git
M._GitSigningKeyConcelPattern = [[\(signingkey\s\{-\}\)\@<=.*$]]
M._GitEmailConcealPattern = [[\(email\s\{-\}\)\@<=.*$]]
M._GitNameConcealPattern = [[\(name\s\{-\}\)\@<=.*$]]

-- SSH
M._HostNameConcealPattern = [[\(Hostname\s\{-\}\)\@<=.*$]]

-- Compounded 
M._EnvConcealPattern = [[\($env:\s\{-\}\)\@<=.*$\|\(export \s\{-\}\)\@<=\S*\|\(email\s\{-\}\)\@<=.*$]]
M._GitConcealPattern = [[\(email\s\{-\}\)\@<=.*$\|\(name\s\{-\}\)\@<=.*$\|\(signingkey\s\{-\}\)\@<=.*$]]
M._MasterConcealPattern =
  [[\($env:\s\{-\}\)\@<=.*$\|\(export \s\{-\}\)\@<=.*$\|\(email[ ]\?\s\{-\}\)\@<=.*$\|\(name[ ]\?\s\{-\}\)\@<=.*$\|\(signingkey\s\{-\}\)\@<=.*$]]

-- M._ConcealPatterns = {
--   env = M._EnvConcealPattern,
--   bash_exports = M._BashConcealPattern,
--   powershell = M._PowerShellConcealPattern,
--   git = M._GitConcealPattern,
--   git_name = M._GitNameConcealPattern,
--   git_email = M._GitEmailConcealPattern,
--   git_signingkey = M._GitSigningKeyConcelPattern,
--	 host_name = M._HostNameConcealPattern,
-- }

M.set_patterns = function(opts)
  M._opts.patterns = opts.patterns or M._ConcealPatterns
end

local conceal_augroup = vim.api.nvim_create_augroup('StreamerMode', { clear = true })
M._matches = {}

-- Sets up streamer-mode for paths specified in `opts`: { paths = { name = '/path/' }}
-- Can be called { preset = true } to use the defaults.
-- Parameters: ~
--   • {opts}  Table of named paths
--        • paths = { name = '*/path/*' }
--        • level = 'secure' -- or: 'soft', 'edit'
--
--        • levels:
--
--             • 'secure' will disable the text becoming visible until
--               the `level` changes. (:h streamer-mode.command)
--               You can also type out new exports (or other environment
--               variables) and the text will not be shown.
--               Like sudo password input.
--
--             • 'edit' will enable the text to become visible when the
--                cursor goes into insert mode on the same line.
--
--             • `'soft'` means the text will become visible when the cursor is
--               on the same line.
--
-- example:
--	 • require('streamer-mode').setup({
--	     paths = { name = '*/path/*' },
--	     level = 'edit',
--	     exclude = 'powershell'
--	   })
--
-- :h streamer-mode
---@param opts table
M.setup = function(opts)
  -- Gather initial options from setup to use throughout
  M._opts['level'] = opts['level'] or M._opts['level']
  M._opts['paths'] = opts['paths'] or M._opts['paths']
  M._opts['exclude'] = opts['exclude'] or M._opts['exclude']
  M._opts['conceal_char'] = opts['conceal_char'] or M._opts['conceal_char']
  M._opts['default_state'] = opts['default_state'] or M._opts['default_state']
  if opts['preset'] == true then
    opts = M.preset_opts
  end
  if opts['paths'] then
    for name, path in pairs(opts['paths']) do
      M.paths[name] = vim.fs.normalize(path, { expand_env = true })
    end
  end
  -- Remove any unwanted paths
  if opts['exclude'] then
    for i, name in ipairs(opts['exclude']) do
      M.paths[name] = nil
    end
  end
  if opts['level'] then
    M._level = opts['level']
    if opts['level'] == 'secure' then
      vim.o.concealcursor = 'ivnc'
    elseif opts['level'] == 'edit' then
      vim.o.concealcursor = 'vn'
    elseif opts['level'] == 'soft' then
      vim.o.concealcursor = ''
    end
  end
  M.conceal_char = opts['conceal_char'] or '*'
  vim.o.conceallevel = 1
  M._cmds = vim.api.nvim_get_autocmds({ group = conceal_augroup })
  M.default_state = opts['default_state'] or M.default_state
  if M.default_state == 'on' then
    M.start_streamer_mode()
    M.default_state = 'on'
  end
end

-- Not yet fully tested. Use setup() instead.
-- Add a single path (or file/type) to Streamer Mode.
-- setup({ paths = { name = '*/path/*' } }) is preferred.
-- example:
--	   add_path('bashrc', '*/.bashrc')
---@param name string
---@param path string
M.add_path = function(name, path)
  if path:match('~') then
    path = path:gsub('~', vim.fn.expand('~'))
  end
  M.paths[name] = path
end

---Activates Streamer Mode
M.start_streamer_mode = function()
  table.insert(M._matches, vim.fn.matchadd('Conceal', M._MasterConcealPattern, 9999, -1, { conceal = M.conceal_char }))
  M.setup_env_conceals()
  if M.paths['gitconfig'] then
    M.setup_git_conceals(M.paths['gitconfig'])
  end
end

---Stops Streamer Mode. Alias for `remove_conceals()`
M.stop_streamer_mode = function()
  M.remove_conceals()
end

--- Turns off Streamer Mode (Removes Conceal commands)
M.remove_conceals = function()
  vim.api.nvim_clear_autocmds({ group = 'StreamerMode' })
  vim.fn.clearmatches()
  vim.o.conceallevel = 0
end

---Sets up conceals for environment variables
M.setup_env_conceals = function()
  for name, path in pairs(M.paths) do
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufEnter', 'BufWinEnter' }, {
      pattern = path,
      callback = function()
        table.insert(
          M._matches,
          vim.fn.matchadd('Conceal', M._MasterConcealPattern, 9999, -1, { conceal = M.conceal_char })
        )
      end,
      group = conceal_augroup,
    })
  end
end

---Sets up conceals for .gitconfig, with the given '*/path/*'
---@param path string
M.setup_git_conceals = function(path)
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufEnter', 'BufWinEnter' }, {
    pattern = path,
    callback = function()
      table.insert(M._matches, vim.fn.matchadd('Conceal', M._GitConcealPattern, 9999, -1, { conceal = M.conceal_char }))
    end,
    group = conceal_augroup,
  })
  vim.o.conceallevel = 1
end

--#region "User Commands"
vim.api.nvim_create_user_command('StreamerMode', function()
  M.setup({ paths = M.paths, default_state = 'on', level = M._level })
end, { desc = 'Starts streamer mode.' })

vim.api.nvim_create_user_command('StreamerModeOff', function()
  M.stop_streamer_mode()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('StreamerModeSecure', function()
  M.setup({ level = 'secure', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('StreamerModeEdit', function()
  M.setup({ level = 'edit', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('StreamerModeSoft', function()
  M.setup({ level = 'soft', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Soft level enabled.' })

-- ALIASES YEE

vim.api.nvim_create_user_command('SM', function()
  M.setup(M.paths)
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode.' })

vim.api.nvim_create_user_command('SMoff', function()
  M.remove_conceals()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('SMsecure', function()
  M.setup({ level = 'secure', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('SMedit', function()
  M.setup({ level = 'edit', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('SMsoft', function()
  M.setup({ level = 'soft', default_state = 'on' })
  M.start_streamer_mode()
end, { desc = 'Starts streamer mode with Soft level enabled.' })
--#endregion

M.preset_opts = {
  paths = {
    -- The names are unimportant, only the paths matter.
    -- Any path in here will hide exports and .gitconfig personals. (and $env:s)
    venv = '*/venv/*',
    virtualenv = '*/virtualenv/*',
    dotenv = '*/.env',
    config = '*/.config/*',
    aliases = '*/.bash_aliases',
    dotfiles = '*/.dotfiles/*',
    nodotdot = '*/dotfiles/*',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
  },
  level = 'secure', -- | 'edit' | 'soft'
  default_state = 'on', -- Whether or not streamer mode turns on when nvim is launched.
  exclude = { '' }, -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'
}

M._opts = M.preset_opts


return M

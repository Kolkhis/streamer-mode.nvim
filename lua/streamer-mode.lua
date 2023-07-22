M = {}
-- Set up default paths.
M.preset_opts = {
  paths = {
    -- The names are unimportant, only the paths matter.
    -- Any path in here will hide exports, .gitconfig personals, $env: vars, etc
    venv = '*/venv/*',
    virtualenv = '*/virtualenv/*',
    dotenv = '*/.env',
    config = '*/.config/*',
    aliases = '*/.bash_aliases',
    dotfiles = '*/dotfiles/*',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
    configini = '*/*.ini',
    secretsyaml = '*/*.yaml',
    ssh = '*/.ssh/*',
  },
  level = 'secure', -- | 'edit' | 'soft'
  default_state = 'on', -- Whether or not streamer mode turns on when nvim is launched.
  exclude = { '' }, -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'
  conceal_char = '*',
  patterns = M._ConcealPatterns,
}

M._opts = M.preset_opts

-- regex lol.
M._BaseConcealPattern = [[\(X\s\{-\}\)\@<=.*$]]
M._APIKeyConcealPattern = [[\(API_KEY\s\{-\}\)\@<=.*$]]
M._TOKENConcealPattern = [[\(TOKEN\s\{-\}\)\@<=.*$]]
M._PowerShellEnvConcealPattern = [[\($env:\s\{-\}\)\@<=.*$]]
M._BashEnvConcealPattern = [[\(export \s\{-\}\)\@<=.*$]]
M._BashAliasConcealPattern = [[\(alias \s\{-\}\)\@<=.*$]]

-- Git
M._GitSigningKeyConcelPattern = [[\(signingkey\s\{-\}\)\@<=.*$]]
M._GitEmailConcealPattern = [[\(email\s\{-\}\)\@<=.*$]]
M._GitNameConcealPattern = [[\(^[Nn]ame\s\{-\}\)\@<=.*$]]
-- Git Credentials
M._GitCredentialConcealPattern = [[\(credential.helper\s\{-\}\)\@<=.*$]]
M._GitUserNameConcealPattern = [[\(user.name\s\{-\}\)\@<=.*$]]
M._GitUserPasswordConcealPattern = [[\(user.password\s\{-\}\)\@<=.*$]]

-- SSH
M._HostNameConcealPattern = [[\([Hh]ostname\s\{-\}\)\@<=.*$]]
M._IdentityFileConcealPattern = [[\(IdentityFile\s\{-\}\)\@<=.*$]]

-- .ini
M._ServerIPConcealPattern = [[\([Ss]erver\s\{-\}\)\@<=.*$]]
M._PortConcealPattern = [[\([Pp]ort\s\{-\}\)\@<=.*$]]

-- Compounded (Avoid these)
M._EnvConcealPattern = [[\($env:\s\{-\}\)\@<=.*$\|\(export \s\{-\}\)\@<=\S*\|\(email\s\{-\}\)\@<=.*$]]
M._GitConcealPattern = [[\(email\s\{-\}\)\@<=.*$\|\(name\s\{-\}\)\@<=.*$\|\(signingkey\s\{-\}\)\@<=.*$]]
M._MasterConcealPattern =
  [[\($env:\s\{-\}\)\@<=.*$\|\(export \s\{-\}\)\@<=.*$\|\(email[ ]\?\s\{-\}\)\@<=.*$\|\(name[ ]\?\s\{-\}\)\@<=.*$\|\(signingkey\s\{-\}\)\@<=.*$\|\(TOKEN\s\{-\}\)\@<=.*$\|\(API_KEY\s\{-\}\)\@<=.*$\|\(credential.helper\s\{-\}\)\@<=.*$\|\(user.name\s\{-\}\)\@<=.*$]]
-- SSH IdentityFile, Hostname and GitUserPasswordConcealPattern
M._OverflowConcealPattern =
  [[\(user.password\s\{-\}\)\@<=.*$\|\(IdentityFile\s\{-\}\)\@<=.*$\|\(Hostname\s\{-\}\)\@<=.*$]]

M._ConcealPatterns = {
  M._APIKeyConcealPattern,
  M._TOKENConcealPattern,
  M._PowerShellEnvConcealPattern,
  M._BashEnvConcealPattern,
  M._GitUserNameConcealPattern,
  M._GitUserPasswordConcealPattern,
  M._GitCredentialConcealPattern,
  M._GitSigningKeyConcelPattern,
  M._GitEmailConcealPattern,
  M._GitNameConcealPattern,
  M._HostNameConcealPattern,
  M._IdentityFileConcealPattern,
  M._OpenSSHPrivateKeyConcealPattern,
  M._ServerIPConcealPattern,
  M._PortConcealPattern,
}

--[==[ IN PROGRESS ]==]
--
--[=[--
M._opts.hide = {
	export = true,
	alias = true,
	env = true,
	powershell = true,
	git_name = true,
	git_username = true,
	git_userpassword = true,
	git_email = true,
	git_signingkey = true,
	api_key = true,
	token = true,
	identity_file = true,
	host_name = true,
}



--]=]
-- [=[ More Regex coming! ]=]

M.conceal_augroup = vim.api.nvim_create_augroup('StreamerMode', { clear = true })
M._matches = {}
M._cursor_levels = {
  secure = 'ivnc',
  edit = 'vn',
  soft = '',
}

-- Can be called { preset = true } to use the defaults.
-- Parameters: ~
--   • {opts}  Table of named paths
--        • paths = { any_name = '*/path/*' }
--        • level = 'secure' -- or: 'soft', 'edit'
--        • exclude = { 'default', 'path', 'names' }
--        • conceal_char = '*' -- default
--        • default_state = 'on' -- or 'off'
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
-- :h streamer-mode.setup
---@param opts? table
function M.setup(opts)
  -- Gather initial options from setup to use throughout
  if opts then
    M._opts.level = opts.level or M._opts.level
    M._opts.paths = opts.paths or M._opts.paths
    M._opts.exclude = opts.exclude or M._opts.exclude
    M._opts.conceal_char = opts.conceal_char or M._opts.conceal_char
    M._opts.default_state = opts.default_state or M._opts.default_state
    -- TODO: Add kwargs for words to conceal: 'export', 'name', etc
    M._opts.patterns = opts.patterns or M._opts.patterns
  else
    opts = M._opts
  end
  if opts.preset then
    M._opts = M.preset_opts
  end
  if opts.paths then
    for name, path in pairs(opts.paths) do
      M._opts[name] = path
    end
  end
  if M._opts.paths then
    for name, path in pairs(M._opts.paths) do
      M._opts.paths[name] = vim.fs.normalize(path, { expand_env = true })
    end
  end
  -- Remove any unwanted paths
  if opts.exclude then
    for i, name in ipairs(opts['exclude']) do
      M._opts.paths[name] = nil
    end
  end
  -- set conceal character
  vim.o.concealcursor = M._cursor_levels[M._opts.level]
  vim.o.conceallevel = 1
  M._cmds = vim.api.nvim_get_autocmds({ group = M._conceal_augroup })
  M._opts.default_state = opts.default_state or M._opts.default_state
  if M._opts.default_state == 'on' then
    M:start_streamer_mode()
    M._opts.default_state = 'on'
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
    path = path:gsub('~', vim.fn.expand('~')) -- Essentially normalize
  end
  M._opts.paths[name] = path
end

---Callback for autocmds.
function M:add_match_conceals()
  for i, conc in ipairs(M._ConcealPatterns) do
    table.insert(M._matches, vim.fn.matchadd('Conceal', conc, 9999, -1, { conceal = M._opts.conceal_char }))
  end
end

---Activates Streamer Mode
function M:start_streamer_mode()
  vim.fn.clearmatches()
  self._matches = {}
  M:add_match_conceals()
  M:setup_env_conceals()
end

---Stops Streamer Mode. Alias for `remove_conceals()`
function M:stop_streamer_mode()
  M:remove_conceals()
end

--- Turns off Streamer Mode (Removes Conceal commands)
function M:remove_conceals()
  vim.api.nvim_clear_autocmds({ group = 'StreamerMode' })
  vim.fn.clearmatches()
  self._matches = {}
  vim.o.conceallevel = 0
end

---Sets up conceals for environment variables
function M:setup_env_conceals()
  for name, path in pairs(M._opts.paths) do
    vim.api.nvim_create_autocmd({ 'BufRead' }, {
      pattern = path,
      callback = function()
        M:add_match_conceals()
      end,
      group = M._conceal_augroup,
    })
  end
end

vim.api.nvim_create_user_command('StreamerMode', function()
  M.setup({ paths = M._opts.paths, default_state = 'on', level = M._opts.level })
end, { desc = 'Starts streamer mode.' })

vim.api.nvim_create_user_command('StreamerModeOff', function()
  M:stop_streamer_mode()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('StreamerModeSecure', function()
  M.setup({ level = 'secure', default_state = 'on' })
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('StreamerModeEdit', function()
  M.setup({ level = 'edit', default_state = 'on' })
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('StreamerModeSoft', function()
  M.setup({ level = 'soft', default_state = 'on' })
end, { desc = 'Starts streamer mode with Soft level enabled.' })

vim.api.nvim_create_user_command('SM', function()
  M.setup({ default_state = 'on' })
end, { desc = 'Starts streamer mode.' })

vim.api.nvim_create_user_command('SMoff', function()
  M:remove_conceals()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('SMsecure', function()
  M.setup({ level = 'secure', default_state = 'on' })
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('SMedit', function()
  M.setup({ level = 'edit', default_state = 'on' })
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('SMsoft', function()
  M.setup({ level = 'soft', default_state = 'on' })
end, { desc = 'Starts streamer mode with Soft level enabled.' })

return M

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
    configini = '*.ini',
    secretsyaml = '*.yaml',
    ssh = '*/.ssh/*',
  },
  level = 'secure', -- | 'edit' | 'soft'
  default_state = 'off', -- Whether or not streamer mode turns on when nvim is launched.
  exclude = { '' }, -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'
  conceal_char = '*',
  patterns = M._ConcealPatterns,
}

M._opts = M.preset_opts

-- regex lol.
M._BaseConcealPattern = [[\(%s\s\{-\}\)\@<=.*$]]
-- M._APIKeyConcealPattern = [[\(API_KEY\s\{-\}\)\@<=.*$]]
M._APIKeyConcealPattern = [[\([api\|API]\{3}_\?[key\|KEY]\{3}\s\{-\}\)\@<=.*$]]
M._ClientSecretConcealPattern = [[\([client]\{6}\|[CLIENT]\{6}_\?[secret]\{6}\|[SECRET]\{6}\s\{-\}\)\@<=.*$]]
M._TOKENConcealPattern = [[\(token\|TOKEN\s\{-\}\)\@<=.*$]]
M._PowerShellEnvConcealPattern = [[\($env:\s\{-\}\)\@<=.*$]]
M._BashEnvConcealPattern = [[\(export \s\{-\}\)\@<=.*$]]
M._BashAliasConcealPattern = [[\(alias \s\{-\}\)\@<=.*$]]

-- Git
M._GitSigningKeyConcelPattern = [[\(signingkey\s\{-\}\)\@<=.*$]]
M._GitEmailConcealPattern = [[\(email\|EMAIL\s\{-\}\)\@<=.*$]]
M._GitNameConcealPattern = [[\(name\|NAME\s\{-\}\)\@<=.*$]]
-- Git Credentials
M._GitCredentialConcealPattern = [[\(credential.helper\s\{-\}\)\@<=.*$]]
M._GitUserNameConcealPattern = [[\(user.name\s\{-\}\)\@<=.*$]]
M._GitUserPasswordConcealPattern = [[\(user.password\s\{-\}\)\@<=.*$]]

-- SSH
M._HostNameConcealPattern = [[\([Hh]ostname\|HOSTNAME\s\{-\}\)\@<=.*$]]
M._HostConcealPattern = [[\([Hh]ost\|HOST\s\{-\}\)\@<=.*$]]
M._IdentityFileConcealPattern = [[\(IdentityFile\s\{-\}\)\@<=.*$]]

-- .ini
M._ServerIPConcealPattern = [[\(server\|SERVER\s\{-\}\)\@<=.*$]]
M._PortConcealPattern = [[\(port\|PORT\s\{-\}\)\@<=.*$]]


M._ConcealPatterns = {
  M._APIKeyConcealPattern,
  M._TOKENConcealPattern,
  M._ClientSecretConcealPattern,
  M._PowerShellEnvConcealPattern,
  M._BashEnvConcealPattern,
  M._BashAliasConcealPattern,
  M._GitUserNameConcealPattern,
  M._GitUserPasswordConcealPattern,
  M._GitCredentialConcealPattern,
  M._GitSigningKeyConcelPattern,
  M._GitEmailConcealPattern,
  M._GitNameConcealPattern,
  M._HostNameConcealPattern,
  M._HostConcealPattern,
  M._IdentityFileConcealPattern,
  M._ServerIPConcealPattern,
  M._PortConcealPattern,
  --
  M._OpenSSHPrivateKeyConcealPattern,
}

M._opts.patterns = M._ConcealPatterns
--[==[ IN PROGRESS ]==]

M._opts.keywords = {
  'api_key',
  'token',
  'client_secret',
  'powershell',
  '$env:',
  'export',
  'alias',
  'name',
  'userpassword',
  'email',
  'signingkey',
  'IdentityFile',
  'server',
  'username',
  'host',
  'port',
  'hostname',
}

-- Will eventually be used for keyword customization
M._opts.conceal_dict = {
  export = M._opts.patterns._BashEnvConcealPattern,
  alias = M._opts.patterns._BashAliasConcealPattern,
  powershell = M._opts.patterns._PowerShellEnvConcealPattern,
  git_name = M._opts.patterns._GitNameConcealPattern,
  git_username = M._opts.patterns._GitUserNameConcealPattern,
  git_userpassword = M._opts.patterns._GitUserPasswordConcealPattern,
  git_email = M._opts.patterns._GitEmailConcealPattern,
  git_signingkey = M._opts.patterns._GitSigningKeyConcelPattern,
  api_key = M._opts.patterns._APIKeyConcealPattern,
  client_secret = M._opts.patterns._ClientSecretConcealPattern,
  token = M._opts.patterns._TOKENConcealPattern,
  identity_file = M._opts.patterns._IdentityFileConcealPattern,
  host_name = M._opts.patterns._HostNameConcealPattern,
  host = M._opts.patterns._HostConcealPattern,
  server = M._opts.patterns._ServerIPConcealPattern,
  port = M._opts.patterns._PortConcealPattern,
  credential_helper = M._opts.patterns._GitCredentialConcealPattern,
}

--
--[=[--



--]=]
-- [=[ More Regex coming! ]=]

M.conceal_augroup = vim.api.nvim_create_augroup('StreamerMode', { clear = true })
M._matches = {}
M._cursor_levels = {
  secure = 'ivnc',
  edit = 'vn',
  soft = '',
}

--- Setup function for the user. Configures default behavior.
--- Usage:
--- <code>
---	  require('streamer-mode').setup({
---      -- Use all the default paths
---      preset = true,
---      -- Add more paths
---      paths = { project_dir = '~/projects/*' },
---      -- Set Streamer Mode to be active when nvim is launched
---	     default_mode = 'on',
---      -- Set Streamer Mode behavior. :h sm.level
---	     level = 'edit',
---      -- A listlike table of default paths to exlude
---	     exclude = { 'powershell' }
---	     keywords = { 'export', 'alias', 'api_key' }
---	   })
--- </code>
---
--- Parameters: ~
---   • {opts}  Table of named paths
---        • keywords: table = { 'keywords', 'to', 'conceal' }
---        • paths: table = { any_name = '*/path/*' }
---        • level: string = 'secure' -- or: 'soft', 'edit'
---        • exclude: table = { 'default', 'path', 'names' }
---        • conceal_char: string = '*' -- default
---        • default_state: string = 'on' -- or 'off'
---
---        • levels:
---
---             • 'secure' will disable the text becoming visible until
---               the `level` changes. (:h streamer-mode.command)
---               You can also type out new exports (or other environment
---               variables) and the text will not be shown.
---               Like sudo password input.
---
---             • 'edit' will enable the text to become visible when the
---                cursor goes into insert mode on the same line.
---
---             • `'soft'` means the text will become visible when the cursor is
---               on the same line.
---
--- :h streamer-mode.setup
---@param opts? table: keywords: table, paths: table, exclude: table, default_mode: string, conceal_char: string, level: string
function M.setup(opts)
  -- Gather initial options from setup to use throughout
  M.default_conceallevel = vim.o.conceallevel
  if opts then
    M._opts.level = opts.level or M._opts.level
    M._opts.paths = opts.paths or M._opts.paths
    M._opts.exclude = opts.exclude or M._opts.exclude
    M._opts.conceal_char = opts.conceal_char or M._opts.conceal_char
    M._opts.default_state = opts.default_state or M._opts.default_state
    M._opts.patterns = opts.patterns or M._opts.patterns
    M._opts.keywords = opts.keywords or M._opts.keywords
  else
    opts = M._opts
  end

  if opts.preset then
    M._opts = M.preset_opts -- Catch if user chooses preset AND custom paths
    if opts.paths then
      for name, path in pairs(opts.paths) do
        M._opts[name] = path
      end
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
  -- Add custom keywords
  if opts.keywords then
    M:generate_patterns(M._opts.keywords)
  end
  -- set conceal character
  vim.o.concealcursor = M._cursor_levels[M._opts.level]
  vim.o.conceallevel = 1
  M._cmds = vim.api.nvim_get_autocmds({ group = M._conceal_augroup })
  M._opts.default_state = opts.default_state or M._opts.default_state
  if M._opts.default_state == 'on' then
    M:start_streamer_mode()
  else
    vim.o.conceallevel = M.default_conceallevel
  end
end

-- Not yet fully tested. Use setup() instead.
-- Add a single path (or file/type) to Streamer Mode.
-- setup({ paths = { name = '*/path/*' } }) is preferred.
-- example:
--	   add_path('bashrc', '*/.bashrc')
---@param name string
---@param path string
function M:add_path(name, path)
  if path:match('~') then
    -- TODO: vim.loop.fs_realpath(path) Also viable option. Refactor?
    path = path:gsub('~', vim.fn.expand('~')) -- Essentially normalize
  end
  self._opts.paths[name] = path
end

---Takes in a table in the format of { keyword = true }
---Any keyword that is assigned a value of `true` will be added to
---the conceal patterns.
---@param keywords table list
function M:generate_patterns(keywords)
  for i, word in ipairs(keywords) do
    M._opts.patterns[word] = M._BaseConcealPattern:format(word)
  end
end

---Callback for autocmds.
function M:add_match_conceals()
  for i, pattern in ipairs(M._opts.patterns) do
    table.insert(self._matches, vim.fn.matchadd('Conceal', pattern, 9999, -1, { conceal = self._opts.conceal_char }))
  end
end

---Activates Streamer Mode
function M:add_conceals()
  vim.fn.clearmatches()
  self._matches = {}
  self:add_match_conceals()
  self:setup_env_conceals()
  vim.o.conceallevel = 1
end

---Turns off Streamer Mode (Removes Conceal commands)
function M:remove_conceals()
  vim.api.nvim_clear_autocmds({ group = self.conceal_augroup })
  vim.fn.clearmatches()
  self._matches = {}
  vim.o.conceallevel = self.default_conceallevel
end

---Sets up conceals for environment variables
function M:setup_env_conceals()
  for name, path in pairs(self._opts.paths) do
    vim.api.nvim_create_autocmd({ 'BufRead' }, {
      pattern = path,
      callback = function()
        self:add_match_conceals()
      end,
      group = self._conceal_augroup,
    })
  end
end

---Starts Streamer Mode. Alias for `add_conceals()`
function M:start_streamer_mode()
    self:add_conceals()
    self.enabled = true
end

---Stops Streamer Mode. Alias for `remove_conceals()`
function M:stop_streamer_mode()
  self:remove_conceals()
  self.enabled = false
end

function M:toggle_streamer_mode()
    if self.enabled then
        self:stop_streamer_mode()
    else
        self:start_streamer_mode()
    end
end

vim.api.nvim_create_user_command('StreamerMode', function()
  M:toggle_streamer_mode()
end, { desc = 'Toggles streamer mode.' })

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
  M:toggle_streamer_mode()
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

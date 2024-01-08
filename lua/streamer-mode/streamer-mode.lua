M = {}

local default_opts = {
  paths = {
    '*/venv/*',
    '*/virtualenv/*',
    '*/.env',
    '*/.config/*',
    '*/.bash_aliases',
    '*/.bashrc',
    '*/dotfiles/*',
    '*.ps1',
    '*/.gitconfig',
    '*.ini',
    '*.yaml',
    '*/.ssh/*',
  },

  keywords = {
    'api_key',
    'token',
    'client_secret',
    'powershell',
    '$env:',
    'export',
    'alias',
    'name',
    'userpassword',
    'username',
    'user.name',
    'user.password',
    'user.email',
    'email',
    'signingkey',
    'IdentityFile',
    'server',
    'host',
    'port',
    'credential.helper',
  },

  level = 'secure', -- | 'edit' | 'soft'
  default_state = 'off', -- Whether or not streamer mode turns on when nvim is launched.
  conceal_char = '*',
  patterns = {},
}

M._BaseKeywordConcealPattern = [[^\(\s*\)\?\c\(\%%['"]%s\%%['"]\%%(\s\{-}\)\?\)\zs.*$]]
for _, keyword in ipairs(default_opts.keywords) do
  default_opts.patterns[#default_opts.patterns + 1] = M._BaseKeywordConcealPattern:format(keyword)
end

M.opts = {}

M.conceal_augroup = vim.api.nvim_create_augroup('StreamerMode', { clear = true })
M._matches = {}
M.cursor_levels = {
  secure = 'ivnc',
  edit = 'vn',
  soft = '',
}

--- Setup function for the user. Configures default behavior.
--- Usage: >
---	  require('streamer-mode').setup({
---      -- Use all the default paths
---      preset = true,
---      -- Use custom paths
---      paths = { '~/projects/*' },
---      -- Set Streamer Mode to be active when nvim is launched
---	     default_mode = 'on',
---      -- Set Streamer Mode behavior. :h sm.level
---	     level = 'edit',
---      -- A listlike table of default paths to exlude
---	     keywords = { 'export', 'alias', 'api_key' }
---	   })
---
--- Parameters: ~
---   • {opts}  Table of named paths
---     • keywords: table = { 'keywords', 'to', 'conceal' }
---     • paths: table = { any_name = '*/path/*' }
---     • level: string = 'secure' -- or: 'soft', 'edit'
---     • conceal_char: string = '*' -- default
---     • default_state: string = 'on' -- or 'off'
---     • levels:
---        • `'secure'` will prevent the concealed text from becoming
---          visible at all.
---          This will also conceal any keywords while typing
---          them (like sudo password input).
---
---        • `'edit'` will allow the concealed text to become visible
---          only when the cursor goes into insert mode on the same line.
---
---        • `'soft'` will allow the concealed text to become visible
---          when the cursor is on the same line in any mode.
---
--- :h streamer-mode.setup
---@param user_opts? table
---keywords: list[string],
---paths: list[string],
---default_mode: string,
---conceal_char: string,
---level: string
function M.setup(user_opts)
  user_opts = user_opts or {}
  local opts = vim.tbl_deep_extend('force', default_opts, user_opts)
  M.opts = opts

  if table.concat(opts.keywords) ~= table.concat(default_opts.keywords) then
    M:generate_patterns(opts.keywords)
  end

  M.default_conceallevel = vim.o.conceallevel
  vim.o.concealcursor = M.cursor_levels[M.opts.level]
  if opts.default_state == 'on' then
    M:start_streamer_mode()
  end
end

---Takes in a table in the format of { keyword = true }
---Any keyword that is assigned a value of `true` will be added to
---the conceal patterns.
---@param keywords table list
function M:generate_patterns(keywords)
  for _, word in ipairs(keywords) do
    self.opts.patterns[#self.opts.patterns + 1] = self._BaseKeywordConcealPattern:format(word)
  end
end

---Callback for autocmds.
function M:add_match_conceals()
  for _, pattern in ipairs(M.opts.patterns) do
    table.insert(self._matches, vim.fn.matchadd('Conceal', pattern, 9999, -1, { conceal = self.opts.conceal_char }))
  end
end

---Activates Streamer Mode
function M:add_conceals()
  vim.fn.clearmatches()
  self._matches = {}
  self:add_match_conceals()
  self:setup_env_conceals()
  self:add_ssh_key_conceals()
  self:start_ssh_conceals()
  vim.o.conceallevel = 1
  self.enabled = true
  self.autocmds = vim.api.nvim_get_autocmds({ group = M._conceal_augroup })
end

---Turns off Streamer Mode (Removes Conceal commands)
function M:remove_conceals()
  vim.api.nvim_clear_autocmds({ group = self.conceal_augroup })
  vim.fn.clearmatches()
  self._matches = {}
  vim.o.conceallevel = self.default_conceallevel
  self.enabled = false
end

---Sets up conceals for environment variables
function M:setup_env_conceals()
  for _, path in pairs(self.opts.paths) do
    vim.api.nvim_create_autocmd({ 'BufEnter' }, {
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
end

---Stops Streamer Mode. Alias for `remove_conceals()`
function M:stop_streamer_mode()
  self:remove_conceals()
end

function M:toggle_streamer_mode()
  if self.enabled then
    return self:stop_streamer_mode()
  end
  return self:start_streamer_mode()
end

M.ssh_conceal_pattern =
  [[^-\{1,}BEGIN OPENSSH PRIVATE KEY-\{-1,}\n\zs\(\_.\{-}\)\ze-\{1,}END OPENSSH PRIVATE KEY-\{-1,}\n\?]]
function M:start_ssh_conceals()
  table.insert(
    self._matches,
    vim.fn.matchadd('Conceal', self.ssh_conceal_pattern, 9999, -1, { conceal = self.opts.conceal_char })
  )
end

function M:add_ssh_key_conceals()
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = '*/.ssh/id_*',
    callback = function()
      -- Check that the filename doesn't end with .pub
      if vim.fn.expand('%:e') ~= 'pub' then
        self:start_ssh_conceals()
      end
    end,
    group = self.conceal_augroup,
  })
end

return M

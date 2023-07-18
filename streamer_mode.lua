require('dev.globals')
M = {}
-- Set up default paths.
M.paths = { venv = '*/venv/*', virtualenv = '*/virtualenv/*' }
M._path_cache = M.paths

M.add_path = function (name, path)
	M.paths[name] = path
end

-- Sets up streamer-mode for paths specified in `opts`: { paths = {name = '/path/'}}
-- Can be called with an empty table to use the defaults.
-- Parameters: ~
--   • {opts}  Table of named paths
--
-- example: 
--	 • require('streamer-mode').setup({ paths = { name = '/path/' }})
---@param opts table
---@param ... unknown
M.setup = function(opts, ...)
	--#region setup
	-- print("Args to setup: ")
	-- print(opts)
	if opts['paths'] then
		for name, path in pairs(opts['paths']) do
			M.paths[name] = path
		end
	end
	if select('#', ...) then
		print('Args:', select('#', ...))
		for i = 1, select('#', ...) do
			print(select(i, ...))
		end
	end
end

M.setup({paths = { venv = '*/venv/*', aliases = '/.bash_aliases'}})

M.setup({})

P(M.paths)

return M


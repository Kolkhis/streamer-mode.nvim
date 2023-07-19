

# Streamer Mode - Be Safe!

This plugin is not just for streamers, but anyone who wants to conceal their environment
variables and other sensitive information.


![streamer-mode-demo](https://github.com/Kolkhis/streamer-mode.nvim/assets/36500473/d8e551d0-b73a-4e65-93b7-6eebe2a05027)


Currently supports the concealment of `export`, `$env:`, `name`, `email`, and `signingkey`

If anyone has any requests for new concealments, or other features, please don't hesitate to let me know!

### Installation

Install using your favorite plugin manager.


Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use('Kolkhis/streamer-mode.nvim')
```


Using [lazy.nvim]()

```lua
    { 'Kolkhis/streamer-mode.nvim' },
```


Using [vim-plug](https://github.com/junegunn/vim-plug)

```vimscript
Plug 'Kolkhis/streamer-mode.nvim'
```



### Setup


After installing, you can configure Streamer Mode to use the default settings with:

```lua

require('streamer-mode').setup({ preset = true })

```

The default setup is as follows:

```lua

require('streamer-mode').setup({
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
  exclude = { '' }  -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'
})

```


If you want to use the defaults, but exclude some paths, you can:

```lua
require('streamer-mode').setup({
  preset = true,
  level = 'secure',
  exclude = { 'bash_aliases', 'powershell' }
})
```


### Levels
*:h sm.levels*

There are three different levels, each with different behavior.

    * `'secure'` will disable the text becoming visible until
      the `level` changes. (see |streamer-mode.command|)
      You can also type out new exports (or other environment 
      variables) and the text will not be shown.
      Like sudo password input.

									*edit*
    * `'edit'` will enable the text to become visible when the 
       cursor goes into insert mode on the same line.

									*soft*
    * `'soft'` means the text will become visible when the cursor is 
      on the same line.







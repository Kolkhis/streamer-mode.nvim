

# Streamer Mode - Be Safe!

This plugin is not just for streamers, but anyone who wants to conceal their environment
variables and other sensitive information.


![streamer-mode-demo](https://github.com/Kolkhis/streamer-mode.nvim/assets/36500473/d8e551d0-b73a-4e65-93b7-6eebe2a05027)
> Short demo of the basic modes.


If you find a bug, please let me know! I'll try to fix it as soon as I can.

If anyone has any requests for new concealments, customizations, or other features, please don't hesitate to let me know. I'll add them!




### Current Features

* Currently supports the concealment of `export`, `$env:`, `name`, `email`, and `signingkey`

* Hides environment variables and sensitive `.gitconfig` information.

* Three different levels: Secure, Edit, and Soft
    * Check [here](#levels) or `:h sm.levels` for more information on level behaviors.

* Ability to create type out new environment variables without displaying them (secure level), like
  sudo password input.


## Installation

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



## Setup
###### *:h sm.setup*


After installing, you can configure Streamer Mode to use the default settings with:

```lua
require('streamer-mode').setup({ preset = true })
```



To set up Streamer Mode for all files everywhere:
```lua
require('streamer-mode').setup({ paths = { all = '*' } })
```



It's also possible to use default settings and only change `default_state`, `conceal_char`, and/or `level`.
Here's an example that sets `default_state` to 'off', so `:SM` must be run to start
Streamer Mode:

```lua
require('streamer-mode').setup({ default_state = 'off' })
```





If you want to use the defaults, but exclude some paths, you can.
Just don't pass in the `paths` argument, and pass in the other settings
you want to customize (`exclude`, `level`, and `default_state`):

```lua
require('streamer-mode').setup({
  level = 'secure',
  exclude = { 'bash_aliases', 'powershell' },
  default_state = 'off'
})
```



#### Default Settings

The default setup is as follows:

```lua
require('streamer-mode').setup({
  paths = {
    -- You can use any name you want, the '*/path/*' is the important part.
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
  level = 'edit', -- | 'secure' | 'soft'

  default_state = 'on',  -- Whether or not streamer mode turns on when nvim is launched.

  conceal_char = '*'  -- Default. This is what will be displayed instead
                      -- of your secrets.

  exclude = { '' }  -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'
})

```


#### Parameters:

* `paths`: Dictionary-like Table. The paths/files that `streamer-mode` will apply to.
    - To apply `streamer-mode` to ALL files:
        * `{ paths = { all = '*' } }`
    - Pass in paths in the format `name = '*/path/*`
    - Pass in filetypes in the format `name = '*.txt`
* `level`: String. The level in which Streamer Mode will be in effect. 
See more about the different levels below.
* `default_state`: Whether or not Streamer Mode will be active 
when you first launch a Neovim session. Leaving it `'on'` (default)
is recommended.
* `exclude`: List-like table of strings. Only necessary if you want to use the 
some of the defaults, but not all of them.


#### Example Custom Setup

> init.lua
```lua
require('streamer-mode').setup({
  paths = {
    shell_scripts = '*.sh',
    my_config = '*/.myconf/*',
    venv = '*/venv/*',
    aliases = '*/.bash_aliases',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
  },
  level = 'edit',
  default_state = 'on'
})
```



## Levels
`:h sm.levels`

There are three different levels, each with different behavior.

* `'secure'` will disable the text becoming visible until
the `level` changes. (see |streamer-mode.command|)
You can also type out new exports (or other environment 
variables) and the text will not be shown.
Like sudo password input.

    
* `'edit'` (default) will enable the text to become visible when the 
cursor goes into insert mode on the same line.

* `'soft'` means the text will become visible when the cursor is 
on the same line.



## Commands
`:h sm.commands`

There are five commands available for Streamer Mode.
Each command has an alias for easier typing.
The new mode will go into effect once the command is called.


* `:StreamerMode` (or `:SM`) - Starts Streamer Mode.

* `:StreamerModeOff` (or `:SMoff`) - Shuts off Streamer Mode.

* `:StreamerModeSecure` (or `:SMsecure`) - Starts streamer mode with `secure` level enabled.

* `:StreamerModeEdit` (or `:SMedit`) - Starts streamer mode with 'edit' level enabled.

* `:StreamerModeSoft` (or `:SMsoft`) - Starts streamer mode with 'soft' level enabled.





## Donation

If you like this plugin and want to give me money, you can!


[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A4M7MV7) 

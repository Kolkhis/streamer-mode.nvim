# Streamer Mode - Be Safe!  

### Streamer Mode - a Neovim plugin to hide your environment variables.  

This plugin is not just for streamers, but anyone who wants to conceal their environment  
variables and other sensitive information.  

![Streamer-Mode Demo](https://github.com/Kolkhis/streamer-mode.nvim/assets/36500473/3fc1fc02-f4f4-4c6f-a5f7-bbc077f384fa)  

##### *Short demo of the basic modes.*  

If you find a bug, please let me know! I'll try to fix it as soon as I can.  


> #### Side note: It's recommended that you find a more secure way to store VERY private information than in plain text environment variables. But sometimes it's just easier for a temporary solution.  



If anyone has any requests for new customizations or other features, please don't hesitate to let me know. Just [open an issue](https://github.com/Kolkhis/streamer-mode.nvim/issues)!  

## Table of Contents  

- [Installation](#installation)  
- [Setup](#setup)  
  - [Default setup](#default-setup)  
  - [Advanced Setup](#advanced-setup)  
    - [Custom Keywords](#custom-keywords)  
    - [Custom Paths](#custom-paths)  
    - [Custom Behavior and Style Options](#custom-behavior-and-style-options)  
- [Levels](#levels)  
- [Commands](#commands)  

### Current Features  

By default, Streamer Mode currently supports the concealment of a number of  
keywords. More can be added through the `setup()` function.  
The default concealed keywords (case-insensitive):  
* `API_KEY`
* `name`
* `email`
* `export`
* `signingkey`
* `Hostname`
* `IdentityFile`
* `credential.helper`
* `user.name` 
* `user.email`
* `user.password`
* `host`
* `$env:`
* `alias`
* `TOKEN` 
* `server`
* `port`  

You can specify your own keywords to conceal in [setup](#setup).  

- Hides the contents of all SSH private keys (`id_rsa`, `id_ed25519`, `id_dsa`, etc.)  
  in any `.ssh` directory.  
    - Note that this is reliant on the filename starting with `id_`.  
      I will be adding support for private SSH keys with custom filenames  
      in the future.  

- Hides environment variables and sensitive `.gitconfig` information.  

- Three different levels: Secure, Edit, and Soft  

  - Check [here](#levels) or `:h sm.levels` for more information on level behaviors.  

- Ability to type out new environment variables without displaying them (secure level), like sudo password input.  

## Installation  

Install using your favorite plugin manager.  

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)  

```lua  
use('Kolkhis/streamer-mode.nvim')  
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)  

```lua  
{ 'Kolkhis/streamer-mode.nvim' },
```

Using [vim-plug](https://github.com/junegunn/vim-plug)  

```vim  
Plug 'Kolkhis/streamer-mode.nvim'  
```

## Setup  

###### *:h sm.setup*  

In your `init.lua` file, add the following:
```lua
require('streamer-mode').setup()
```
This will enable `streamer-mode.nvim` with the default settings.  

After restarting neovim, just run `:StreamerMode` or `:SM` to toggle on Streamer Mode.  
It will be off by default.  

`streamer-mode.nvim` applies filters to most of the files that will contain sensitive information by default. See [default settings](#default-settings).  


### Default setup:  
To enable streamer mode by default with the default settings:  
```lua  
require('streamer-mode').setup({ default_state = 'on' })  
```
Call `:StreamerModeOff` (`:SMoff`) to disable Streamer Mode, or simply toggle it with `:SM`.  
  

Streamer Mode is disabled by default, which means it won't turn on when Neovim is launched.  
To enable Streamer Mode on launch:  

```lua  
require('streamer-mode').setup({ default_state = 'on' })  
```
Now Streamer Mode will be active every time a new Neovim session is launched.  
    

## Advanced Setup:  
##### These are just examples. To jump to all configuration options, see the [parameters](#Parameters) section.  

### Custom Keywords  
To set your own keywords to conceal, pass them in as a list-like table to  
the `require('streamer-mode').setup()` function.  

The `keywords` table is formatted as follows:  
```lua  
require('streamer-mode').setup({
    default_state = 'on',
    keywords = {
        "secret",
        "api_key",
        "token",
        "auth_token",
        "MySecretVariable",
        "MyAddress",
    }
})  
```
Keywords are not case-sensitive.  
Adding `API_KEY` will conceal both `API_KEY` and `api_key`.  
#### Note that passing in custom keywords will 

### Custom Paths  
To use [defaults](#default-settings) in addition to your own paths/filetypes:  
```lua  
require('streamer-mode').setup({
  preset = true,
  paths = {
    '*/*.yaml'  
  },
})  
```
  

### Custom Behavior and Style Options  
If you want to customize (`conceal_char`, `level`, and `default_state`):  
```lua  
require('streamer-mode').setup({
  level = 'secure',
  default_state = 'off',
  conceal_char = 'X'  
})  
```
  


### Example  

Here's an example of a custom configuration.  
Note that passing in your own `paths` and `keywords` will disable the  
default paths and keywords, unless you also pass in `use_defaults = true`.

```lua  
require('streamer-mode').setup({
  -- Use the default paths and keywords in addition to your own.
  use_defaults = true,  
  paths = {
	-- Any path in here will conceal any keywords in the `keywords` table.  
    '*/venv/*',
    '*/virtualenv/*',
    '*/.env',
    '*/.config/*',
    '~/.bash_aliases',
    '~/.dotfiles/*',
    '*/dotfiles/*',
    '*.ps1',
    '*/.gitconfig',
  },
  keywords = {
    'token',
    'auth_token',
    'key',
    'auth_key',
    'export',
  }
  level = 'edit', -- | 'secure' | 'soft'  
  default_state = 'on', -- | 'off'  
  conceal_char = 'X' -- Can be any character  
})  
```

### Enabling Streamer Mode for all files  
While it is possible to enable Streamer Mode for all files.  
However, it's *possible* that doing this this can slow down your editor. 
Most common files that will contain sensitive information are already in the defaults. 

To enable Streamer Mode for all files, you can do the following:  
```lua  
require('streamer-mode').setup({ use_defaults = true, paths = { '*' } })  
```

## Default Settings  

The default setup is as follows:  

```lua  
require('streamer-mode').setup({
    -- Streamer Mode will apply to any path in here, and will hide any of the `keywords` below.  
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

  -- Any text appearing after one of the keywords specified here will be concealed.  
  -- They are case-insensitive.  
  -- E.g., passing in 'API_KEY' will conceal both 'API_KEY' and 'api_key'.  
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

  conceal_char = '*',  -- Default. This is what will be displayed instead  
                       -- of your secrets.  
})  
```

### Parameters:  

##### All optional. Just calling this function will use the defaults.  

* `use_defaults`: Boolean. Whether or not to use the default paths and keywords.
    * If you do not specify this parameter, it will default to `true`.
    * Note that if this is not set to `false`, then any custom `paths` and `keywords`  
      will be used **in addition** to the default paths and keywords.
* `keywords`: List-like Table of strings. Keywords that will be concealed.  
    * Any text that appears **after** one of these keywords will be concealed 
      with `conceal_char` (default is `*`).  
    * It is possible to pass a Vim basic regular expression as a keyword.  
* `paths`: List-like Table. The paths/files that Streamer Mode will apply to.  
    * Pass in paths in the format: `paths = { '*/path/* }`
    * Pass in filetypes in the same format: ` paths = { '*.txt }`
    * You can apply streamer mode to ALL files (not recommended): `paths = { '*' }`
* `level`: String. The level in which Streamer Mode will be in effect.  
  See more about the different [levels](#levels) below.  
* `default_state`: Whether or not Streamer Mode will be active  
  when you first launch a Neovim session. It's recommended to set this to `'off'`,
  turning it on when needed.  
* `conceal_char`: String. This is the character that will be displayed in place of your hidden text.  

### Example Custom Setup  

> init.lua  

```lua  
require('streamer-mode').setup({
  preset = true,
  paths = {
    '*.sh',
    '*/.config/*',
    '*/venv/*',
    '*/.bash_aliases',
    '*.ps1',
    '*/.gitconfig',
  },
  keywords = {
      "secret",
      "api_key",
      "token",
      "auth_token",
      "MySecretVariable",
      "MyAddress",
  }
  level = 'edit',
  default_state = 'on',
})  
```

## Levels  

###### *:h sm.levels*  

There are three different levels, each with different behavior.  

* `'secure'` (default) will prevent the concealed text from becoming  
  visible at all.  
  This will also conceal any keywords while typing  
  them (like sudo password input).  
* `'edit'` will allow the concealed text to become visible  
  only when the cursor goes into insert mode on the same line.  
* `'soft'` will allow the concealed text to become visible  
when the cursor is on the same line in any mode.  



## Commands  

###### *:h sm.commands*  

There are five commands available for Streamer Mode.  
Each command has an alias for easier typing.  
The new mode will go into effect once the command is called.  

* `:StreamerMode` (`:SM`) - Toggle Streamer Mode on and off.  
* `:StreamerModeOff` (`:SMoff`) - Shuts off Streamer Mode.  
* `:StreamerModeSecure` (`:SMsecure`) - Starts streamer mode with `secure` level enabled.  
* `:StreamerModeEdit` (`:SMedit`) - Starts streamer mode with `edit` level enabled.  
* `:StreamerModeSoft` (`:SMsoft`) - Starts streamer mode with `soft` level enabled.  
  

## Usage  
Streamer Mode will be off be default, unless `default_state = 'on'` is passed during [setup](#setup)).  
To toggle it on, use the command `:SM`, or `:SM(level)`.  
Here's an example of binding it to a key:  
```lua  
vim.keymap.set('n', '<leader>sm', '<cmd>SM<CR>', { silent = true })  
```
Now `<leader>sm` will toggle Streamer Mode on and off.  



## Currently Working On  

- [x] User customization of which keywords they'd like to filter.  
- [x] Make `:SM` command a toggle - enable a single hotkey to turn StreamerMode both on and off. 
  

## Known Issues  

- None. Find something? Open an issue!  
  

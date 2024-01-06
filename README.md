# Streamer Mode - Be Safe!  

### Streamer Mode - a Neovim plugin to hide your environment variables.  

This plugin is not just for streamers, but anyone who wants to conceal their environment  
variables and other sensitive information.  

![Streamer-Mode Demo](https://github.com/Kolkhis/streamer-mode.nvim/assets/36500473/3fc1fc02-f4f4-4c6f-a5f7-bbc077f384fa)  

##### *Short demo of the basic modes.*  

If you find a bug, please let me know! I'll try to fix it as soon as I can.  


> ##### Side note: It's recommended that you find a more secure way to store VERY private information than in plain text environment variables. But sometimes it's just easier for a temporary solution.  



If anyone has any requests for new concealments, customizations, or other features, please don't hesitate to let me know. Just [open an issue!](https://github.com/Kolkhis/streamer-mode.nvim/issues) I'll add them!  

Jump to  

- [Installation](#installation)  
- [Setup](#setup)  
  - [Default setup](#default-setup)  
  - [Advanced Setup](#advanced-setup)  
    - [Custom Keywords](#custom-keywords)  
    - [Custom Paths](#custom-paths)  
    - [Custom Behavior and Style Options](#custom-behavior-and-style-options)  
- [Levels](#levels)  
- [Commands](#commands)  
- [Donation](#donation)  

### Current Features  

By default, Streamer Mode currently supports the concealment of a number of  
keywords. More can be added through the `setup()` function.  
The default keywords to conceal are:  
* `export`
* `alias`
* `$env:`
* `name`
* `email`
* `signingkey`
* `Hostname`
* `host`
* `IdentityFile`
* `user.name` 
* `user.email`
* `user.password`
* `API_KEY`
* `TOKEN` 
* `credential.helper`
* `server`
* `port`  

You can add your own keywords to conceal in setup.  


- Hides environment variables and sensitive `.gitconfig` information.  

- Three different levels: Secure, Edit, and Soft  

  - Check [here](#levels) or `:h sm.levels` for more information on level behaviors.  

- Ability to create type out new environment variables without displaying them (secure level), like sudo password input.  

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


After installing, just run `:StreamerMode` or `:SM` to turn on Streamer Mode. It will be off by default.  
streamer-mode.nvim applies filters to the most files that will contain sensitive information by default. Check the [default settings](#default-settings)  


### Default setup:  
To enable streamer mode by default with the preset options:  
```lua  
require('streamer-mode').setup({ preset = true, default_state = 'on' })  
```
Then just call `:StreamerModeOff` (or `:SMoff`) and Streamer Mode will be deactivated.  
  

Streamer Mode is disabled by default, which means it won't turn on when Neovim is launched.  
To enable Streamer Mode on launch:  

```lua  
require('streamer-mode').setup({ default_state = 'on' })  
```

Now Streamer Mode will be active every time a new Neovim session is launched!  
    

### Advanced Setup:  


##### These are just examples. To jump to all configuration options, click [here.](#Parameters)  

### Custom Keywords  
To set your own keywords to conceal, pass them in as a list-like table to the `setup()` function.  
The table is formatted as `keywords = { "word", "another_word }`, then `word` and `another_word` will be added to the list of keywords to be concealed.  
```lua  
require('streamer-mode').setup({
    preset = true,
    default_state = 'on',
    keywords = {
        "export",
        "alias",
        "api_key",
        "auth_token",
        "MySecretVariable",
        "MyAddress",
    }
})  
```
The kewords are not case-sensitive. Adding `API_KEY` will conceal both `API_KEY` and `api_key`.  

#### Custom Paths  
To use [defaults](#default-settings) in addition to your own paths/filetypes:  
```lua  
require('streamer-mode').setup({
  preset = true,
  paths = {
    yaml_files = '*/*.yaml',
  },
})  
```
  

#### Custom Behavior and Style Options  
If you want to customize (`conceal_char`, `exclude`, `level`, and `default_state`):  
```lua  
require('streamer-mode').setup({
  level = 'secure',
  exclude = { 'bash_aliases', 'powershell' },
  default_state = 'off',
  conceal_char = 'X'  
})  
```
  


#### Example  

Here's an example of a custom configuration:  

```lua  

require('streamer-mode').setup({
  paths = {
    -- You can use any name you want, the '*/path/*' is the important part.  
	-- Any path in here will hide exports and .gitconfig personals. (and $env:s)  
    venv = '*/venv/*',
    virtualenv = '*/virtualenv/*',
    dotenv = '*/.env',
    config = '*/.config/*',
    aliases = '~/.bash_aliases',
    dotfiles = '~/.dotfiles/*',
    nodotdot = '*/dotfiles/*',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
  },
  keywords = {
    token = true,
    auth_token = true,
    key = true,
    auth_key = true,
    export = true,
  }
  level = 'edit', -- | 'secure' | 'soft'  
  default_state = 'on', -- | 'off'  
  exclude = { 'powershell' },
  conceal_char = 'X' -- Can be any character  
})  
```
 <br /> 

While it is possible to enable Streamer Mode for all files, it's not recommended.  
It's possible for this to slow down your editor. 
Most common files that will contain sensitive information are already in the defaults (if I missed any please let me know). 
  

If you want to do this despite that, here's how:  
```lua  
require('streamer-mode').setup({ paths = { all = '*' } })  
```  

### Default Settings  

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
    dotfiles = '*/dotfiles/*',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
    configini = '*.ini',
    secretsyaml = '*.yaml',
    ssh = '*/.ssh/*',
    }
  },
  level = 'secure', -- | 'edit' | 'soft'  

  default_state = 'off',  -- Whether or not streamer mode turns on when nvim is launched.  

  conceal_char = '*'  -- Default. This is what will be displayed instead  
                      -- of your secrets.  

  exclude = { '' },  -- Any of the named defaults can go here, as strings. e.g., 'bash_aliases'  

  keywords = {
    "api_key",
    "token",
    "client_secret",
    "powershell",
    "$env:",
    "export",
    "alias",
    "name",
    "userpassword",
    "email",
    "signingkey",
    "IdentityFile",
    "server",
    "username",
    "host",
    "port",
    "hostname",
  }

})  

```

#### Parameters:  

##### All optional. Just calling this function will use the defaults.  

- `paths`: Dictionary-like Table. The paths/files that Streamer Mode will apply to.  
  - Pass in paths in the format: `paths = { name = '*/path/* }`
  - Pass in filetypes in the same format: ` paths = { name = '*.txt }`
  - You can apply streamer mode to ALL files (not recommended): `paths = { all = '*' }`
- `level`: String. The level in which Streamer Mode will be in effect.  
  See more about the different [levels](#levels) below.  
- `default_state`: Whether or not Streamer Mode will be active  
  when you first launch a Neovim session. It's recommended to set this to `'off'`,
  turning it on when needed.  
- `exclude`: List-like table of strings. Only necessary if you want to use the  
  some of the defaults, but not all of them.  
- `conceal_char`: String. This is the character that will be displayed in place of your hidden text.  

#### Example Custom Setup  

> init.lua  

```lua  
require('streamer-mode').setup({
  preset = true,
  paths = {
    shell_scripts = '*.sh',
    my_config = '*/.config/*',
    venv = '*/venv/*',
    aliases = '*/.bash_aliases',
    powershell = '*.ps1',
    gitconfig = '*/.gitconfig',
  },
  keywords = {
    'api_key',
    'token',
    'client_secret',
    'export',
    'name',
    'email',
    'user.password',
    'user.name',
    'user.email',
    'signingkey',
    'IdentityFile',
    'server',
    'username',
    'host',
    'port',
    'hostname',
  },
  level = 'edit',
  default_state = 'on',
  exclude = { 'powershell', 'dotfiles' }
})  
```

## Levels  

###### *:h sm.levels*  

There are three different levels, each with different behavior.  

- `'secure'` will disable the text becoming visible until  
  the `level` changes. (see |streamer-mode.command|)  
  You can also type out new exports (or other environment  
  variables) and the text will not be shown.  
  Like sudo password input.  
- `'edit'` (default) will enable the text to become visible when the  
  cursor goes into insert mode on the same line.  
- `'soft'` means the text will become visible when the cursor is  
  on the same line.  

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
  

# Neovim Config

Neovim config using lazy.nvim.

## Optional plugins

Optional plugin specs are located in `lua/local_plugins` (mirroring `lua/plugins`) and can be included depending on local environment.

To include an optional spec, symlink it into `lua/plugins/local/`, for example:

```sh
mkdir -p lua/plugins/local; ln -s ../../local_plugins/lang/ruby.lua lua/plugins/local/ruby.lua
```

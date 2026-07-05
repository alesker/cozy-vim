# CozyVim

![](https://github.com/user-attachments/assets/8ee6f857-c580-406c-b078-720030975e69)


Neovim config using lazy.nvim for focused work and cozy vibes.

## Features

- Language-aware editing with LSP navigation, code actions, rename, hover, codelens, diagnostics, and spell checking
    - `nvim-lspconfig`, `mason-lspconfig`, `Trouble`
- Completion, snippets, signature help, auto-pairs, and AI-assisted completion from insert mode
    - `blink.cmp`, `nvim-autopairs`, `minuet-ai`
- Syntax highlighting, indentation, folding, structural text objects, and code-aware movement
    - `nvim-treesitter`, `nvim-treesitter-textobjects`, `mini.ai`, `treesitter-context`
- Formatting and linting hooks that can be extended per language and provision required Mason tools (default support for Go, Lua, shell, Markdown, and data formats)
    - `conform.nvim`, `nvim-lint`, `mason.nvim`
- Project search and discovery through fuzzy finding, live grep, recent files, buffers, tabs, commands, help, registers, and marks
    - `telescope.nvim`
- File browsing and project tree workflows with floating directory editing, git-aware file views, previews, and reveal-current-file support
    - `oil.nvim`, `neo-tree.nvim`
- Fast navigation through per-tab marked files, numbered jump targets, jump labels, structural jumps, and enhanced marks
    - `harpoon`, `flash.nvim`, `marks.nvim`
- Git workflow support for status, commits, blame, hunks, previews, staging, and hunk navigation
    - `Neogit`, `gitsigns.nvim`
- Session and terminal workflow support for restoring workspaces and opening floating or split terminals
    - `persistence.nvim`, `toggleterm.nvim`
- Buffer, tab, and statusline UI with scoped tabs, diagnostics indicators, harpoon-aware grouping, and mode/location details
    - `bufferline.nvim`, `scope.nvim`, `lualine.nvim`
- Command, input, notification, scroll, indent, dimming, and toggle UI refinements
    - `noice.nvim`, `snacks.nvim`
- In-editor AI workflow integration through an OpenCode terminal/session bridge and work scheduler
    - `opencode.nvim`, `toggleterm.nvim`

## Optional plugins

Optional plugin specs are located in `lua/local_plugins` (mirroring `lua/plugins`) and can be included depending on local environment.

To include an optional spec, symlink it into `lua/plugins/local/`, for example:

```sh
mkdir -p lua/plugins/local; ln -s ../../local_plugins/lang/ruby.lua lua/plugins/local/ruby.lua
```

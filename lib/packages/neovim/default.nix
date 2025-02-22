{ symlinkJoin, fetchFromGitHub, vimUtils, wrapNeovim, neovim-unwrapped, tree-sitter, vimPlugins }:
let
  plugins = import ./config/plugins.nix { inherit fetchFromGitHub; };

  buildPlugin = name: vimUtils.buildVimPlugin {
    pname = name;
    version = "master";
    src = builtins.getAttr name plugins;
  };

  neovim-wrapped = wrapNeovim neovim-unwrapped {
    vimAlias = true;
    configure = {
      customRC = ''
        luafile ${./config/lua/global.lua}
        luafile ${./config/lua/lsp.lua}
        colorscheme gruvbox
      '';
      packages.myVimPackage = {
        start = with vimPlugins; [
          nvim-treesitter
          nvim-lspconfig
          nvim-lsputils
          null-ls-nvim
          gruvbox-nvim
          nerdtree
          nerdcommenter
          nvim-cmp
          cmp-nvim-lsp
          cmp-path
          cmp-buffer
          cmp-cmdline
          luasnip
          gitsigns-nvim
          vim-abolish
          lualine-nvim
          vim-rooter
          vim-surround
          vim-fugitive
          neovim-sensible
          telescope-nvim
          telescope-fzy-native-nvim
          plenary-nvim
          toggleterm-nvim
        ];
      };
    };
  };
in
symlinkJoin {
  name = "bundled-neovim";
  paths = [
    neovim-wrapped
    tree-sitter
  ];
}

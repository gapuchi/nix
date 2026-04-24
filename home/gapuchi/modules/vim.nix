{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      syntax on
    '';
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true

      vim.keymap.set("n", "<Up>", "<Nop>")
      vim.keymap.set("n", "<Down>", "<Nop>")
      vim.keymap.set("n", "<Left>", "<Nop>")
      vim.keymap.set("n", "<Right>", "<Nop>")
    '';
  };
}

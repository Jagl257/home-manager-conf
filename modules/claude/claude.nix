{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    claude-code
  ];

  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
  home.file.".claude/settings.json".source = ./settings.json;
  home.file.".claude/.claudeignore".source = ./.claudeignore;
}

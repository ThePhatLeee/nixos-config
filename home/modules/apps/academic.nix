{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-medium latexmk biblatex biber;
    })
    pandoc
    pdfgrep
    poppler-utils

    obsidian
  ];
}

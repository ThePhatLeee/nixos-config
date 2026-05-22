{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    ripgrep
    fd
    jq
    unzip
    tree
    tealdeer
    glow
    xh
    wf-recorder
    swappy
    claude-code
    mcp-server-filesystem

    pv
    hyperfine
    tokei
    procs
    bandwhich
    gping
    doggo
    viddy
  ];
}

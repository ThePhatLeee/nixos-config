{ pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];

  programs.git = {
    enable = true;
    settings = {
      user.name       = "Marko Jokinen";
      user.email      = "phat.le@thephatle.dev";
      user.signingkey = "09D801B2351193B1";

      commit.gpgsign      = true;
      gpg.program         = "gpg2";

      merge.conflictstyle  = "diff3";
      diff.colorMoved      = "default";
      pull.rebase          = false;
      push.autoSetupRemote = true;
      init.defaultBranch   = "main";
      core.pager           = "less";

      "url \"git@github.com:\"".insteadOf            = "https://github.com/";
      "url \"git@codeberg.org:\"".insteadOf          = "https://codeberg.org/";
      "url \"git@gitlab.com:\"".insteadOf            = "https://gitlab.com/";
      "url \"git@forgejo.thephatle.dev:\"".insteadOf = "https://forgejo.thephatle.dev/";
    };
  };

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };
}

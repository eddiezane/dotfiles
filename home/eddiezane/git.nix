{ pkgs, config, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Eddie Zaneski";
        email = "eddiezane@gmail.com";
        # SSH-key commit signing via 1Password. The signing key public string
        # goes in ~/.gitconfig_local so this repo can stay generic. Example:
        #   [user]
        #     signingkey = "key::ssh-ed25519 AAAA..."
        # Generate or pick the key in 1Password (Settings -> Developer ->
        # "Use the SSH agent" must be on), then "Show public key" and paste it.
      };
      alias.changelog = "log --abbrev-commit --pretty=format:'- %h - %s - %aN'";
      core.excludesfile = "~/.gitignore_global";
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      github.user = "eddiezane";
      pull.ff = "only";
      init.defaultBranch = "main";

      # Commit + tag signing via SSH (Git >= 2.34). 1Password's helper resolves
      # the private key from the agent and produces the signature.
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg = {
        format = "ssh";
        ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
        # Used by `git log --show-signature` to verify your own + others' commits.
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      };

      status.showUntrackedFiles = "all";
      "credential \"https://github.com\"" = {
        helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      };
      "credential \"https://gist.github.com\"" = {
        helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      };
      "url \"git@github.com:\"" = {
        insteadOf = "https://github.com/";
      };
      include.path = "~/.gitconfig_local";
    };
  };

  # `allowed_signers` lets `git log --show-signature` verify SSH-signed commits.
  # Format: `<email-or-*> <key-type> <base64-key>`. Add yourself + any other
  # signers whose commits you want git to mark as Good.
  home.file.".config/git/allowed_signers".text = ''
    eddiezane@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII76gJY0VgQhPOXpkihjBZDwK2OAkapxghO/21J16Mxl TEHUNICORN
  '';

  home.file.".gitignore_global".text = ''
    .DS_Store
    .direnv/
    .envrc
    .envrc.local
    *.swp
    *.qcow2
  '';

  home.packages = with pkgs; [
    # gh is in packages.nix (also referenced inline as ${pkgs.gh} in the
    # credential helper above — that resolution is independent of whether
    # the binary is on PATH).
    lazygit
    tig
    git-lfs
  ];
}

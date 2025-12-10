{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  shellAliases = {
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gdiff = "git diff";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";

    jd = "jj desc";
    jf = "jj git fetch";
    jn = "jj new";
    jp = "jj git push";
    js = "jj st";

    gh-rerun-failed = "gh run rerun $(gh run list --branch $(git rev-parse --abbrev-ref HEAD) --status failure --limit 1 --json databaseId --jq '.[0].databaseId') --failed";
  } // (if isLinux then {
    # Two decades of using a Mac has made this such a strong memory
    # that I'm just going to keep it consistent.
    pbcopy = "xclip";
    pbpaste = "xclip -o";
  } else {});

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
    '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;

  # We manage our own Nushell config via Chezmoi
  home.shell.enableNushellIntegration = false;

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------
  imports = [
    ./neovim.nix
  ];

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.awscli2
    pkgs.awsebcli

    pkgs._1password-cli
    pkgs.atuin
    pkgs.asciinema
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.ghostty
    pkgs.btop
    pkgs.i3
    pkgs.jq
    pkgs.ranger
    pkgs.rsync
    pkgs.ripgrep
    pkgs.sentry-cli
    pkgs.tig
    pkgs.ffmpeg
    pkgs.timg
    pkgs.mpv
    pkgs.tokei
    pkgs.tree
    pkgs.watch

    pkgs.gopls
    pkgs.zigpkgs."0.14.0"

    pkgs.zsh-bd
    pkgs.zsh-powerlevel10k
    pkgs.zsh-syntax-highlighting

    #{ nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    #    "claude-code"
    #  ];
    #}
    pkgs.claude-code
    pkgs.gemini-cli
    pkgs.codex

    pkgs.git-absorb
    pkgs.git-trim

    # Node is required for Copilot.vim
    pkgs.nodejs
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    pkgs.chromium
    pkgs.firefox
    pkgs.rofi
    pkgs.valgrind
    pkgs.zathura
    pkgs.xfce.xfce4-terminal
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";

    AMP_API_KEY = "op://Private/Amp_API/credential";
    OPENAI_API_KEY = "op://Private/OpenAPI_Personal/credential";
  } // (if isDarwin then {
    # See: https://github.com/NixOS/nixpkgs/issues/390751
    DISPLAY = "nixpkgs-390751";
  } else {});

  home.file = {
    ".gdbinit".source = ./gdbinit;
    ".inputrc".source = ./inputrc;
  };

  xdg.configFile = {
    "i3/config".text = builtins.readFile ./i3;
    "rofi/config.rasi".text = builtins.readFile ./rofi;
  } // (if isDarwin then {
    # Rectangle.app. This has to be imported manually using the app.
    "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
  } else {}) // (if isLinux then {
    "ghostty/config".text = builtins.readFile ./ghostty.linux;
  } else {});

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;
    shellAliases = shellAliases;
  };

  # programs.direnv= {
  #   enable = true;

  #   config = {
  #     whitelist = {
  #       prefix= [
  #         "$HOME/code/go/src/github.com/hashicorp"
  #         "$HOME/code/go/src/github.com/mitchellh"
  #       ];

  #       exact = ["$HOME/.envrc"];
  #     };
  #   };
  # };

  # programs.fish = {
  #   enable = true;
  #   shellAliases = shellAliases;
  #   interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" ([
  #     "source ${inputs.theme-bobthefish}/functions/fish_prompt.fish"
  #     "source ${inputs.theme-bobthefish}/functions/fish_right_prompt.fish"
  #     "source ${inputs.theme-bobthefish}/functions/fish_title.fish"
  #     (builtins.readFile ./config.fish)
  #     "set -g SHELL ${pkgs.fish}/bin/fish"
  #   ]));

  #   plugins = map (n: {
  #     name = n;
  #     src  = inputs.${n};
  #   }) [
  #     "fish-fzf"
  #     "fish-foreign-env"
  #     "theme-bobthefish"
  #   ];
  # };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };

    autocd = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 1000000;
      size = 100000;
    };

    defaultKeymap = "viins";

    shellAliases = {
      j = "just";
      ls = "exa";
      ll = "exa -l --header";
      la = "exa -a";
      lt = "exa --tree";
      lla = "exa -la --header";
      ".." = "cd ..";
      rdme-glow = "glow -p https://github.com/charmbracelet/glow";
      rdme-git-extras = "glow -p https://github.com/tj/git-extras/blob/master/Commands.md";
      rdme-just = "glow -p https://raw.githubusercontent.com/casey/just/master/README.adoc";

    #  sg = "BROWSER=w3m ddgr --unsafe --noua \!g ";
    #  ssg = "ddgr --unsafe --noua \!g ";
    #  sd = "BROWSER=w3m ddgr --unsafe --noua ";
    };

    initExtra = "
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r \"\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then
      source \"\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\"
    fi

    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

    export ATUIN_NOBIND=\"true\";
    eval \"$(atuin init zsh)\";
    bindkey '^r' _atuin_search_widget

    # Alt + Right Arrow → move forward a word
    bindkey '^[[1;3C' forward-word

    # Alt + Left Arrow → move backward a word
    bindkey '^[[1;3D' backward-word

    # bind to the up key, which depends on terminal mode
    bindkey '^[[A' _atuin_up_search_widget

    # export MANPAGER=\"/bin/sh -c \\\"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\\\"\";
    # export MANROFFOPT='-c'
    export PYENV_ROOT=\"$HOME/.pyenv\";
    export PATH=\"$PYENV_ROOT/bin:$PATH\";
    # export PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH;

    export PATH=\"/usr/local/opt/openjdk/bin:$PATH\";
    export PATH=\"$HOME/.cargo/bin:$PATH\";
    export PATH=\"$HOME/bin:$PATH\";

    if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
      source \"$GHOSTTY_RESOURCES_DIR\"/shell-integration/zsh/ghostty-integration
    fi
    ";

    oh-my-zsh = {
      enable = true;

      plugins = [
        "git ripgrep tig ssh-agent"
      ];
    };

    plugins = [
      {
        name = "fzf-tab";
        file = "fzf-tab.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "17ff089938a8f693689d67814af3212fc4053da1";
          sha256 = "1cizy2nlmvrblirxkl7036fnp1q55s11v5pxm7x64jx1591iy67s";
        };
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "Jono Chang";
    userEmail = "j.g.chang@gmail.com";
    # signing = {
    #   key = "523D5DC389D273BC";
    #   signByDefault = true;
    # };
    aliases = {
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "jonochang";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "code/go";
    goPrivate = [ "github.com/jonochang" ];
  };

  programs.jujutsu = {
    enable = true;

    # I don't use "settings" because the path is wrong on macOS at
    # the time of writing this.
  };

  # programs.alacritty = {
  #   enable = !isWSL;

  #   settings = {
  #     env.TERM = "xterm-256color";

  #     key_bindings = [
  #       { key = "K"; mods = "Command"; chars = "ClearHistory"; }
  #       { key = "V"; mods = "Command"; action = "Paste"; }
  #       { key = "C"; mods = "Command"; action = "Copy"; }
  #       { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
  #       { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
  #       { key = "Subtract"; mods = "Command"; action = "DecreaseFontSize"; }
  #     ];
  #   };
  # };

  # programs.kitty = {
  #   enable = !isWSL;
  #   extraConfig = builtins.readFile ./kitty;
  # };

  programs.i3status = {
    enable = isLinux && !isWSL;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  # programs.neovim = {
  #   enable = true;
  #   package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  # };

  # programs.atuin = {
  #   enable = true;
  # };

  # programs.nushell = {
  #   enable = true;
  # };

  # programs.oh-my-posh = {
  #   enable = true;
  # };

  # services.gpg-agent = {
  #   enable = isLinux;
  #   pinentry.package = pkgs.pinentry-tty;

  #   # cache the keys forever so we don't get asked for a password
  #   defaultCacheTtl = 31536000;
  #   maxCacheTtl = 31536000;
  # };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf (isLinux && !isWSL) {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}

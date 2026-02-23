{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.zsh.enable = true;

  users.users.jonochang = {
    isNormalUser = true;
    home = "/home/jonochang";
    extraGroups = [ "docker" "lxd" "wheel" "ydotool" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$wU04qVoXnnAsStf5$I0LYbQUbacScbFdvZDPif5zu2/.xAUQAhAE7.qLa6HUdeG4sVjIBW9bzYuL0SVfAFFQiYh37DSDkqY3t/jKs/0";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAw2L3BWpEHXNl8jFbEdizEkKt2eAM6ExCWuGxBWKDAZ295F+DqiD3Lv+jJzxvH/wuyRs9UJn9XkIEc8MRP8uGv0mW5ad1msCnkoCIDGdQfEM4jgBx4chrLYbUdm4+A08uwsukmvQFbJMHSQ/2dS62WEz69urSFHwFZzzFGoxw2cYLVZpkc621Q4FN3FvUlhchfyLx35wK5qQ6HB0Ceeeb1MkciwoMSnbE6O7qhDqkdAAgItgiS9HrQwe1woBdK0oxqHSYVPaUc+/h5FC8grKcUV7VTsuytTtHxqsR/tmGQ5az3qn2xDw1hrR6n0vLvTpvmQ0fG3xrrMn14D6mes9DKQ== jonochang@kirillrdy-imac.local"
    ];
  };
}

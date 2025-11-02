{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.zsh.enable = true;

  users.users.simon = {
    isNormalUser = true;
    home = "/home/simon";
    extraGroups = [ "docker" "lxd" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$wU04qVoXnnAsStf5$I0LYbQUbacScbFdvZDPif5zu2/.xAUQAhAE7.qLa6HUdeG4sVjIBW9bzYuL0SVfAFFQiYh37DSDkqY3t/jKs/0";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmfh7QXsvyfWLc86DfFew9DDCV4eriZYrSfy+XrxJdrohV3dHX3VKwTSNEPqDXBDvP99Dhaoqvp8orb1JkLMkLejSUXQKRNltcoPpykj5XcE0ysaUXye9tvtTWAkVbG74E5uRzumbtxoe3RuktilMuFPDiGwSzNHT5FuitrI3gjfums7c87plkcFmuAqiArPjTOVchSXQrx8mihm2NnIothjguvvwlnWcJbM7/CYioNoDqRj1TuPZ0w/3G6/FgnRNx3CFxfujXB0etx6W4wGf6Jt7J9dk0fvKddDUiQoEEDJqH56C+O/rqlODOxyZlnAZS7Ds/YJvECJHgiEqOXwSL simon.hudson@silverpond.com.au"
    ];
  };
}

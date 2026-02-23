{ config, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware/vm-aarch64-utm.nix
    ./vm-shared.nix
  ];

  networking.useNetworkd = true;

  # Interface is this on my M1
  systemd.network.networks."10-enp0s10" = {
    matchConfig.Name = "enp0s10";
    networkConfig.DHCP = "yes";
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
  };

  # Use our preferred DNS
  services.resolved.enable = true;

  # Qemu
  services.spice-vdagentd.enable = true;

  # For now, we need this since hardware acceleration does not work.
  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;
}

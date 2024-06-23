{ pkgs, ... }:

{
  imports = [
    ./features/nix.nix
    ./features/fish.nix
    ./features/avahi.nix
    ./features/services/nginx.nix
    ./features/services/uptime-kuma.nix
    ./features/services/prometheus.nix
    ./features/services/loki.nix
    ./features/services/grafana.nix
    ./features/services/zabbix.nix
  ];

  time.timeZone = "Asia/Shanghai";
  # i18n.defaultLocale = "zh_CN.UTF-8";

  # Users
  users = {
    # Don't allow mutation of users outside of the config.
    mutableUsers = false;
    # Privilege User
    users.root.openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBC5HypvbsI4xvwfd4Uw7D+SV0AevYPS/nCarFwfBwrMHKybbqUJV1cLM1ySZPxXcZD7+3m48Riiwlssh6o7WM/M= openpgp:0xDE4C24F6" ];
  };

  # Basic Packages
  environment.systemPackages = with pkgs; [ htop btop atuin ];

  system.stateVersion = "24.05";
}
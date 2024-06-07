{ pkgs, config, ... }:
{
  services.uptime-kuma = {
    enable = true;
    settings.UPTIME_KUMA_ALLOW_ALL_CHROME_EXEC = "1";
  };

  systemd.services.uptime-kuma.serviceConfig.AmbientCapabilities = "CAP_NET_RAW";

  # Browser Engine
  environment.systemPackages = with pkgs; [ chromium ];

  services.nginx.virtualHosts."uptime.home.lostattractor.net" = {
    locations."/".proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${config.services.uptime-kuma.settings.PORT}";
    forceSSL = true;
    enableACME = true;
  };
}
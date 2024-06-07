{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server.domain = "grafana.home.lostattractor.net";
  };

  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
    forceSSL = true;
    enableACME = true;
  };
}
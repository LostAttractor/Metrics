{ config, ... }:
{
  services.prometheus = {
    enable = true;

    globalConfig = {
      scrape_interval = "15s"; # Set the scrape interval to every 15 seconds. Default is every 1 minute.
      evaluation_interval = "15s"; # Evaluate rules every 15 seconds. The default is every 1 minute.
      # scrape_timeout is set to the global default (10s).
    };

    scrapeConfigs = [
      ## Here it's Prometheus itself.
      {
        job_name = "prometheus";
        static_configs = [{ targets = [ "localhost:${toString config.services.prometheus.port}" ]; }];
      }
      ## Application
      # Nix-CI
      {
        job_name = "nix-ci";
        static_configs = [
          { 
            targets = [ "hydra.home.lostattractor.net:9100" ];
            labels.group = "hydra";
          }
          {
            targets = [ "nixbuilder1.home.lostattractor.net:9100" "nixbuilder2.home.lostattractor.net:9100" ];
            labels.group = "nixbuilder";
          }
        ];
      }
      # NixNAS
      {
        job_name = "nixnas";
        static_configs = [{ targets = [ "nixnas.home.lostattractor.net:9100" ]; }];
      }
      ## Infrastructure
      # Router
      {
        job_name = "router";
        static_configs = [{ targets = [ "router.local:9100" ]; }];
      }
      {
        job_name = "dnsmasq";
        static_configs = [{ targets = [ "router.local:9153" ]; }];
      }
      {
        job_name = "mosdns";
        static_configs = [{ targets = [ "router.local:9154" ]; }];
      }
    ];
  };

  services.nginx.virtualHosts."prometheus.home.lostattractor.net" = {
    locations."/".proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
    forceSSL = true;
    enableACME = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.prometheus.port ];
}
{ config, ... }:
{
  # https://github.com/grafana/loki/blob/main/cmd/loki/loki-local-config.yaml
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3100;
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };  
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };
      query_range.results_cache.cache.embedded_cache = {
        enabled = true;
        max_size_mb = 100;
      };
      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      # ruler.alertmanager_url = "http://localhost:9093";
      frontend.encoding = "protobuf";
    };
  };

  services.nginx.virtualHosts."loki.home.lostattractor.net" = {
    locations."/".proxyPass = "http://${config.services.loki.configuration.common.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}";
    forceSSL = true;
    enableACME = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.loki.configuration.server.http_listen_port ];
}
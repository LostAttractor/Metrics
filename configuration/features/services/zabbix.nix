_:
{
  services.zabbixServer.enable = true;
  services.zabbixWeb = {
    enable = true;
    frontend = "nginx";
    hostname = "zabbix.home.lostattractor.net";
    nginx.virtualHost = {
      forceSSL = true;
      enableACME = true;
    };
  };

  services.zabbixAgent = {
    enable = true;
    server = "localhost";
  };
}
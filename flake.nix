{
  description = "ChaosAttractor's NixNAS Server Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, deploy-rs, ... }: let
    user = "lostattractor";
  in rec {
    # Metrics@NUC9.home.lostattractor.net
    nixosConfigurations."metrics@nuc9.home.lostattractor.net" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit user; };
      modules = [
        ./hardware/lxc
        ./configuration
        { networking.hostName = "metrics"; }
      ];
    };

    # Deploy-RS Configuration
    deploy = {
      sshUser = "root";
      magicRollback = false;

      nodes."metrics@nuc9.home.lostattractor.net" = {
        hostname = "metrics.home.lostattractor.net";
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations."metrics@nuc9.home.lostattractor.net";
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks deploy) deploy-rs.lib;

    hydraJobs = with nixpkgs.lib; {
      nixosConfigurations = mapAttrs' (name: config:
        nameValuePair name config.config.system.build.toplevel)
        nixosConfigurations;
      tarball = mapAttrs' (name: config:
        nameValuePair name config.config.system.build.tarball)
        nixosConfigurations;
    };
  };
}

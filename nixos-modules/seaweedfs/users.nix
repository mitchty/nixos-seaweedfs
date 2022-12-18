{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.services.seaweedfs.staticUser;

in
{
  options = {
    services.seaweedfs.staticUser = {
      enable = mkEnableOption "Use a static user+group for seaweed daemons";
    };
  };
  config = mkIf cfg.enable {
    users = {
      groups.weed = { };
      users = {
        weed = {
          isSystemUser = true;
          description = "seaweedfs daemon user";
          createHome = false;
          home = "/dev/null";
          group = "weed";
        };
      };
    };
  };
}

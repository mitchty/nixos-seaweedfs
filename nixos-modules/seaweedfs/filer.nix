{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.services.seaweedfs.filer;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.seaweedfs.filer = {
    enable = mkEnableOption "seaweedfs filer server";

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;

        options.leveldb2 = {
          enabled = mkOption {
            description = mdDoc "blah";
            type = types.bool;
            default = true;
          };

          dir = mkOption {
            description = mdDoc "blah";
            default = "/tmp";
            type = types.path;
          };
        };
      };
      default = { };
    };
  };
  config = mkIf cfg.enable {
    environment.etc."seaweedfs/filer.toml".source = settingsFormat.generate "seaweedfs-filer.toml" cfg.settings;

    networking.firewall = {
      allowedTCPPorts = [ 8888 18888 ];
    };

    systemd.services.seaweedfs-filer =
      {
        description = "seaweedfs filer";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "weed";
          Group = "weed";
          # DynamicUser = mkDefault true;
          # PrivateTmp = mkDefault true;
          CacheDirectory = "seaweedfs-filer";
          ConfigurationDirectory = "seaweedfs-filer";
          RuntimeDirectory = "seaweedfs-filer";
          StateDirectory = "seaweedfs-filer";
          ExecStart = "${pkgs.seaweedfs}/bin/weed filer -s3";
          LimitNOFILE = mkDefault 65536;
          LimitNPROC = mkDefault 65536;
        };
      };
  };
}

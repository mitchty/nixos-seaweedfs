{
  inputs = {
    # should keep this at a mostly stable release methinks, unstable is a bit...
    # well lot of needless rebuilds of dependencies.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
    in
    flake-utils.lib.eachSystem systems
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        checks = import ./checks { inherit self system nixpkgs; } // {
          nixpkgs-fmt = pkgs.runCommand "check-nix-format" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            install -dm755 $out
          '';
          versions = pkgs.runCommand "check-versions" { } ''
            export PATH="${nixpkgs.lib.makeBinPath [pkgs.coreutils pkgs.curl pkgs.jq pkgs.htmlq]}:$PATH"
            DIR=${./.} sh ${./bin/versions}
            install -dm755 $out
          '';
        };
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          seaweedfs = pkgs.callPackage ./pkgs/seaweedfs { };
        } // flake-utils.lib.flattenTree {
#        default = pkgs.stdenv.mkDerivation {
#          name = "seaweedfs";
#          buildInputs = [ packages.seaweedfs ];
#        };
        };
      })
    // {
      overlays.default = final: prev: {
        seaweedfs = prev.callPackage ./pkgs/seaweedfs { };
      };
      nixosModules = {
        seaweedfs = import ./nixos-modules/seaweedfs { };
      };
    };
}

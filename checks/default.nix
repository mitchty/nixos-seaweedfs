{ self
, nixpkgs
, system
,
}: {
  simple = import ./simple.nix { inherit self nixpkgs system; };
  multimaster = import ./multimaster.nix { inherit self nixpkgs system; };
}

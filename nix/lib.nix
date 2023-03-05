{ lib, pkgs, pkgs-i386, ... }:
rec {
  targetSpec = pkgs.rust.toRustTargetSpec pkgs-i386.stdenv.targetPlatform;

  cargoWithDeps = { cargoExtraArgs ? "", ... }@attrs:
    let
      commonArgs = attrs // {
        cargoExtraArgs = "--target ${targetSpec} ${cargoExtraArgs}";
      };

      cargoArtifacts = lib.crane.buildDepsOnly commonArgs;
    in
    lib.crane.buildPackage (commonArgs // { inherit cargoArtifacts; });
}

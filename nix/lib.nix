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

  vendorCargoDeps' = cargoLocks:
    let
      inherit (builtins)
        attrNames
        concatMap
        readFile
        fromToml;

      inherit (lib)
        unique
        concatMapStrings
        escapeShellArg;

      linkSources = sources: concatMapStrings
        (name: ''
          ln -s ${escapeShellArg sources.${name}} $out/${escapeShellArg name}
        '')
        (attrNames sources);

      locks = map fromTOML (map readFile cargoLocks);
      lockPackages = unique (concatMap (lock: lock.package) locks);

      cargoConfigs = (lib.crane.findCargoFiles ./..).cargoConfigs;

      vendoredRegistries = lib.crane.vendorCargoRegistries { inherit lockPackages cargoConfigs; };
      vendoredGit = lib.crane.vendorGitDeps { inherit lockPackages; };
    in
    pkgs.runCommandLocal "vendor-cargo-deps" { } ''
      mkdir -p $out
      cat >>$out/config.toml <<EOF
      ${vendoredRegistries.config}
      ${vendoredGit.config}
      EOF

      ${linkSources vendoredRegistries.sources}
      ${linkSources vendoredGit.sources}
    '';
}

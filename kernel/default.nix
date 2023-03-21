{ lib, rustToolchain }:
lib.my.cargoWithDeps {
  src = lib.crane.cleanCargoSource ./.;

  cargoExtraArgs = "-Zbuild-std=core,compiler_builtins,alloc,proc_macro -Zbuild-std-features=compiler-builtins-mem";

  doCheck = false; # `test` from std does not build

  # No need to check binary caches, they don't exist
  preferLocalBuild = true;
  allowSubstitutes = false;

  # FIXME: Vendor dependencies for std crates; See https://github.com/ipetkov/crane/issues/260
  cargoVendorDir = lib.my.vendorCargoDeps' [
    (rustToolchain.passthru.availableComponents.rust-src + "/lib/rustlib/src/rust/Cargo.lock")
    ../Cargo.lock
  ];
}

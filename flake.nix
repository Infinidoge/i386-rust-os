{
  description = "A small operating system written in Rust targetting the i386 processor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    crane.url = "github:ipetkov/crane";

    rust-overlay.url = "github:oxalica/rust-overlay";

    # Input consolidation
    crane.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, crane, rust-overlay, ... }:
    let
      inherit (flake-utils.lib) eachSystem system;
    in
    eachSystem (with system; [ x86_64-linux ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
          ];
        };

        pkgs-i386 = (import nixpkgs {
          inherit system;
          crossSystem = {
            config = "i386-elf";
            rustc.platform = {
              data-layout = "e-m:e-p:32:32";
              llvm-target = "i386-none-elf";
              target-endian = "little";
              target-pointer-width = "32";
              target-c-int-width = "32";
              os = "none";
              arch = "x86";
              executables = true;
              linker-flavor = "ld.lld";
              linker = "rust-lld";
              panic-strategy = "abort";
              features = "-mmx,-sse,+soft-float";
            };
          };
        }).buildPackages;

        rustToolchain = (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
          extensions = [ "rust-src" ];
        }));


        lib = pkgs.lib.extend (final: prev: {
          my = (import ./nix/lib.nix { lib = final; inherit pkgs pkgs-i386; });
          crane = (crane.mkLib pkgs).overrideToolchain rustToolchain;
        });


        callPackage = pkgs.newScope {
          inherit lib pkgs-i386 rustToolchain;
        };
      in
      rec {
        devShells.default = pkgs.mkShell {
          CARGO_BUILD_TARGET = lib.my.targetSpec;

          buildInputs = with pkgs; [
            nasm
            rustToolchain
          ];
        };

        packages = rec {
          bootloader = callPackage ./boot { };
          kernel = callPackage ./kernel { };
          os-image = pkgs.runCommandLocal "os-image.bin" { } "cat ${bootloader} ${lib.getExe kernel} > $out";

          toolchain = rustToolchain;

          default = os-image;
        };

        apps = let runners = callPackage ./nix/run.nix { inherit (packages) os-image; }; in rec {
          inherit (runners) run curses;
          default = curses;
        };
      }
    );
}

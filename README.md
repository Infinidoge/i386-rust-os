# Rust Operating System on i386

This is my personal attempt to redo https://github.com/cfenollosa/os-tutorial (and by extension https://github.com/Infinidoge/os-tutorial) in Rust.

It uses Nix much more extensively in the tooling.

## Outputs

### Buildables

- `bootloader`: Assembles the [bootloader](./boot)
- `kernel`: Builds the [kernek](./kernel)
- `os-image`: Creates an OS image by combining the bootloader and kernel
- `toolchain`: The Rust toolchain used to do the compilation (Nightly, `rust-src` included)
- `default`: Alias of `os-image`

### Apps

- `run`: Runs OS image with QEMU i386 with VGA
- `curses`: Runs OS image with QEMU i386 in Curses mode
- `default`: Alias of `curses`

### DevShells

- `default`: Sets `CARGO_BUILD_TARGET` environment variable, includes `nasm` and the Rust toolchain in `PATH`

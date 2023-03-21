{ stdenv, nasm }:
stdenv.mkDerivation {
  name = "bootsect.bin";

  # No need to check binary caches, they don't exist
  preferLocalBuild = true;
  allowSubstitutes = false;

  buildInputs = [ nasm ];

  src = ./.;

  buildPhase = ''
    nasm bootsect.asm -f bin -o $out
  '';
}

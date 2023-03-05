{ stdenv, nasm }:
stdenv.mkDerivation {
  name = "bootsect.bin";

  buildInputs = [ nasm ];

  src = ./.;

  buildPhase = ''
    nasm bootsect.asm -f bin -o $out
  '';
}

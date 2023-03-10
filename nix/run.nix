{ lib
, writeScriptBin
, qemu
  # , pkgs-i386
, os-image
}:
let
  tmp = "tmp=$(mktemp -d --tmpdir rust-kernel.XXXX); cd $tmp";
  i386 = "${qemu}/bin/qemu-system-i386";
  qemuArgs = "-boot order=a -drive file=os-image.bin,index=0,if=floppy,format=raw";
in
lib.mapAttrs (_: script: { type = "app"; program = lib.getExe script; })
{
  run = writeScriptBin "run" ''
    ${tmp}
    cp ${os-image} os-image.bin
    chmod u+rwx os-image.bin
    ${i386} -vga std ${qemuArgs}
  '';

  curses = writeScriptBin "curses" ''
    ${tmp}
    cp ${os-image} os-image.bin
    chmod u+rwx os-image.bin
    ${i386} -display curses ${qemuArgs}
  '';

  # .elf file not yet generated
  # debug = writeScriptBin "debug" ''
  #   ${tmp}
  #   cp ${drv}/os-image.bin ${drv}/kernel.elf .
  #   chmod u+rwx os-image.bin
  #   ${i386} -display curses -s ${qemuArgs}
  # '';

  # gdb = writeScriptBin "gdb" ''
  #   ${tmp}
  #   cp ${drv}/kernel.elf .
  #   cp -r ${drv.src}/* .
  #   ${pkgs-i386.gdb}/bin/i386-elf-gdb -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"
  # '';
}

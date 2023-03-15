#![no_std]
#![no_main]
#![allow(unused_imports)]

use core::arch::asm;
use i386_os::{
    drivers::screen::{paint, print, COLS, ROWS, VIDEO_ADDRESS},
    AsciiStr,
};

const HELLO: AsciiStr = AsciiStr(b"Hello World!");

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // Let screen 'chill' before doing anything
    // For some reason if you try to write to the screen too quickly,
    // The bootloader hasn't finished printing, so the text from the bootloader is still there
    wait(1000);

    // Clear the screen:
    // for x in 0..COLS {
    //     for y in 0..ROWS {
    //         paint((x, y).into(), ' ', 0x0f);
    //     }
    // }
    // Currently disabled during testing, will be factored out

    // Print 'Hello World!' to the screen
    for (i, &byte) in HELLO.0.iter().enumerate() {
        paint((0, i), byte, 0x0b);
    }
    // This works properly, it prints just fine

    // (Attempt to) print 'Hello World!' to the screen
    print(HELLO, 0x0b);
    // This *does not* work properly, since `print` is imported from the srceen driver
    // If the `print` use at the top is commented out, and the print function below
    // (which is identical to the one in the module)
    // is uncommented, it works just fine.
    // WHY???

    loop {}
}

// pub fn print(string: AsciiStr, style: u8) {
//     for (i, &byte) in string.0.iter().enumerate() {
//         paint(
//             // (min(pos.row + (i / COLS), ROWS), (pos.col + i) % COLS),
//             (1, i),
//             byte,
//             style,
//         );
//     }
// }

fn wait(value: u32) {
    for _ in 0..value {
        unsafe {
            asm!("");
        }
    }
}

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

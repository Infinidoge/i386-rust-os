#![no_std]
#![no_main]

use core::arch::asm;

const ROWS: i32 = 25;
const COLS: i32 = 80;

static HELLO: &[u8] = b"Hello World!";

#[no_mangle]
pub extern "C" fn _start() -> ! {
    wait(1000); // Let screen 'chill' before doing anything

    let vga_buffer = 0xb8000 as *mut u8;

    for i in 0..(ROWS * COLS) {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = b' ';
            *vga_buffer.offset(i as isize * 2 + 1) = 0x0f;
        }
    }

    for (i, &byte) in HELLO.iter().enumerate() {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = byte;
            *vga_buffer.offset(i as isize * 2 + 1) = 0xb;
        }
    }

    loop {}
}

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

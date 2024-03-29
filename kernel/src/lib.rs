#![no_std]

pub mod cpu;
pub mod drivers;

#[repr(transparent)]
pub struct AsciiStr<'a>(pub &'a [u8]);

pub type AsciiChar = u8;

use core::arch::asm;

pub fn wait(value: u32) {
    for _ in 0..value {
        unsafe {
            asm!("");
        }
    }
}

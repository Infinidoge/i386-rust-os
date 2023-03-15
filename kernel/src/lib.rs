#![no_std]

pub mod cpu;
pub mod drivers;

#[repr(transparent)]
pub struct AsciiStr<'a>(pub &'a [u8]);

pub type AsciiChar = u8;

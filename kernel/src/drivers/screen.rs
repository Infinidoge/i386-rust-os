#![allow(dead_code)]

// use core::cmp::min;

use crate::{
    cpu::ports::{port_byte_in, port_byte_out},
    AsciiChar, AsciiStr,
};

pub const ROWS: usize = 25;
pub const COLS: usize = 80;
pub const VIDEO_ADDRESS: u32 = 0xb8000;

const REG_SCREEN_CTRL: u16 = 0x3d4;
const REG_SCREEN_DATA: u16 = 0x3d5;

pub struct Pos {
    row: usize,
    col: usize,
}

impl From<(usize, usize)> for Pos {
    fn from(i: (usize, usize)) -> Pos {
        Pos { row: i.0, col: i.1 }
    }
}

#[repr(C)]
struct ScreenChar {
    ascii_character: u8,
    color_code: u8,
}

#[repr(transparent)]
pub struct Buffer {
    chars: [[ScreenChar; COLS]; ROWS],
}

pub fn paint(position: (usize, usize), symbol: AsciiChar, style: u8) {
    let pos: Pos = position.into();
    let mut vga_buffer: &'static mut Buffer = unsafe { &mut *(VIDEO_ADDRESS as *mut Buffer) };

    vga_buffer.chars[pos.row][pos.col] = ScreenChar {
        ascii_character: symbol,
        color_code: style,
    };
}

pub fn print(string: AsciiStr, style: u8) {
    for (i, &byte) in string.0.iter().enumerate() {
        paint(
            // (min(pos.row + (i / COLS), ROWS), (pos.col + i) % COLS),
            (1, i),
            byte,
            style,
        );
    }
}

fn get_cursor_offset() -> usize {
    port_byte_out(REG_SCREEN_CTRL, 14);
    let mut offset: usize = (port_byte_in(REG_SCREEN_DATA) as usize) << 8;
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA) as usize;
    return offset * 2;
}

fn set_cursor_offset(offset: usize) {
    let offset = offset / 2;
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (offset >> 8) as u8);
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (offset & 0xff) as u8);
}

fn get_offset(x: usize, y: usize) -> usize {
    2 * (x + y * COLS)
}

fn get_offset_row(offset: usize) -> usize {
    offset / (2 * COLS)
}

fn get_offset_col(offset: usize) -> usize {
    (offset - (get_offset_row(offset) * 2 * COLS)) / 2
}

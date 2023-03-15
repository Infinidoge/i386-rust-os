use core::arch::asm;

pub fn port_byte_in(port: u16) -> u8 {
    let mut result: u8;

    unsafe {
        asm!(
            "in al, dx",
            out("al") result,
            in("dx") port,
        );
    }

    result
}

pub fn port_byte_out(port: u16, data: u8) {
    unsafe {
        asm!(
            "out dx, al",
            in("dx") port,
            in("al") data,
        )
    }
}

pub fn port_word_in(port: u16) -> u16 {
    let mut result: u16;

    unsafe {
        asm!(
            "in ax, dx",
            out("ax") result,
            in("dx") port,
        );
    }

    result
}

pub fn port_word_out(port: u16, data: u16) {
    unsafe {
        asm!(
            "out dx, ax",
            in("dx") port,
            in("ax") data,
        )
    }
}

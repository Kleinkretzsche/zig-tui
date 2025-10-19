const std = @import("std");
const linux = @import("linux.zig");
const t = @import("types.zig");
const builtin = @import("builtin");

/// Control Sequence Introducer: ESC key, followed by '[' character
pub const CSI = "\x1b[";

/// The ESC character
pub const ESC = '\x1b';

// Sets the number of column and rows to very high numbers, trying to maximize
// the window.
pub const WinMaximize = CSI ++ "999C" ++ CSI ++ "999B";

// Reports the cursor position (CPR) by transmitting ESC[n;mR, where n is the
// row and m is the column
pub const ReadCursorPos = CSI ++ "6n";

// CSI sequence to clear the screen.
pub const ClearScreen = CSI ++ "2J" ++ CSI ++ "H";

pub fn getWindowSize() !t.Screen {
    if (builtin.is_test) return error.getWindowSizeFailed;

    var screen: t.Screen = undefined;
    var wsz: std.posix.winsize = undefined;

    if (linux.winsize(&wsz) == -1 or wsz.col == 0) {
        screen = try getCursorPosition();
    } else {
        screen = t.Screen{
            .rows = wsz.row,
            .cols = wsz.col,
        };
    }
    return screen;
}

pub fn write_char_at(i: u8, j: u8, c: u8) !void {
    var j_copy = j;
    var i_copy = i;

    var buf: [256]u8 = undefined;
    var n = buf.len - 1;

    buf[n] = c;
    n -= 1;
    buf[n] = 'H';

    while (j_copy != 0) : (j_copy /= 10) {
        n -= 1;
        buf[n] = (j_copy % 10) + '0';
    }

    n -= 1;
    buf[n] = ';';

    while (i_copy != 0) : (i_copy /= 10) {
        n -= 1;
        buf[n] = (i_copy % 10) + '0';
    }

    n -= 1;
    buf[n] = '[';
    n -= 1;
    buf[n] = '\x1b';
    return try linux.write(buf[n..]);
}

pub fn getCursorPosition() !t.Screen {
    var buf: [32]u8 = undefined;
    try linux.write(WinMaximize ++ ReadCursorPos);
    var nread = try linux.readChars(&buf);
    // ignore the final R character
    if (buf[nread - 1] == 'R') {
        nread -= 1;
    } else if (try linux.readChars(buf[nread..]) != 1 or buf[nread] != 'R') {
        return error.CursorError;
    }
    if (buf[0] != ESC or buf[1] != '[') return error.CursorError;

    var screen = t.Screen{};
    var semicolon: bool = false;
    var digits: u8 = 0;

    // lets not depend on sscanf :)
    var i = nread;
    while (i > 2) {
        i -= 1;
        if (buf[i] == ';') {
            semicolon = true;
            digits = 0;
        } else if (semicolon) {
            screen.rows += (buf[i] - '0') * try std.math.powi(usize, 10, digits);
            digits += 1;
        } else {
            screen.cols += (buf[i] - '0') * try std.math.powi(usize, 10, digits);
            digits += 1;
        }
    }
    if (screen.cols == 0 or screen.rows == 0) {
        return error.CursorError;
    }
    return screen;
}

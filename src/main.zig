const std = @import("std");
const linux = @import("linux.zig");
const ansi = @import("ansi.zig");

var orig_termios: std.os.linux.termios = undefined;

pub fn main() !void {
    orig_termios = try linux.enableRawMode();
    defer linux.disableRawMode(orig_termios);

    const win = try ansi.getWindowSize();

    _ = try linux.write(ansi.ClearScreen);

    const text = "hello world";
    var i: u8 = 0;
    while (i < text.len) : (i += 1) {
        try ansi.write_char_at(@intCast(win.rows / 2), @intCast(win.cols / 2 - text.len / 2 + i), text[i]);
    }

    try linux.write(ansi.WinMaximize);

    var buf: [1]u8 = undefined;
    while (try linux.readChars(&buf) == 1) {
        if (buf[0] == 'q') {
            break;
        }
    }

    try linux.write(ansi.ClearScreen);
}

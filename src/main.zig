const std = @import("std");
const linux = @import("linux.zig");
const ansi = @import("ansi.zig");

var orig_termios: std.os.linux.termios = undefined;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    orig_termios = try linux.enableRawMode();
    defer linux.disableRawMode(orig_termios);

    const win = try ansi.getWindowSize();

    var term_buf = try allocator.alloc(u8, win.cols * win.rows);

    @memset(term_buf, ' ');

    term_buf[win.cols * 20 + 50] = '*';

    _ = try linux.write(ansi.ClearScreen);

    _ = try linux.write(term_buf);

    var buf: [1]u8 = undefined;
    while (try linux.readChars(&buf) == 1) {
        if (buf[0] == 'q') {
            break;
        }
    }

    try linux.write(ansi.ClearScreen);
}

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
    defer allocator.free(term_buf);

    @memset(term_buf, ' ');

    term_buf[win.cols * 20 + 50] = '*';

    _ = try linux.write(ansi.ClearScreen);

    const daniel = "hello world";
    var i: u8 = 0;
    while (i < daniel.len) : (i += 1) {
        try ansi.write_char_at(@intCast(win.rows / 2), @intCast(win.cols / 2 - daniel.len / 2 + i), daniel[i]);
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

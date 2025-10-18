const std = @import("std");
const posix = std.posix;
const linux = @import("linux.zig");

var orig_termios: std.os.linux.termios = undefined;

pub fn main() !void {
    orig_termios = try linux.enableRawMode();
    defer linux.disableRawMode(orig_termios);

    var buf: [8]u8 = undefined;
    var n: usize = 0;
    while (n < buf.len) : (n += 1) {
        _ = try linux.readChars(buf[n..]);
        if (buf[n] == '\n') {
            break;
        }
    }

    std.debug.print("{s}\n", .{buf[0..n]});
}

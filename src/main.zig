const std = @import("std");

pub fn main() !void {
    const file = try std.fs.openFileAbsolute("/dev/pts/2", .{
        .allow_ctty = true,
        .mode = .read_write,
    });

    defer file.close();

    while (true) {
        _ = try file.write(&[_]u8{ 0x1B, '[', '2', 'J' });
    }
}

const std = @import("std");
const ArrayList = std.ArrayList;

pub const Buffer = struct {
    lines: ArrayList(ArrayList(u8)),

    pub fn create(allocator: *std.mem.Allocator) Buffer {
        return Buffer {
            .lines=ArrayList(ArrayList(u8)).init(allocator),
        };
    }

    pub fn deinit(self: Buffer) void {
        for (self.lines.items) |line| {
            line.deinit();
        }
        self.lines.deinit();
    }
};
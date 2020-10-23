const std = @import("std");
const ArrayList = std.ArrayList;

pub const Buffer = struct {
    allocator: *std.mem.Allocator,
    lines: ArrayList(ArrayList(u8)),

    pub fn create(allocator: *std.mem.Allocator) Buffer {
        return Buffer {
            .allocator=allocator,
            .lines=ArrayList(ArrayList(u8)).init(allocator),
        };
    }

    pub fn deinit(self: Buffer) void {
        for (self.lines.items) |line| {
            line.deinit();
        }
        self.lines.deinit();
    }

    pub fn append(self: *Buffer, chars: []u8) void {
        if (self.lines.items.len == 0) {
            self.lines.append(ArrayList(u8).init(self.allocator)) catch unreachable;
        }
        self.lines.items[0].appendSlice(chars) catch unreachable;
    }

    pub fn toString(self: *Buffer) []u8 {
        return self.lines.items[0].items;
    }
};
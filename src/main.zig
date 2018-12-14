const std = @import("std");
const mem = std.mem;

fn equal(a: []const u8, b: []const u8) bool {
    return mem.eql(u8, a, b);
}

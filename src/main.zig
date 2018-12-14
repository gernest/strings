const std = @import("std");
const unicode = @import("unicode");
const utf8 = unicode.utf8;
const mem = std.mem;
const warn = std.debug.warn;

pub fn equal(a: []const u8, b: []const u8) bool {
    return mem.eql(u8, a, b);
}

pub fn compare(a: []const u8, b: []const u8) mem.Compare {
    return mem.compare(u8, a, b);
}

const Exploding = struct {
    src: []const u8,
    pos: usize,
    size: usize,

    pub fn init(src: []const u8) Exploding {
        return Exploding{ .src = src, .pos = 0, .size = src.len };
    }

    pub fn next(self: *Exploding) !?[]const u8 {
        if (self.size == 0 or (self.pos >= self.size)) {
            return null;
        }
        if (self.size == 1) {
            self.pos += 1;
            return self.src;
        }
        const rune = try utf8.decodeRune(self.src[self.pos..]);
        const o = self.pos;
        self.pos += rune.size;
        return self.src[o..self.pos];
    }
};

test "explode" {
    const e = &Exploding.init("abcdefg");
    while (try e.next()) |v| {
        warn("{}\n", v);
    }
}

pub fn indexByte(b: []const u8, c: u8) ?usize {
    return mem.indexOfScalar(u8, a, c);
}

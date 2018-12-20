const std = @import("std");
const Buffer = std.Buffer;
const unicode = @import("unicode");
const utf8 = unicode.utf8;
const mem = std.mem;
const Allocator = mem.Allocator;
const warn = std.debug.warn;

pub fn equal(a: []const u8, b: []const u8) bool {
    return mem.eql(u8, a, b);
}

/// compare compares the two strings.
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

pub fn indexByte(b: []const u8, c: u8) ?usize {
    return mem.indexOfScalar(u8, a, c);
}

/// returns true if sub_slice is within s.
pub fn contains(s: []const u8, sub_slice: []const u8) bool {
    return mem.indexOf(u8, s, sub_slice) != null;
}

/// hasPrefix returns true if slice s begins with prefix.
pub fn hasPrefix(s: []const u8, prefix: []const u8) bool {
    return s.len >= prefix.len and
        equal(s[0..prefix.len], prefix);
}

pub fn hasSuffix(s: []const u8, suffix: []const u8) bool {
    return s.len >= suffix.len and
        equal(s[s.len - suffix.len ..], suffix);
}

pub fn trimPrefix(s: []const u8, prefix: []const u8) []const u8 {
    return mem.trimLeft(u8, s, prefix);
}

pub fn trimSuffix(s: []const u8, suffix: []const u8) []const u8 {
    return mem.trimRight(u8, s, suffix);
}

fn map(out: *Buffer, mapping: fn (r: i32) i32, src: []const u8) !void {
    var max_bytes = src.len;
    try out.resize(max_bytes);
    var nb_bytes: usize = 0;
    var i: usize = 0;
    while (i < src.len) {
        var wid: usize = 1;
        var r = @intCast(i32, src[i]);
        if (r >= utf8.rune_self) {
            const rune = try utf8.decodeRune(src[i..]);
            wid = rune.size;
            r = rune.value;
        }
        r = mapping(r);
        if (r >= 0) {
            const rune_length = try utf8.runeLen(r);
            if (nb_bytes + rune_length > max_bytes) {
                max_bytes = max_bytes * 2 + utf8.utf_max;
                try out.resize(max_bytes);
            }
            const w = try utf8.encodeRune(out.toSlice()[nb_bytes..max_bytes], r);
            nb_bytes += w;
        }
        i += wid;
    }
    try out.resize(nb_bytes);
}

fn toUpper(a: *Allocator, s: []const u8) ![]const u8 {
    var buf = &try Buffer.init(a, "");
    defer buf.deinit();
    try map(buf, unicode.toUpper, s);
    return buf.toOwnedSlice();
}

fn toLower(a: *Allocator, s: []const u8) ![]const u8 {
    var buf = &try Buffer.init(a, "");
    defer buf.deinit();
    try map(buf, unicode.toLower, s);
    return buf.toOwnedSlice();
}

test "toUpper" {
    var a = std.debug.global_allocator;
    const out = try toUpper(a, "mamaMia");
    defer a.free(out);
    warn("upper case: {}\n", out);

    const low = try toLower(a, "mamaMia");
    defer a.free(low);
    warn("low case: {}\n", low);
}

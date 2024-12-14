const std = @import("std");

fn works(t: i64, c: i64, r: []i64) bool {
    if (r.len == 0) return t == c;
    if (c > t) return false;
    return works(t, c+r[0], r[1..]) or works(t, c*r[0], r[1..]);
}

pub fn main() !void {
    const data = @embedFile("in1");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, data, "\n");
    var d = std.ArrayList([]i64).init(allocator);
    defer {
        for (d.items) |l| {
            allocator.free(l);
        }
        d.deinit();
    }
    while (it.next()) |line| {
        var it2 = std.mem.tokenizeAny(u8, line, " :");
        var l = std.ArrayList(i64).init(allocator);
        defer l.deinit();
        while (it2.next()) |num| {
            try l.append(try std.fmt.parseInt(i64, num, 10));
        }
        try d.append(try l.toOwnedSlice());
    }
    var res: i64 = 0;
    for (d.items) |l| {
        res += if (works(l[0], l[1], l[2..])) l[0] else 0;
    }
    std.debug.print("part 1: {}\n", .{ res });
}

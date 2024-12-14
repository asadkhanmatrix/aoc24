const std = @import("std");

fn worksPart1(t: i128, c: i128, r: []i128) bool {
    if (r.len == 0) return t == c;
    if (c > t) return false;
    return worksPart1(t, c + r[0], r[1..]) or worksPart1(t, c * r[0], r[1..]);
}

fn concat(allocator: std.mem.Allocator, a: i128, b: i128) !i128 {
    const str_a = try std.fmt.allocPrint(allocator, "{}", .{a});
    defer allocator.free(str_a);
    const str_b = try std.fmt.allocPrint(allocator, "{}", .{b});
    defer allocator.free(str_b);
    const res = try std.mem.concat(allocator, u8, &[_][]const u8{ str_a, str_b });
    defer allocator.free(res);
    return try std.fmt.parseInt(i128, res, 10);
}

fn worksPart2(allocator: std.mem.Allocator, t: i128, c: i128, r: []i128) !bool {
    if (r.len == 0) return t == c;
    if (c > t) return false;
    return (try worksPart2(allocator, t, c + r[0], r[1..])) or (try worksPart2(allocator, t, c * r[0], r[1..])) or (try worksPart2(allocator, t, try concat(allocator, c, r[0]), r[1..]));
}

pub fn main() !void {
    const data = @embedFile("in1");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, data, "\n");
    var d = std.ArrayList([]i128).init(allocator);
    defer {
        for (d.items) |l| {
            allocator.free(l);
        }
        d.deinit();
    }
    while (it.next()) |line| {
        var it2 = std.mem.tokenizeAny(u8, line, " :");
        var l = std.ArrayList(i128).init(allocator);
        defer l.deinit();
        while (it2.next()) |num| {
            try l.append(try std.fmt.parseInt(i128, num, 10));
        }
        try d.append(try l.toOwnedSlice());
    }
    var res1: i128 = 0;
    var res2: i128 = 0;
    for (d.items) |l| {
        if (worksPart1(l[0], l[1], l[2..])) {
            res1 += l[0];
            res2 += l[0];
        } else if (try worksPart2(allocator, l[0], l[1], l[2..])) {
            res2 += l[0];
        }
        std.debug.print("res 1: {} | res 2: {}\n", .{ res1, res2 });
    }
    std.debug.print("part 1: {}\n", .{res1});
    std.debug.print("part 2: {}\n", .{res2});
}

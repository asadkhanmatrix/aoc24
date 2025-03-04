const std = @import("std");

fn isSafe(l: []const i32) bool {
    // std.debug.print("inp: {any}\n", .{l});
    for (1..l.len) |i| {
        const v = @abs(l[i]-l[i-1]);
        if (v == 0 or v < 1 or v > 3 or (((l[1]-l[0])>0) != ((l[i]-l[i-1])>0))) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const data = @embedFile("in1");
    var it1 = std.mem.tokenizeAny(u8, data, "\n");
    var safeCount: u32 = 0;

    while (it1.next()) |line| {
        var it2 = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
        var l = std.ArrayList(i32).init(allocator);
        defer l.deinit();
        while (it2.next()) |num| {
            try l.append(try std.fmt.parseInt(i32, num, 10));
        }
        safeCount += if (isSafe(l.items)) 1 else 0;
    }
    std.debug.print("part 1: {}\n", .{safeCount});

    it1 = std.mem.tokenizeAny(u8, data, "\n");
    safeCount = 0;

    while (it1.next()) |line| {
        var it2 = std.mem.tokenizeAny(u8, line, &std.ascii.whitespace);
        var l = std.ArrayList(i32).init(allocator);
        defer l.deinit();
        while (it2.next()) |num| {
            try l.append(try std.fmt.parseInt(i32, num, 10));
        }
        safeCount += for (0..l.items.len) |i| {
            var l2 = std.ArrayList(i32).init(allocator);
            defer l2.deinit();
            for (0..l.items.len) |j| {
                if (i != j) {
                    try l2.append(l.items[j]);
                }
            }
            if (isSafe(l2.items)) break 1;
        } else 0;
    }
    std.debug.print("part 2: {}\n", .{safeCount});
}

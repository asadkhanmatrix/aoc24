const std = @import("std");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();
    const allocator = std.heap.c_allocator;
    const data = comptime std.mem.trim(u8, @embedFile("in1"), &std.ascii.whitespace);
    var it = std.mem.tokenizeAny(u8, data, " ");
    var l = std.ArrayList(u128).init(allocator);
    defer l.deinit();
    while (it.next()) |num| {
        try l.append(try std.fmt.parseInt(u128, num, 10));
    }
    var a = try l.toOwnedSlice();
    const loop_cnt = 25;
    for (0..loop_cnt) |_| {
        for (a) |v| {
            if (v == 0) {
                // std.debug.print("v: 0 -> 1\n", .{});
                try l.append(1);
                continue;
            }
            const num = try std.fmt.allocPrint(allocator, "{}", .{v});
            defer allocator.free(num);
            // std.debug.print("num: {s}[{}]\n", .{num, num.len});
            if (@mod(num.len, 2) == 0) {
                const v1 = try std.fmt.parseInt(u128, num[0 .. num.len / 2], 10);
                const v2 = try std.fmt.parseInt(u128, num[num.len / 2 ..], 10);
                // std.debug.print("v1: {}\nv2: {}\n", .{v1, v2});
                try l.append(v1);
                try l.append(v2);
            } else {
                // std.debug.print("v: {} -> {}\n", .{v, v * 2024});
                try l.append(v * 2024);
            }
        }
        allocator.free(a);
        a = try l.toOwnedSlice();
        // std.debug.print("{any}\n", .{a});
    }
    std.debug.print("part 1: {}\n", .{a.len});
}

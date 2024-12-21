const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const data = comptime std.mem.trim(u8, @embedFile("in1"), "\n");
    var layout = std.ArrayList(i32).init(allocator);
    defer layout.deinit();
    for (data, 0..) |c, i| {
        const val: i32 = if (@mod(i, 2) == 1) -1 else @intCast(@divFloor(i, 2));
        const cnt = c - '0';
        for (0..cnt) |_| {
            try layout.append(val);
        }
    }
    var lit: usize = std.mem.indexOfScalar(i32, layout.items, -1) orelse layout.items.len;
    var rit: usize = std.mem.lastIndexOfNone(i32, layout.items, &[_]i32{-1}) orelse 0;
    while (lit < rit) {
        layout.items[lit] = layout.items[rit];
        layout.items[rit] = -1;
        lit = std.mem.indexOfScalar(i32, layout.items, -1) orelse layout.items.len;
        rit = std.mem.lastIndexOfNone(i32, layout.items, &[_]i32{-1}) orelse 0;
    }
    var res: u64 = 0;
    for (layout.items[1..], 1..) |v, i| {
        if (v == -1) break;
        res += @as(u64, @intCast(v)) * i;
    }
    std.debug.print("part 1: {}\n", .{res});
}

const std = @import("std");

pub fn main() !void {
    const start = std.time.milliTimestamp();
    defer {
        const end = std.time.milliTimestamp();
        std.debug.print("{}ms\n", .{end - start});
    }
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
    var layout2 = try std.ArrayList(i32).initCapacity(allocator, layout.items.len);
    layout2.appendSliceAssumeCapacity(layout.items);
    defer layout2.deinit();
    var files = std.ArrayList([]i32).init(allocator);
    defer files.deinit();
    var spaces = std.ArrayList([]i32).init(allocator);
    defer spaces.deinit();
    var st: usize = 0;
    for (data, 0..) |c, i| {
        const cnt = c - '0';
        if (cnt > 0) {
            if (@mod(i, 2) == 0) {
                try files.append(layout2.items[st..][0..cnt]);
            } else {
                try spaces.append(layout2.items[st..][0..cnt]);
            }
            st += cnt;
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
    for (layout.items, 0..) |v, i| {
        if (v == -1) break;
        res += @as(u64, @intCast(v)) * i;
    }
    std.debug.print("part 1: {}\n", .{res});
    var fi: usize = files.items.len;
    while (fi > 0) {
        fi -= 1;
        for (spaces.items) |*s| {
            // ptr check is to ensure that files are only moved forward
            // since heap memory grows from low to high we can compare pointers to ensure this condition
            // ... it's beautiful, i know. /s
            if (files.items[fi].len <= s.len and @intFromPtr(s.ptr) < @intFromPtr(files.items[fi].ptr)) {
                std.mem.copyForwards(i32, s.*, files.items[fi]);
                s.* = s.*[files.items[fi].len..];
                @memset(files.items[fi], -1);
                break;
            }
        }
    }
    res = 0;
    for (layout2.items, 0..) |v, i| {
        if (v == -1) continue;
        res += @as(u64, @intCast(v)) * i;
        // std.debug.print("v: {} i: {} res: {}\n", .{v, i, res});
    }
    // std.debug.print("layout2[{}]: {any}\n", .{layout2.items.len, layout2.items});
    std.debug.print("part 2: {}\n", .{res});
}

const std = @import("std");

fn getIntegerList(allocator: std.mem.Allocator, buffer: []const u8) !?[]i32 {
    var list = std.ArrayList(i32).init(allocator);
    errdefer list.deinit();
    var ok: bool = false;
    var neg: bool = false;
    var num: i32 = 0;
    for (buffer) |c| {
        switch (c) {
            '-' => {
                neg = true;
            },
            '0'...'9' => {
                ok = true;
                num = num * 10 + @as(i32, c - '0');
            },
            else => {
                if (ok) {
                    if (neg) num = -num;
                    try list.append(num);
                }
                ok = false;
                neg = false;
                num = 0;
            },
        }
    }
    if (ok) {
        if (neg) num = -num;
        try list.append(num);
    }
    return if (list.items.len > 0) try list.toOwnedSlice() else null;
}

fn Pair(comptime T: type) type {
    return struct {
        f: T,
        s: T,
    };
}

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}).init;
    defer _ = da.deinit();
    const allocator = da.allocator();
    const input_data = try std.fs.cwd().readFileAlloc(allocator, "./data/14_l_in", 1 << 20);
    defer allocator.free(input_data);
    var line_it = std.mem.tokenizeScalar(u8, input_data, '\n');
    var robots = std.ArrayList(Pair(Pair(i32))).init(allocator);
    defer robots.deinit();
    while (line_it.next()) |line| {
        if (try getIntegerList(allocator, line)) |nums| {
            std.debug.assert(nums.len == 4);
            try robots.append(.{ .f = .{ .f = nums[0], .s = nums[1] }, .s = .{ .f = nums[2], .s = nums[3] } });
            allocator.free(nums);
        }
    }
    const Rows = 103; // 7
    const Cols = 101; // 11
    const Iter = 100;
    for (robots.items) |*robot| {
        const p = &robot.f;
        const v = robot.s;
        for (0..Iter) |_| {
            p.f = @mod((Cols + p.f + v.f), Cols);
            p.s = @mod((Rows + p.s + v.s), Rows);
        }
    }
    var quad: @Vector(4, u32) = @splat(0);
    for (robots.items) |robot| {
        const p = robot.f;
        var q: usize = 0;
        if (p.f < Cols / 2) {
            q = if (p.s < Rows / 2) 0 else if (p.s > Rows / 2) 2 else 4;
        } else if (p.f > Cols / 2) {
            q = if (p.s < Rows / 2) 1 else if (p.s > Rows / 2) 3 else 4;
        } else {
            q = 4;
        }
        if (q < 4) quad[q] += 1;
    }
    std.debug.print("{any}\n", .{quad});
    std.debug.print("part 1: {}\n", .{@reduce(.Mul, quad)});
}

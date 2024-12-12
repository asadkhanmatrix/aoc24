const std = @import("std");

pub fn main() !void {
    const data = @embedFile("in1");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var d = std.ArrayList([]u8).init(allocator);
    defer {
        for (d.items) |r| {
            allocator.free(r);
        }
        d.deinit();
    }
    var it = std.mem.tokenizeAny(u8, data, "\n");
    while (it.next()) |line| {
        try d.append(try allocator.dupe(u8, line));
    }
    var cur = [2]i32{ -1, -1 };
    var dir = [2]i32{ -1, -1 };
    for (d.items, 0..) |r, _i| {
        for (r, 0..) |c, _j| {
            const i: i32 = @intCast(_i);
            const j: i32 = @intCast(_j);
            switch (c) {
                '^' => {
                    cur = [2]i32{ i, j };
                    dir = [2]i32{ -1, 0 };
                },
                '>' => {
                    cur = [2]i32{ i, j };
                    dir = [2]i32{ 0, 1 };
                },
                'v' => {
                    cur = [2]i32{ i, j };
                    dir = [2]i32{ 1, 0 };
                },
                '<' => {
                    cur = [2]i32{ i, j };
                    dir = [2]i32{ 0, -1 };
                },
                else => {},
            }
        }
    }
    while (cur[0] >= 0 and cur[0] < d.items.len and cur[1] >= 0 and cur[1] < d.items[0].len) {
        switch (d.items[@intCast(cur[0])][@intCast(cur[1])]) {
            '#' => {
                if (dir[0] == -1 and dir[1] == 0) { // up
                    cur[0] += 1;
                    cur[1] += 1;
                    dir = [2]i32{ 0, 1 }; // right
                } else if (dir[0] == 0 and dir[1] == 1) { // right
                    cur[0] += 1;
                    cur[1] -= 1;
                    dir = [2]i32{ 1, 0 }; // down
                } else if (dir[0] == 1 and dir[1] == 0) { // down
                    cur[0] -= 1;
                    cur[1] -= 1;
                    dir = [2]i32{ 0, -1 }; // left
                } else { // left
                    cur[0] -= 1;
                    cur[1] += 1;
                    dir = [2]i32{ -1, 0 }; // up
                }
            },
            else => {
                d.items[@intCast(cur[0])][@intCast(cur[1])] = 'x';
                cur[0] += dir[0];
                cur[1] += dir[1];
            },
        }
    }
    var res: u32 = 0;
    for (d.items) |r| {
        for (r) |v| {
            res += if (v == 'x') 1 else 0;
            std.debug.print("{u}", .{v});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("part 1: {}\n", .{res});
}

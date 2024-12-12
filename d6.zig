const std = @import("std");

const State = struct {
    x: i32,
    y: i32,
    d: Direction,
};

const Direction = enum(u8) {
    up,
    right,
    down,
    left,
};

fn getRight(d: Direction) Direction {
    return switch (d) {
        .up => .right,
        .right => .down,
        .down => .left,
        .left => .up,
    };
}

fn changeInX(d: Direction) i32 {
    return switch (d) {
        .up => 0,
        .right => 1,
        .down => 0,
        .left => -1,
    };
}

fn changeInY(d: Direction) i32 {
    return switch (d) {
        .up => -1,
        .right => 0,
        .down => 1,
        .left => 0,
    };
}

pub fn main() !void {
    const data = @embedFile("in2");
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
    var dir = Direction.up;
    for (d.items, 0..) |r, _i| {
        for (r, 0..) |c, _j| {
            const i: i32 = @intCast(_i);
            const j: i32 = @intCast(_j);
            switch (c) {
                '^' => {
                    cur = [2]i32{ i, j };
                    dir = .up;
                },
                '>' => {
                    cur = [2]i32{ i, j };
                    dir = .right;
                },
                'v' => {
                    cur = [2]i32{ i, j };
                    dir = .down;
                },
                '<' => {
                    cur = [2]i32{ i, j };
                    dir = .left;
                },
                else => {},
            }
        }
    }
    const start_pos = cur;
    const start_dir = dir;
    while (cur[0] >= 0 and cur[0] < d.items.len and cur[1] >= 0 and cur[1] < d.items[0].len) {
        switch (d.items[@intCast(cur[0])][@intCast(cur[1])]) {
            '#' => {
                switch (dir) {
                    .up => {
                        cur[0] += 1;
                        cur[1] += 1;
                        dir = .right;
                    },
                    .right => {
                        cur[0] += 1;
                        cur[1] -= 1;
                        dir = .down;
                    },
                    .down => {
                        cur[0] -= 1;
                        cur[1] -= 1;
                        dir = .left;
                    },
                    .left => {
                        cur[0] -= 1;
                        cur[1] += 1;
                        dir = .up;
                    },
                }
            },
            else => {
                d.items[@intCast(cur[0])][@intCast(cur[1])] = 'x';
                cur[0] += changeInY(dir);
                cur[1] += changeInX(dir);
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

    cur = start_pos;
    dir = start_dir;
    var seen = std.ArrayList(State).init(allocator);
    defer seen.deinit();
    while (cur[0] >= 0 and cur[0] < d.items.len and cur[1] >= 0 and cur[1] < d.items[0].len) {
        switch (d.items[@intCast(cur[0])][@intCast(cur[1])]) {
            '#' => {
                switch (dir) {
                    .up => {
                        cur[0] += 1;
                        cur[1] += 1;
                        dir = .right;
                    },
                    .right => {
                        cur[0] += 1;
                        cur[1] -= 1;
                        dir = .down;
                    },
                    .down => {
                        cur[0] -= 1;
                        cur[1] -= 1;
                        dir = .left;
                    },
                    .left => {
                        cur[0] -= 1;
                        cur[1] += 1;
                        dir = .up;
                    },
                }
            },
            else => {
                try seen.append(.{ .x = cur[0], .y = cur[1], .d = dir });
                var pos = cur;
                cur[0] += changeInY(dir);
                cur[1] += changeInX(dir);

                const right_dir = getRight(dir);
                pos[0] += changeInY(right_dir);
                pos[1] += changeInX(right_dir);
                var in_seen: bool = false;
                for (seen.items) |item| {
                    if (item.x == pos[0] and item.y == pos[1] and item.d == right_dir) {
                        in_seen = true;
                        break;
                    }
                }
                if (in_seen and cur[0] >= 0 and cur[0] < d.items.len and cur[1] >= 0 and cur[1] < d.items[0].len) {
                    std.debug.print("{{{}, {}}}\n", .{pos[0], pos[1]});
                    d.items[@intCast(cur[0])][@intCast(cur[1])] = 'o';
                }
            },
        }
    }
    res = 0;
    for (d.items) |r| {
        for (r) |v| {
            res += if (v == 'o') 1 else 0;
            std.debug.print("{u}", .{v});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("part 2: {}\n", .{res});
}

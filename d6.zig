const std = @import("std");

const State = struct {
    x: i32,
    y: i32,
    d: Direction,
};

const Direction = enum {
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

fn hasCycle(allocator: std.mem.Allocator, g: []const []u8, start_cur: [2]i32, start_dir: Direction) !bool {
    var seen = std.ArrayList(State).init(allocator);
    defer seen.deinit();
    var cur = start_cur;
    var dir = start_dir;
    while (cur[0] >= 0 and cur[0] < g.len and cur[1] >= 0 and cur[1] < g[0].len) {
        switch (g[@intCast(cur[0])][@intCast(cur[1])]) {
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
                var in_seen: bool = false;
                for (seen.items) |item| {
                    if (item.x == cur[0] and item.y == cur[1] and item.d == dir) {
                        in_seen = true;
                        break;
                    }
                }
                if (in_seen) {
                    return true;
                }
                try seen.append(.{ .x = cur[0], .y = cur[1], .d = dir });

                cur[0] += changeInY(dir);
                cur[1] += changeInX(dir);
            },
        }
    }
    return false;
}

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
    var dir = Direction.up;
    outer: for (d.items, 0..) |r, _i| {
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
            switch (c) {
                '^', '>', 'v', '<' => break :outer,
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

    res = 0;
    for (0..d.items.len) |i| {
        for (0..d.items[i].len) |j| {
            const v = d.items[i][j];
            if (v != '#') {
                d.items[i][j] = '#';
                res += if (try hasCycle(allocator, d.items, start_pos, start_dir)) 1 else 0;
                d.items[i][j] = v;
                std.debug.print("{{{}, {}}}: {}\n", .{i, j, res});
            }
        }
    }
    std.debug.print("part 2: {}\n", .{res});
}

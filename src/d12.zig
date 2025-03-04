const std = @import("std");

const dir = [_][2]i8{
    [_]i8{ 1, 0 },
    [_]i8{ 0, 1 },
    [_]i8{ -1, 0 },
    [_]i8{ 0, -1 },
};

const all_dir = [_][2]i8{
    [_]i8{ 0, -1 },
    [_]i8{ -1, -1 },
    [_]i8{ -1, 0 },
    [_]i8{ -1, 1 },
    [_]i8{ 0, 1 },
    [_]i8{ 1, 1 },
    [_]i8{ 1, 0 },
    [_]i8{ 1, -1 },
};

fn dfs2(g: std.ArrayList([]const u8), r: usize, c: usize, vis: [][]bool, area: *u32, side: *u32) void {
    vis[r][c] = true;
    area.* += 1;
    var d = [_]u8{0} ** all_dir.len;
    for (dir, 0..) |arr, i| {
        const nr: i32 = @as(i32, @intCast(r)) + arr[0];
        const nc: i32 = @as(i32, @intCast(c)) + arr[1];
        if (nr < 0 or nr >= g.items.len or nc < 0 or nc >= g.items[0].len or g.items[@intCast(nr)][@intCast(nc)] != g.items[r][c]) {
            d[i] = 1;
            continue;
        }
        if (!vis[@intCast(nr)][@intCast(nc)]) {
            dfs2(g, @intCast(nr), @intCast(nc), vis, area, side);
        }
    }
    for (all_dir, 0..) |arr, i| {
        const nr: i32 = @as(i32, @intCast(r)) + arr[0];
        const nc: i32 = @as(i32, @intCast(c)) + arr[1];
        d[i] = if (nr < 0 or nr >= g.items.len or nc < 0 or nc >= g.items[0].len or g.items[@intCast(nr)][@intCast(nc)] != g.items[r][c]) 0 else 1;
    }
    var i: u8 = 0;
    while (i < d.len) : (i += 2) {
        if ((d[i] == 0 and d[(i + 2) % d.len] == 0) or (d[i] == 1 and d[i + 1] == 0 and d[(i + 2) % d.len] == 1)) {
            side.* += 1;
        }
    }
}

fn dfs(g: std.ArrayList([]const u8), r: usize, c: usize, vis: [][]bool, area: *u32, peri: *u32) void {
    vis[r][c] = true;
    area.* += 1;
    for (dir) |arr| {
        const nr: i32 = @as(i32, @intCast(r)) + arr[0];
        const nc: i32 = @as(i32, @intCast(c)) + arr[1];
        if (nr < 0 or nr >= g.items.len or nc < 0 or nc >= g.items[0].len or g.items[@intCast(nr)][@intCast(nc)] != g.items[r][c]) {
            peri.* += 1;
            continue;
        }
        if (!vis[@intCast(nr)][@intCast(nc)]) {
            dfs(g, @intCast(nr), @intCast(nc), vis, area, peri);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const data = @embedFile("in1");
    var it = std.mem.tokenizeAny(u8, data, "\n");
    var g = std.ArrayList([]const u8).init(allocator);
    defer {
        for (g.items) |s| {
            allocator.free(s);
        }
        g.deinit();
    }
    while (it.next()) |line| {
        try g.append(try allocator.dupe(u8, line));
    }
    const vis = try allocator.alloc([]bool, g.items.len);
    defer {
        for (vis) |s| {
            allocator.free(s);
        }
        allocator.free(vis);
    }
    for (vis) |*s| {
        s.* = try allocator.alloc(bool, g.items[0].len);
        @memset(s.*, false);
    }
    var res: u32 = 0;
    for (g.items, 0..) |_, r| {
        for (g.items[r], 0..) |_, c| {
            if (!vis[r][c]) {
                var area: u32 = 0;
                var peri: u32 = 0;
                dfs(g, r, c, vis, &area, &peri);
                std.debug.print("{u}: {} * {} = {}\n", .{ g.items[r][c], area, peri, area * peri });
                res += area * peri;
            }
        }
    }
    std.debug.print("part 1: {}\n", .{res});
    res = 0;
    for (vis) |s| {
        @memset(s, false);
    }
    for (g.items, 0..) |_, r| {
        for (g.items[r], 0..) |_, c| {
            if (!vis[r][c]) {
                var area: u32 = 0;
                var side: u32 = 0;
                dfs2(g, r, c, vis, &area, &side);
                std.debug.print("{u}: {} * {} = {}\n", .{ g.items[r][c], area, side, area * side });
                res += area * side;
            }
        }
    }
    std.debug.print("part 2: {}\n", .{res});
}

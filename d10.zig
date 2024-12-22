const std = @import("std");

fn dfs(g: std.ArrayList([]u8), r: usize, c: usize, vis: [][]bool, score: *u32) void {
    vis[r][c] = true;
    if (g.items[r][c] == '9') {
        score.* += 1;
        return;
    }
    if (r + 1 < g.items.len and !vis[r + 1][c] and g.items[r + 1][c] == g.items[r][c] + 1) dfs(g, r + 1, c, vis, score);
    if (r > 0 and !vis[r - 1][c] and g.items[r - 1][c] == g.items[r][c] + 1) dfs(g, r - 1, c, vis, score);
    if (c + 1 < g.items[0].len and !vis[r][c + 1] and g.items[r][c + 1] == g.items[r][c] + 1) dfs(g, r, c + 1, vis, score);
    if (c > 0 and !vis[r][c - 1] and g.items[r][c - 1] == g.items[r][c] + 1) dfs(g, r, c - 1, vis, score);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const data = @embedFile("in1");
    var it = std.mem.tokenizeAny(u8, data, "\n");
    var g = std.ArrayList([]u8).init(allocator);
    defer {
        for (g.items) |s| {
            allocator.free(s);
        }
        g.deinit();
    }
    while (it.next()) |line| {
        try g.append(try allocator.dupe(u8, line));
    }
    var res: u32 = 0;
    const vis = try allocator.alloc([]bool, g.items.len);
    defer {
        for (vis) |s| {
            allocator.free(s);
        }
        allocator.free(vis);
    }
    for (vis) |*r| {
        r.* = try allocator.alloc(bool, g.items[0].len);
    }
    for (g.items, 0..) |_, r| {
        for (g.items[r], 0..) |v, c| {
            if (v == '0') {
                var score: u32 = 0;
                for (vis) |s| {
                    @memset(s, false);
                }
                _ = dfs(g, r, c, vis, &score);
                // std.debug.print("{{{}, {}}}: {}\n", .{r, c, score});
                res += score;
            }
        }
    }
    std.debug.print("part 1: {}\n", .{res});
}

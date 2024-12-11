const std = @import("std");

fn dfs(g: []const []const u32, u: u32, f: u32, vis: []bool, allowed: []const u32) bool {
    if (u == f) return true;
    vis[u] = true;
    for (g[u]) |v| {
        if (std.mem.indexOfScalar(u32, allowed, v) != null and !vis[v] and dfs(g, v, f, vis, allowed)) {
            return true;
        }
    }
    return false;
}

fn pathExists(allocator: std.mem.Allocator, g: []const []const u32, u: u32, v: u32, allowed: []const u32) !bool {
    const vis = try allocator.alloc(bool, g.len);
    defer allocator.free(vis);
    @memset(vis, false);
    return dfs(g, u, v, vis, allowed);
}

pub fn main() !void {
    const data = @embedFile("in1");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    // const allocator = std.heap.c_allocator;
    var it = std.mem.splitAny(u8, data, "\n");
    var edges = std.ArrayList([2]u32).init(allocator);
    defer edges.deinit();
    const adj_list = try allocator.alloc(std.ArrayList(u32), 100);
    defer {
        for (0..adj_list.len) |i| {
            adj_list[i].deinit();
        }
        allocator.free(adj_list);
    }
    for (0..adj_list.len) |i| {
        adj_list[i] = std.ArrayList(u32).init(allocator);
    }
    while (it.next()) |line| {
        if (line.len == 0) break;
        var it2 = std.mem.tokenizeAny(u8, line, "|");
        const u: u32 = try std.fmt.parseInt(u32, it2.next().?, 10);
        const v: u32 = try std.fmt.parseInt(u32, it2.next().?, 10);
        try adj_list[u].append(v);
        try edges.append([2]u32{ u, v });
    }
    const g = try allocator.alloc([]u32, adj_list.len);
    defer {
        for (g) |l| {
            allocator.free(l);
        }
        allocator.free(g);
    }
    for (0..adj_list.len) |i| {
        g[i] = try adj_list[i].toOwnedSlice();
    }
    // for (g, 0..) |l, i| {
    //     if (l.len == 0) continue;
    //     std.debug.print("{}: ", .{i});
    //     for (l) |v| {
    //         std.debug.print("{} ", .{v});
    //     }
    //     std.debug.print("\n", .{});
    // }
    var insert_list = std.ArrayList([]u32).init(allocator);
    defer {
        for (insert_list.items) |l| {
            allocator.free(l);
        }
        insert_list.deinit();
    }
    while (it.next()) |line| {
        if (line.len == 0) break;
        var l = std.ArrayList(u32).init(allocator);
        defer l.deinit();
        var it2 = std.mem.tokenizeAny(u8, line, ",");
        while (it2.next()) |num| {
            try l.append(try std.fmt.parseInt(u32, num, 10));
        }
        try insert_list.append(try l.toOwnedSlice());
    }
    // std.debug.print("edges:\n", .{});
    // for (edges.items) |e| {
    //     std.debug.print("{} -> {}\n", .{ e[0], e[1] });
    // }
    // std.debug.print("insert list:\n", .{});
    // for (insert_list.items) |l| {
    //     for (l) |v| {
    //         std.debug.print("{} ", .{v});
    //     }
    //     std.debug.print("\n", .{});
    // }
    var res: u32 = 0;
    for (insert_list.items) |l| {
        var ok: bool = true;
        for (0..l.len - 1) |i| {
            if (try pathExists(allocator, g, l[i + 1], l[i], l)) {
                std.debug.print("X {any} {{{}, {}}} {{{}, {}}}\n", .{ l, i, i + 1, l[i], l[i + 1] });
                ok = false;
                break;
            }
        }
        if (ok) {
            res += l[@divFloor(l.len, 2)];
            std.debug.print("O {any}\n", .{l});
        }
    }
    std.debug.print("part 1: {}\n", .{res});

    res = 0;
    for (insert_list.items) |l| {
        var ok: bool = false;
        var fine: bool = true;
        while (!ok) {
            ok = true;
            for (0..l.len - 1) |i| {
                if (try pathExists(allocator, g, l[i + 1], l[i], l)) {
                    std.mem.swap(u32, &l[i], &l[i+1]);
                    // std.debug.print("X {any} {{{}, {}}} {{{}, {}}}\n", .{ l, i, i + 1, l[i], l[i + 1] });
                    ok = false;
                }
            }
            if (!ok) fine = false;
        }
        if (!fine) {
            res += l[@divFloor(l.len, 2)];
            std.debug.print("U {any}\n", .{l});
        }
    }
    std.debug.print("part 2: {}\n", .{res});
}

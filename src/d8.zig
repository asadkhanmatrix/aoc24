const std = @import("std");

pub fn main() !void {
    const data = @embedFile("in1");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var g = std.ArrayList([]u8).init(allocator);
    defer {
        for (g.items) |e| {
            allocator.free(e);
        }
        g.deinit();
    }
    var it = std.mem.tokenizeAny(u8, data, "\n");
    while (it.next()) |line| {
        try g.append(try allocator.dupe(u8, line));
    }
    for (g.items) |e| {
        for (e) |v| {
            std.debug.print("{u} ", .{v});
        }
        std.debug.print("\n", .{});
    }
    var mp = std.AutoHashMap(u8, std.ArrayList([2]i32)).init(allocator);
    defer {
        var mp_it = mp.valueIterator();
        while (mp_it.next()) |v| {
            v.deinit();
        }
        mp.deinit();
    }
    for (g.items, 0..) |r, i| {
        for (r, 0..) |v, j| {
            if (v == '.') continue;
            const res = try mp.getOrPut(v);
            if (!res.found_existing) {
                res.value_ptr.* = std.ArrayList([2]i32).init(allocator);
            }
            try res.value_ptr.append([2]i32{ @intCast(i), @intCast(j) });
        }
    }
    var mp_it = mp.iterator();
    while (mp_it.next()) |v| {
        for (0..v.value_ptr.items.len - 1) |i| {
            for (i + 1..v.value_ptr.items.len) |j| {
                const d = [2]i32{ v.value_ptr.items[j][0] - v.value_ptr.items[i][0], v.value_ptr.items[j][1] - v.value_ptr.items[i][1] };
                const p1 = [2]i32{ v.value_ptr.items[j][0] + d[0], v.value_ptr.items[j][1] + d[1] };
                const p2 = [2]i32{ v.value_ptr.items[i][0] - d[0], v.value_ptr.items[i][1] - d[1] };
                if (p1[0] >= 0 and p1[0] < g.items.len and p1[1] >= 0 and p1[1] < g.items[0].len) {
                    g.items[@intCast(p1[0])][@intCast(p1[1])] = '#';
                }
                if (p2[0] >= 0 and p2[0] < g.items.len and p2[1] >= 0 and p2[1] < g.items[0].len) {
                    g.items[@intCast(p2[0])][@intCast(p2[1])] = '#';
                }
            }
        }
    }
    var res: u32 = 0;
    for (g.items) |r| {
        for (r) |v| {
            res += if (v == '#') 1 else 0;
        }
    }
    std.debug.print("part 1: {}\n", .{res});
    for (g.items) |e| {
        for (e) |v| {
            std.debug.print("{u} ", .{v});
        }
        std.debug.print("\n", .{});
    }
    mp_it = mp.iterator();
    while (mp_it.next()) |v| {
        for (0..v.value_ptr.items.len - 1) |i| {
            for (i + 1..v.value_ptr.items.len) |j| {
                var d = [2]i32{ v.value_ptr.items[j][0] - v.value_ptr.items[i][0], v.value_ptr.items[j][1] - v.value_ptr.items[i][1] };
                const gcd = std.math.gcd(@abs(d[0]), @abs(d[1]));
                d[0] = @divExact(d[0], @as(i32, @intCast(gcd)));
                d[1] = @divExact(d[1], @as(i32, @intCast(gcd)));
                var p1 = [2]i32{ v.value_ptr.items[j][0] + d[0], v.value_ptr.items[j][1] + d[1] };
                var p2 = [2]i32{ v.value_ptr.items[i][0] - d[0], v.value_ptr.items[i][1] - d[1] };
                while (p1[0] >= 0 and p1[0] < g.items.len and p1[1] >= 0 and p1[1] < g.items[0].len) : (p1 = [2]i32{ p1[0] + d[0], p1[1] + d[1] }) {
                    g.items[@intCast(p1[0])][@intCast(p1[1])] = '#';
                }
                while (p2[0] >= 0 and p2[0] < g.items.len and p2[1] >= 0 and p2[1] < g.items[0].len) : (p2 = [2]i32{ p2[0] - d[0], p2[1] - d[1] }) {
                    g.items[@intCast(p2[0])][@intCast(p2[1])] = '#';
                }
            }
        }
    }
    res = 0;
    for (g.items) |r| {
        for (r) |v| {
            res += if (v != '.') 1 else 0;
        }
    }
    std.debug.print("part 2: {}\n", .{res});
    for (g.items) |e| {
        for (e) |v| {
            std.debug.print("{u} ", .{v});
        }
        std.debug.print("\n", .{});
    }
}

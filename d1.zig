const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    var par: u8 = 0;
    var it = std.mem.tokenizeAny(u8, @embedFile("in1"), &std.ascii.whitespace);
    var inp = [2]std.ArrayList(i32){std.ArrayList(i32).init(allocator), std.ArrayList(i32).init(allocator)};
    defer {
        for (0..inp.len) |i| {
            inp[i].deinit();
        }
    }
    while (it.next()) |num| : (par ^= 1) {
        try inp[par].append(try std.fmt.parseInt(i32, num, 10));
    }

    // for (0..inp.len) |i| {
    //     for (inp[i].items) |v| {
    //         std.debug.print("{} ", .{v});
    //     }
    //     std.debug.print("\n", .{});
    // }

    for (0..inp.len) |i| {
        std.mem.sort(i32, inp[i].items, {}, std.sort.asc(i32));
    }

    var dist1: u32 = 0;
    for (0..inp[0].items.len) |i| {
        dist1 += @abs(inp[1].items[i] - inp[0].items[i]);
    }
    std.debug.print("part 1: {}\n", .{dist1});

    var freq = std.AutoHashMap(i32, u32).init(allocator);
    defer freq.deinit();

    for (inp[1].items) |item| {
        try freq.put(item, (freq.get(item) orelse 0) + 1);
    }

    var dist2: u32 = 0;
    for (inp[0].items) |item| {
        dist2 += @as(u32, @intCast(item)) * (freq.get(item) orelse 0);
    }
    std.debug.print("part 2: {}\n", .{dist2});
}

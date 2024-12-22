const std = @import("std");

fn digitCount(n: u128) u128 {
    var num: u128 = n;
    var cnt: u128 = 0;
    while (num > 0) : (cnt += 1) {
        num /= 10;
    }
    return cnt;
}

fn forN(allocator: std.mem.Allocator, n: u128, s: u128, mp: *std.StringHashMap(u128)) u128 {
    if (s == 0) unreachable;
    if (s == 1) {
        if (n == 0 or @mod(digitCount(n), 2) == 1) {
            return 1;
        } else {
            return 2;
        }
    }
    const key = std.fmt.allocPrint(allocator, "{}:{}", .{n,s}) catch unreachable;
    if (mp.contains(key)) {
        return mp.get(key).?;
    }
    if (n == 0) {
        const res = forN(allocator, 1, s - 1, mp);
        mp.put(key, res) catch unreachable;
        return res;
    }
    if (@mod(digitCount(n), 2) == 1) {
        const res = forN(allocator, n * 2024, s - 1, mp);
        mp.put(key, res) catch unreachable;
        return res;
    }
    const num = std.fmt.allocPrint(allocator, "{}", .{n}) catch unreachable;
    defer allocator.free(num);
    const n1 = std.fmt.parseInt(u128, num[0 .. num.len / 2], 10) catch unreachable;
    const n2 = std.fmt.parseInt(u128, num[num.len / 2 ..], 10) catch unreachable;
    const res = forN(allocator, n1, s - 1, mp) + forN(allocator, n2, s - 1, mp);
    mp.put(key, res) catch unreachable;
    return res;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const data = comptime std.mem.trim(u8, @embedFile("in1"), &std.ascii.whitespace);
    const steps1 = 25;
    const steps2 = 75;
    var it = std.mem.tokenizeAny(u8, data, " ");
    var l = std.ArrayList(u128).init(allocator);
    defer l.deinit();
    while (it.next()) |num| {
        try l.append(try std.fmt.parseInt(u128, num, 10));
    }
    var mp = std.StringHashMap(u128).init(allocator);
    defer mp.deinit();
    var res: u128 = 0;
    for (l.items) |v| {
        res += forN(allocator, v, steps1, &mp);
    }
    std.debug.print("part 1: {}\n", .{res});
    res = 0;
    for (l.items) |v| {
        res += forN(allocator, v, steps2, &mp);
    }
    std.debug.print("part 2: {}\n", .{res});
}

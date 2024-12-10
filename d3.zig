const std = @import("std");

const DType = enum {
    m,
    u,
    l,
    num,
    co,
    ob,
    cb,
    noc,
    nob,
    un,
};

fn getDType(c: u8) DType {
    return switch (c) {
        'm' => .m,
        'u' => .u,
        'l' => .l,
        '0'...'9' => .num,
        '(' => .ob,
        ')' => .cb,
        ',' => .co,
        else => .un,
    };
}

pub fn main() !void {
    const data = @embedFile("in3");
    var expected: DType = .m;
    var num1: i32 = 0;
    var num2: i32 = 0;
    var res: i32 = 0;
    var cur: *i32 = &num1;
    var match_count: u32 = 0;
    var nab: bool = true;
    for (data) |c| {
        const dt = getDType(c);
        // std.debug.print("{u} {any} {any}\n", .{ c, dt, expected });
        if (expected != dt) {
            if (!((expected == .noc and (dt == .co or dt == .num)) or (expected == .nob and (dt == .cb or dt == .num)))) {
                expected = .m;
                num1 = 0;
                num2 = 0;
                cur = &num1;
                continue;
            }
        }
        switch (dt) {
            .m => expected = .u,
            .u => expected = .l,
            .l => expected = .ob,
            .ob => {
                nab = true;
                expected = .num;
            },
            .num => {
                cur.* = cur.* * 10 + (c - '0');
                expected = if (nab) .noc else .nob;
            },
            .cb => {
                // std.debug.print("num1: {}\nnum2: {}\n", .{ num1, num2 });
                match_count += 1;
                res += num1 * num2;
                expected = .m;
                num1 = 0;
                num2 = 0;
                cur = &num1;
            },
            .co => {
                expected = .num;
                nab = false;
                cur = &num2;
            },
            else => {
                std.debug.print("type: {any} {u}\n", .{ dt, c });
                unreachable;
            },
        }
    }
    std.debug.print("matches found: {}\n", .{match_count});
    std.debug.print("part 1: {}\n", .{res});
}

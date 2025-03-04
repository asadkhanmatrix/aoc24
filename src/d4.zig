const std = @import("std");

const fileContent = @embedFile("in1");

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    var inp_buf = try std.ArrayList(u8).initCapacity(allocator, fileContent.len);
    defer inp_buf.deinit();

    var it = std.mem.tokenizeAny(u8, fileContent, "\n");
    var rows: i32 = 0;
    var cols: i32 = 0;
    while (it.next()) |line| {
        inp_buf.appendSliceAssumeCapacity(line);
        rows += 1;
        cols = @intCast(line.len);
    }
    const data = inp_buf.items;

    std.debug.print("rows: {}\ncols: {}\n", .{ rows, cols });
    std.debug.assert(rows * cols == data.len);

    const find = "XMAS";

    var res: u32 = 0;
    for (0..@intCast(rows)) |r| {
        for (0..@intCast(cols)) |c| {
            if (data[r * @as(usize, @intCast(cols)) + c] != 'X') continue;
            const i: i32 = @intCast(r);
            const j: i32 = @intCast(c);
            const l = [8][4][2]i32{
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i, j + 1 }, [2]i32{ i, j + 2 }, [2]i32{ i, j + 3 } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i, j - 1 }, [2]i32{ i, j - 2 }, [2]i32{ i, j - 3 } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i + 1, j }, [2]i32{ i + 2, j }, [2]i32{ i + 3, j } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i - 1, j }, [2]i32{ i - 2, j }, [2]i32{ i - 3, j } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i + 1, j + 1 }, [2]i32{ i + 2, j + 2 }, [2]i32{ i + 3, j + 3 } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i + 1, j - 1 }, [2]i32{ i + 2, j - 2 }, [2]i32{ i + 3, j - 3 } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i - 1, j - 1 }, [2]i32{ i - 2, j - 2 }, [2]i32{ i - 3, j - 3 } },
                [4][2]i32{ [2]i32{ i, j }, [2]i32{ i - 1, j + 1 }, [2]i32{ i - 2, j + 2 }, [2]i32{ i - 3, j + 3 } },
            };
            for (l) |t| {
                var ok: bool = true;
                for (t, 0..) |v, p| {
                    if (v[0] < 0 or v[0] >= rows or v[1] < 0 or v[1] >= cols or data[@as(usize, @intCast(v[0] * cols + v[1]))] != find[p]) {
                        ok = false;
                        break;
                    }
                }
                if (ok) {
                    for (t) |v| {
                        std.debug.print("{{{}, {}}} ", .{ v[0], v[1] });
                    }
                    std.debug.print("\n", .{});
                    res += 1;
                }
            }
        }
    }
    std.debug.print("part 1: {}\n", .{res});

    res = 0;
    for (0..@intCast(rows)) |r| {
        for (0..@intCast(cols)) |c| {
            if (data[r * @as(usize, @intCast(cols)) + c] != 'A') continue;
            const i: i32 = @intCast(r);
            const j: i32 = @intCast(c);
            const l = [2][2][2]i32{
                [2][2]i32{ [2]i32{ i - 1, j - 1 }, [2]i32{ i + 1, j + 1 } },
                [2][2]i32{ [2]i32{ i - 1, j + 1 }, [2]i32{ i + 1, j - 1 } },
            };
            var ok: bool = true;
            for (l) |t| {
                var mc: u32 = 0;
                var sc: u32 = 0;
                for (t) |v| {
                    if (v[0] < 0 or v[0] >= rows or v[1] < 0 or v[1] >= cols) continue;
                    switch (data[@as(usize, @intCast(v[0] * cols + v[1]))]) {
                        'M' => mc += 1,
                        'S' => sc += 1,
                        else => {},
                    }
                }
                if (mc != 1 or sc != 1) {
                    ok = false;
                    break;
                }
            }
            if (ok) {
                std.debug.print("{{{}, {}}}\n", .{ r, c });
                res += 1;
            }
        }
    }
    std.debug.print("part 2: {}\n", .{res});
}

const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_count = 6; // You can change this number dynamically
    var executables = [_]*std.Build.Step.Compile{ undefined } ** exe_count;

    inline for (0..exe_count) |i| {
        const filename = try std.fmt.allocPrint(b.allocator, "d{d}.zig", .{i + 1});
        defer b.allocator.free(filename);
        
        executables[i] = b.addExecutable(.{
            .name = filename[0..filename.len-4], // remove .zig
            .root_source_file = b.path(filename),
            .optimize = optimize,
            .target = target,
        });
        executables[i].linkLibC();
        b.installArtifact(executables[i]);
    }

    const run_exe = b.addRunArtifact(executables[exe_count - 1]);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

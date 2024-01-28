const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-alsa",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    //    lib.linkSystemLibrary("asound");
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = "include" },
        .install_dir = .header,
        .install_subdir = ".",
        .exclude_extensions = &.{"COPYING"},
    });

    _ = b.addModule("zig-alsa", .{
        .source_file = .{ .path = "src/main.zig" },
        .dependencies = &.{},
    });

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibC();
    main_tests.linkSystemLibrary("asound");

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}

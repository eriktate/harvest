const std = @import("std");

const glfw_path = "./vendor/glfw/";
const epoxy_path = "./vendor/libepoxy/";
const stb_path = "./vendor/stb/";
const miniaudio_path = "./vendor/miniaudio/";

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("harvest", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // include/ contains any custom C files required to interact with vendors
    exe.addIncludePath("./include");
    exe.addIncludePath(stb_path);
    exe.addIncludePath(miniaudio_path);

    exe.addIncludePath(glfw_path ++ "include");
    exe.addLibraryPath(glfw_path ++ "_build/src");

    exe.addIncludePath(epoxy_path ++ "include");
    exe.addIncludePath(epoxy_path ++ "_build/src");

    exe.linkSystemLibrary("glfw");
    exe.linkSystemLibrary("epoxy");
    exe.linkLibC();

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

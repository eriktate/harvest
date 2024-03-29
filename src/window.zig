const std = @import("std");
const c = @import("c.zig");
const gl = @import("gl.zig");

const WindowError = error{
    InitFailed,
    CreateFailed,
};

const Window = @This();
width: u32,
height: u32,
title: []const u8,
win: *c.GLFWwindow,

// timings
now: f64 = 0,
prev_time: f64 = 0,

pub fn init(width: u16, height: u16, title: [*:0]const u8) WindowError!Window {
    var window = Window{
        .width = width,
        .height = height,
        .title = std.mem.span(title),
        .win = undefined,
    };

    if (c.glfwInit() != 1) {
        return WindowError.InitFailed;
    }

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    window.win = c.glfwCreateWindow(width, height, title, null, null) orelse return WindowError.CreateFailed;

    c.glfwMakeContextCurrent(window.win);
    gl.viewport(0, 0, width, height);
    // c.glEnable(c.GL_DEPTH_TEST);
    // c.glDepthFunc(c.GL_GREATER);

    return window;
}

pub fn shouldClose(self: Window) bool {
    const escape = c.glfwGetKey(self.win, c.GLFW_KEY_ESCAPE);
    return escape == c.GLFW_PRESS;
}

pub fn close(self: Window) void {
    c.glfwDestroyWindow(self.win);
    c.glfwTerminate();
}

pub fn swap(self: Window) void {
    c.glfwSwapBuffers(self.win);
    c.glfwPollEvents();
}

pub fn getDelta(self: *Window) f64 {
    self.prev_time = self.now;
    self.now = c.glfwGetTime();
    return self.now - self.prev_time;
}

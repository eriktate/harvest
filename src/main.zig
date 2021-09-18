const std = @import("std");
const window = @import("window.zig");
const shader = @import("shader.zig");
const gl = @import("gl.zig");

pub fn main() anyerror!void {
    const win = try window.Window.init(640, 480, "harvest - float");
    defer win.close();

    const vert_src = @embedFile("../shaders/vertex.glsl");
    const frag_src = @embedFile("../shaders/frag.glsl");
    _ = try shader.Shader.init(vert_src, frag_src);

    while (!win.shouldClose()) {
        gl.clear();
        win.tick();
    }
}

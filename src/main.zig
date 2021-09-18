const std = @import("std");
const window = @import("window.zig");
const shader = @import("shader.zig");
const gl = @import("gl.zig");
const c = @import("c.zig");

pub fn main() anyerror!void {
    const win = try window.Window.init(640, 480, "harvest - float");
    defer win.close();

    const vert_src = @embedFile("../shaders/vertex.glsl");
    const frag_src = @embedFile("../shaders/frag.glsl");
    const sh = try shader.Shader.init(vert_src, frag_src);
    sh.use();

    const vertices = [_]f32{
        -0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
        0.5,  -0.5, 0.0, 0.0, 1.0, 0.0,
        0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
    };

    const color_offset = @intCast(c_int, 0);
    var vao: u32 = 0;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    var vbo: u32 = 0;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 2 * 3 * @sizeOf(f32), null);
    c.glVertexAttribPointer(1, 3, c.GL_FLOAT, c.GL_FALSE, 2 * 3 * @sizeOf(f32), &color_offset);
    c.glEnableVertexAttribArray(0);

    while (!win.shouldClose()) {
        gl.clear();
        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);
        c.glBindVertexArray(0);
        win.tick();
    }
}

const std = @import("std");
const gl = @import("gl.zig");
const Window = @import("window.zig");
const Shader = @import("shader.zig");
const render = @import("render.zig");
const math = @import("math.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...", .{});

    var win = try Window.init(640, 360, "harvest - float");
    defer win.close();

    const vs_src = @embedFile("./shaders/vs.glsl");
    const fs_src = @embedFile("./shaders/fs.glsl");
    const shader = try Shader.init(vs_src, fs_src);

    var quads = [_]render.Quad{render.Quad{
        .tl = render.Vertex{
            .pos = math.Vec3(f32).init(-0.5, 0.5, 0.0),
            .tex_pos = math.Vec2(u16).zero(),
        },
        .tr = render.Vertex{
            .pos = math.Vec3(f32).init(0.5, 0.5, 0.0),
            .tex_pos = math.Vec2(u16).zero(),
        },
        .bl = render.Vertex{
            .pos = math.Vec3(f32).init(-0.5, -0.5, 0.0),
            .tex_pos = math.Vec2(u16).zero(),
        },
        .br = render.Vertex{
            .pos = math.Vec3(f32).init(0.5, -0.5, 0.0),
            .tex_pos = math.Vec2(u16).zero(),
        },
    }};

    var indices = [6]u32{ 0, 0, 0, 0, 0, 0 };
    render.makeIndices(&quads, &indices);

    var vao = gl.genVAO();
    gl.bindVAO(vao);

    var vbo = gl.genBuffer();
    gl.bindBuffer(gl.BufferTarget.Array, vbo);
    gl.bufferData(render.Quad, gl.BufferTarget.Array, &quads, gl.BufferUsage.DynamicDraw);
    // vertex pos
    gl.vertexAttribPointer(0, 3, gl.DataType.Float, false, @sizeOf(render.Vertex), null);
    // vertex tex pos
    gl.vertexAttribPointer(1, 2, gl.DataType.Uint, false, @sizeOf(render.Vertex), @sizeOf(math.Vec3(f32)));

    var ebo = gl.genBuffer();
    gl.bindBuffer(gl.BufferTarget.Element, ebo);
    gl.bufferData(u32, gl.BufferTarget.Element, &indices, gl.BufferUsage.DynamicDraw);
    gl.bindVAO(0);
    gl.bindBuffer(gl.BufferTarget.Array, 0);
    gl.bindBuffer(gl.BufferTarget.Element, 0);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    shader.use();
    while (!win.shouldClose()) {
        gl.bindVAO(vao);
        gl.clearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.drawElements(gl.DrawMode.Triangles, indices.len);
        win.swap();
        gl.bindVAO(0);
    }
}

const std = @import("std");
const gl = @import("gl.zig");
const render = @import("render.zig");
const math = @import("math.zig");

const Window = @import("window.zig");
const QuadRenderer = @import("quad_renderer.zig");
const Shader = @import("shader.zig");
const Texture = @import("texture.zig");
const Sprite = @import("sprite.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...", .{});
    const width = 360;
    const height = 180;

    var win = try Window.init(width, height, "harvest - float");
    defer win.close();

    const knight_raw = @embedFile("./assets/sprites/knight.png");
    _ = try Texture.fromMemory(knight_raw);

    // var quads = [_]render.Quad{render.Quad{
    //     .tl = render.Vertex{
    //         .pos = math.Vec3(f32).init(32.0, 32.0, 0.0),
    //         .tex_pos = math.Vec2(u16).zero(),
    //     },
    //     .tr = render.Vertex{
    //         .pos = math.Vec3(f32).init(64.0, 32.0, 0.0),
    //         .tex_pos = math.Vec2(u16).zero(),
    //     },
    //     .bl = render.Vertex{
    //         .pos = math.Vec3(f32).init(32.0, 64.0, 0.0),
    //         .tex_pos = math.Vec2(u16).zero(),
    //     },
    //     .br = render.Vertex{
    //         .pos = math.Vec3(f32).init(64.0, 64.0, 0.0),
    //         .tex_pos = math.Vec2(u16).zero(),
    //     },
    // }};

    const knight_spr = Sprite.init(math.Vec3(f32).init(180.0, 90.0, 0.0), math.Vec2(u16).init(0, 0), 16, 16);
    var quads = [1]render.Quad{knight_spr.toQuad()};
    var indices: [6]u32 = undefined;

    const quad_renderer = try QuadRenderer.init(width, height, &quads, &indices);

    // var vao = gl.genVAO();
    // gl.bindVAO(vao);

    // var vbo = gl.genBuffer();
    // gl.bindBuffer(gl.BufferTarget.Array, vbo);
    // gl.bufferData(render.Quad, gl.BufferTarget.Array, &quads, gl.BufferUsage.DynamicDraw);
    // // vertex pos
    // gl.vertexAttribPointer(0, 3, gl.DataType.Float, false, @sizeOf(render.Vertex), null);
    // // vertex tex pos
    // gl.vertexAttribPointer(1, 2, gl.DataType.Uint, false, @sizeOf(render.Vertex), @sizeOf(math.Vec3(f32)));

    // var ebo = gl.genBuffer();
    // gl.bindBuffer(gl.BufferTarget.Element, ebo);
    // gl.bufferData(u32, gl.BufferTarget.Element, &indices, gl.BufferUsage.DynamicDraw);
    // gl.bindVAO(0);
    // gl.bindBuffer(gl.BufferTarget.Array, 0);
    // gl.bindBuffer(gl.BufferTarget.Element, 0);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    // shader.use();
    while (!win.shouldClose()) {
        // gl.bindVAO(vao);
        gl.clearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        // gl.drawElements(gl.DrawMode.Triangles, indices.len);
        quad_renderer.draw();
        win.swap();
        gl.bindVAO(0);
    }
}

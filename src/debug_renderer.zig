const std = @import("std");
const gl = @import("gl.zig");
const math = @import("math.zig");

const Shader = @import("shader.zig");
const Vertex = @import("render.zig").Vertex;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Vec3 = math.Vec3(f32);
const Vec2 = math.Vec2(u16);

const Debug = @This();
vertices: ArrayList(Vertex),
shader: Shader,
active: bool = false,
vao: u32,
vbo: u32,

pub fn init(alloc: Allocator, cap: u64, width: u32, height: u32) !Debug {
    var vertices = try ArrayList(Vertex).initCapacity(alloc, cap);
    const vert_src = @embedFile("../shaders/debug.vert");
    const frag_src = @embedFile("../shaders/debug.frag");

    const shader = try Shader.init(vert_src, frag_src);
    shader.setUint("width", width);
    shader.setUint("height", height);
    const vao = gl.genVAO();
    gl.bindVAO(vao);

    const vbo = gl.genBuffer();
    gl.bindBuffer(gl.BufferTarget.Array, vbo);
    gl.bufferData(Vertex, gl.BufferTarget.Array, vertices.items, gl.BufferUsage.DynamicDraw);

    gl.vertexAttribPointer(0, 3, gl.DataType.Float, false, @sizeOf(Vertex), null);
    gl.vertexAttribPointer(1, 2, gl.DataType.Uint, false, @sizeOf(Vertex), @sizeOf(Vec3));
    gl.bindVAO(0);
    gl.bindBuffer(gl.BufferTarget.Array, 0);

    return Debug{
        .vertices = vertices,
        .shader = shader,
        .vao = vao,
        .vbo = vbo,
    };
}

pub fn drawLine(self: *Debug, start: Vec3, end: Vec3) !void {
    const start_vert = Vertex{ .pos = start, .tex_pos = Vec2.zero() };
    const end_vert = Vertex{ .pos = end, .tex_pos = Vec2.zero() };
    try self.vertices.append(start_vert);
    try self.vertices.append(end_vert);
}

pub fn draw(self: *Debug) void {
    if (!self.active) {
        return;
    }

    self.shader.use();
    gl.bindVAO(self.vao);
    gl.bindBuffer(gl.BufferTarget.Array, self.vbo);
    gl.bufferData(Vertex, gl.BufferTarget.Array, self.vertices.items, gl.BufferUsage.DynamicDraw);
    gl.drawArrays(gl.DrawMode.Lines, self.vertices.items.len);
    self.vertices.resize(0) catch unreachable;
}

pub fn toggle(self: *Debug) void {
    self.active = !self.active;
}

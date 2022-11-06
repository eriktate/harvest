const std = @import("std");
const Texture = @import("texture.zig");
const Shader = @import("shader.zig");
const render = @import("render.zig");
const gl = @import("gl.zig");
const math = @import("math.zig");
const ArrayList = std.ArrayList;

const QuadRenderer = @This();
shader: Shader,
world_width: u32,
world_height: u32,
indices: ArrayList(u32),
texture: Texture,
vao: u32,
vbo: u32,
ebo: u32,

pub fn init(alloc: std.mem.Allocator, world_width: u32, world_height: u32, max_quads: usize, quads: []const render.Quad, tex: Texture) !QuadRenderer {
    var indices = try ArrayList(u32).initCapacity(alloc, max_quads * 6);
    const vert_src = @embedFile("../shaders/sprite.vert");
    const frag_src = @embedFile("../shaders/sprite.frag");

    const shader = try Shader.init(vert_src, frag_src);
    shader.setUint("world_width", world_width);
    shader.setUint("world_height", world_height);

    const vao = gl.genVAO();
    gl.bindVAO(vao);
    const vbo = gl.genBuffer();
    gl.bindBuffer(gl.BufferTarget.Array, vbo);
    gl.bufferData(render.Quad, gl.BufferTarget.Array, quads, gl.BufferUsage.DynamicDraw);

    // vertex pos
    gl.vertexAttribPointer(0, 3, gl.DataType.Float, false, @sizeOf(render.Vertex), null);

    // vertex tex pos
    gl.vertexAttribPointer(1, 2, gl.DataType.Ushort, false, @sizeOf(render.Vertex), @sizeOf(math.Vec3(f32)));

    const ebo = gl.genBuffer();
    gl.bindBuffer(gl.BufferTarget.Element, ebo);
    gl.bufferData(u32, gl.BufferTarget.Element, indices.items, gl.BufferUsage.DynamicDraw);
    gl.bindVAO(0);
    gl.bindBuffer(gl.BufferTarget.Array, 0);
    gl.bindBuffer(gl.BufferTarget.Element, 0);

    return QuadRenderer{
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
        .shader = shader,
        .indices = indices,
        .world_width = world_width,
        .world_height = world_height,
        .texture = tex,
    };
}

pub fn draw(self: *QuadRenderer, quads: []const render.Quad) void {
    self.texture.bind();
    self.genIndices(quads);
    gl.bindVAO(self.vao);

    // load quad data
    gl.bindBuffer(gl.BufferTarget.Array, self.vbo);
    gl.bufferData(render.Quad, gl.BufferTarget.Array, quads, gl.BufferUsage.DynamicDraw);

    // load elements
    gl.bindBuffer(gl.BufferTarget.Element, self.ebo);
    gl.bufferData(u32, gl.BufferTarget.Element, self.indices.items, gl.BufferUsage.DynamicDraw);

    self.shader.use();
    gl.drawElements(gl.DrawMode.Triangles, self.indices.items.len);
}

pub fn genIndices(self: *QuadRenderer, quads: []const render.Quad) void {
    // reset length, because we're going to regenerate all of the indices
    self.indices.items.len = quads.len * 6;

    for (quads) |_, i| {
        const idx = @intCast(u32, i);
        self.indices.items[6 * i] = 4 * idx;
        self.indices.items[6 * i + 1] = 4 * idx + 1;
        self.indices.items[6 * i + 2] = 4 * idx + 2;
        self.indices.items[6 * i + 3] = 4 * idx + 2;
        self.indices.items[6 * i + 4] = 4 * idx + 3;
        self.indices.items[6 * i + 5] = 4 * idx + 1;
    }
}

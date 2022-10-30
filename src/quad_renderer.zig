const Texture = @import("texture.zig");
const Shader = @import("shader.zig");
const render = @import("render.zig");
const gl = @import("gl.zig");
const math = @import("math.zig");

const QuadRenderer = @This();
shader: Shader,
world_width: u32,
world_height: u32,
quads: []const render.Quad,
indices: []u32,
vao: u32,
vbo: u32,
ebo: u32,

pub fn init(world_width: u32, world_height: u32, quads: []const render.Quad, indices: []u32) !QuadRenderer {
    const vert_src = @embedFile("./shaders/sprite.vert");
    const frag_src = @embedFile("./shaders/sprite.frag");

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
    gl.bufferData(u32, gl.BufferTarget.Element, indices, gl.BufferUsage.DynamicDraw);
    gl.bindVAO(0);
    gl.bindBuffer(gl.BufferTarget.Array, 0);
    gl.bindBuffer(gl.BufferTarget.Element, 0);

    return QuadRenderer{
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
        .shader = shader,
        .quads = quads,
        .indices = indices,
        .world_width = world_width,
        .world_height = world_height,
    };
}

pub fn draw(self: QuadRenderer) void {
    render.makeIndices(self.quads, self.indices);
    gl.bindVAO(self.vao);

    // load quad data
    gl.bindBuffer(gl.BufferTarget.Array, self.vbo);
    gl.bufferData(render.Quad, gl.BufferTarget.Array, self.quads, gl.BufferUsage.DynamicDraw);

    // load elements
    gl.bindBuffer(gl.BufferTarget.Element, self.ebo);
    gl.bufferData(u32, gl.BufferTarget.Element, self.indices, gl.BufferUsage.DynamicDraw);

    self.shader.use();
    gl.drawElements(gl.DrawMode.Triangles, self.indices.len);
}

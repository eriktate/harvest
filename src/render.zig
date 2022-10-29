// NOTE: extern structs are used here to guarantee field order.
// Once packed structs are stabalized, they should be replaced

const math = @import("math.zig");

pub const Vertex = extern struct {
    pos: math.Vec3(f32),
    tex_pos: math.Vec2(u16),
};

pub const Quad = extern struct {
    tl: Vertex,
    tr: Vertex,
    bl: Vertex,
    br: Vertex,
};

pub fn makeIndices(quads: []const Quad, indices: [*]u32) void {
    for (quads) |_, i| {
        const idx = @intCast(u32, i);
        indices[6 * idx] = 4 * idx;
        indices[6 * idx + 1] = 4 * idx + 1;
        indices[6 * idx + 2] = 4 * idx + 2;
        indices[6 * idx + 3] = 4 * idx + 2;
        indices[6 * idx + 4] = 4 * idx + 3;
        indices[6 * idx + 5] = 4 * idx + 1;
    }
}

// TODO (etate): add functions here that set up and handle rendering instead of allowing
// the main function to deal with all of that

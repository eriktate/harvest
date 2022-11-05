// NOTE: extern structs are used here to guarantee field order.
// Once packed structs are stabalized, they should be replaced

const std = @import("std");
const math = @import("math.zig");
const ArrayList = std.ArrayList;

pub const Vertex = extern struct {
    pos: math.Vec3(f32),
    tex_pos: math.Vec2(u16),

    pub fn zero() Vertex {
        return Vertex{
            .pos = math.Vec3(f32).zero(),
            .tex_pos = math.Vec2(u16).zero(),
        };
    }
};

pub const Quad = extern struct {
    tl: Vertex,
    tr: Vertex,
    bl: Vertex,
    br: Vertex,

    pub fn zero() Quad {
        return Quad{
            .tl = Vertex.zero(),
            .tr = Vertex.zero(),
            .bl = Vertex.zero(),
            .br = Vertex.zero(),
        };
    }
};

// TODO (etate): add functions here that set up and handle rendering instead of allowing
// the main function to deal with all of that

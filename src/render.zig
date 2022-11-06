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

    pub fn print(self: Quad) void {
        std.debug.print("\n\ntl:\n  pos: {d}, {d}\n", .{ self.tl.pos.x, self.tl.pos.y });
        std.debug.print("  tex: {d}, {d}", .{ self.tl.tex_pos.x, self.tl.tex_pos.y });

        std.debug.print("\ntr:\n  pos: {d}, {d}\n", .{ self.tr.pos.x, self.tr.pos.y });
        std.debug.print("  tex: {d}, {d}", .{ self.tr.tex_pos.x, self.tr.tex_pos.y });

        std.debug.print("\nbl:\n  pos: {d}, {d}\n", .{ self.bl.pos.x, self.bl.pos.y });
        std.debug.print("  tex: {d}, {d}", .{ self.bl.tex_pos.x, self.bl.tex_pos.y });

        std.debug.print("\nbr:\n  pos: {d}, {d}\n", .{ self.br.pos.x, self.br.pos.y });
        std.debug.print("  tex: {d}, {d}", .{ self.br.tex_pos.x, self.br.tex_pos.y });
    }
};

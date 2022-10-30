const render = @import("render.zig");
const math = @import("math.zig");
const Texture = @import("texture.zig");

const Pos = math.Vec3(f32);
const TexPos = math.Vec2(u16);

const Sprite = @This();
pos: Pos,
tex_pos: TexPos,
width: u16,
height: u16,

pub fn init(pos: Pos, tex_pos: TexPos, width: u16, height: u16) Sprite {
    return Sprite{
        .pos = pos,
        .tex_pos = tex_pos,
        .width = width,
        .height = height,
    };
}

fn shiftVertex(vert: render.Vertex, x: u16, y: u16) render.Vertex {
    return render.Vertex{
        .pos = vert.pos.add(Pos.init(@intToFloat(f32, x), @intToFloat(f32, y), 0)),
        .tex_pos = vert.tex_pos.add(TexPos.init(x, y)),
    };
}

pub fn toQuad(self: Sprite) render.Quad {
    const tl = render.Vertex{ .pos = self.pos, .tex_pos = self.tex_pos };
    return render.Quad{
        .tl = tl,
        .tr = shiftVertex(tl, self.width, 0),
        .bl = shiftVertex(tl, 0, self.height),
        .br = shiftVertex(tl, self.width, self.height),
    };
}

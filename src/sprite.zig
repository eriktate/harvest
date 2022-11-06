const std = @import("std");
const render = @import("render.zig");
const math = @import("math.zig");
const Texture = @import("texture.zig");
const Animation = @import("animation.zig");
const Atlas = @import("atlas.zig");

const Pos = math.Vec3(f32);
const TexPos = math.Vec2(u16);

pub const DisplayTag = enum {
    static,
    animation,
};

pub const Display = union(DisplayTag) {
    static: Atlas.Frame,
    animation: *Animation,
};

const Sprite = @This();
pos: Pos,
display: Display,
width: u16,
height: u16,

pub fn init(pos: Pos, display: Display, width: u16, height: u16) Sprite {
    return Sprite{
        .pos = pos,
        .display = display,
        .width = width,
        .height = height,
    };
}

pub fn toQuad(self: Sprite) render.Quad {
    const frame = switch (self.display) {
        .static => self.display.static,
        .animation => self.display.animation.getFrame(),
    };

    const width = @intToFloat(f32, self.width);
    const height = @intToFloat(f32, self.height);

    const tex_dim = frame.br.sub(frame.tl);

    const result = render.Quad{
        .tl = render.Vertex{ .pos = self.pos, .tex_pos = frame.tl },
        .tr = render.Vertex{
            .pos = self.pos.add(Pos.init(width, 0, 0)),
            .tex_pos = frame.tl.add(TexPos.init(tex_dim.x, 0)),
        },
        .bl = render.Vertex{
            .pos = self.pos.add(Pos.init(0, height, 0)),
            .tex_pos = frame.tl.add(TexPos.init(0, tex_dim.y)),
        },
        .br = render.Vertex{
            .pos = self.pos.add(Pos.init(width, height, 0)),
            .tex_pos = frame.br,
        },
    };
    return result;
}

pub fn animation(anim: *Animation) Display {
    return Display{ .animation = anim };
}

pub fn static(frame: Atlas.Frame) Display {
    return Display{ .static = frame };
}

pub fn tick(self: *Sprite, delta: f64) void {
    switch (self.display) {
        .static => {},
        .animation => self.display.animation.tick(delta),
    }
}

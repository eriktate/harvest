const math = @import("math.zig");
const Debug = @import("debug_renderer.zig");
const Pos = math.Vec3(f32);

const Box = @This();
id: usize = 0,
entity_id: ?usize = null,
pos: Pos,
size: Pos,
solid: bool,

pub fn init(pos: Pos, w: f32, h: f32, solid: bool) Box {
    return Box{
        .pos = pos,
        .size = math.Vec3(f32).init(w, h, 0),
        .solid = solid,
    };
}

// pub fn overlaps(self: Box, other: Box) bool {
//     if (self.id == other.id) {
//         return false;
//     }

//     const check = self.pos.add(self.size).sub(other.pos.add(other.size));
//     return (@fabs(check.x) <= self.size.x and @fabs(check.y) <= self.size.y) or (@fabs(check.x) <= other.size.x and @fabs(check.y) <= other.size.y);
// }

fn _overlaps(self: Box, other: Box) bool {
    if (self.id == other.id) {
        return false;
    }

    const left = self.pos.x;
    const right = self.pos.x + self.size.x;
    const top = self.pos.y;
    const bot = self.pos.y + self.size.y;

    const other_left = other.pos.x;
    const other_right = other.pos.x + other.size.x;
    const other_top = other.pos.y;
    const other_bot = other.pos.y + other.size.y;

    const overlap_x = (left > other_left and left < other_right) or (right > other_left and right < other_right);
    const overlap_y = (top > other_top and top < other_bot) or (bot > other_top and bot < other_bot);

    return overlap_x and overlap_y;
}

pub fn overlaps(self: Box, other: Box) bool {
    return _overlaps(self, other) or _overlaps(other, self);
}

pub fn drawDebug(self: Box, debug: *Debug) !void {
    try debug.drawLine(self.pos, self.pos.add(Pos.init(self.size.x, 0, 0)));
    try debug.drawLine(self.pos.add(Pos.init(self.size.x, 0, 0)), self.pos.add(self.size));
    try debug.drawLine(self.pos.add(self.size), self.pos.add(Pos.init(0, self.size.y, 0)));
    try debug.drawLine(self.pos.add(Pos.init(0, self.size.y, 0)), self.pos);
}

test "overlapping boxes" {
    const std = @import("std");
    const assert = std.debug.assert;

    const box = Box.init(Pos.init(64, 64, 0), 32, 32, true);
    const overlapping = Box.init(Pos.init(84, 84, 0), 16, 16, true);

    const not_overlapping = Box.init(Pos.init(32, 32, 0), 16, 16, true);
    const contained = Box.init(Pos.init(68, 68, 0), 4, 4, true);

    const horizontal_touching = Box.init(Pos.init(32, 64, 0), 32, 32, true);
    const vertical_touching = Box.init(Pos.init(64, 32, 0), 32, 32, true);

    assert(box.overlaps(overlapping));
    assert(!box.overlaps(not_overlapping));
    assert(box.overlaps(contained));
    assert(contained.overlaps(box));
    assert(box.overlaps(horizontal_touching));
    assert(box.overlaps(vertical_touching));
}

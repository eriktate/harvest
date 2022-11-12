const math = @import("math.zig");
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

pub fn overlaps(self: Box, other: Box) bool {
    if (self.id == other.id) {
        return false;
    }

    const check = self.pos.add(self.size).sub(other.pos.add(other.size));
    return (@fabs(check.x) <= self.size.x and @fabs(check.y) <= self.size.y) or (@fabs(check.x) <= other.size.x and @fabs(check.y) <= other.size.y);
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

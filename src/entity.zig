const Box = @import("box.zig");
const Sprite = @import("sprite.zig");
const Manager = @import("manager.zig");

const Entity = @This();
id: usize,
sprite_id: ?usize,
box_id: ?usize,
mgr: ?*Manager,

pub fn init(sprite_id: ?usize, box_id: ?usize) Entity {
    return Entity{
        .id = 0,
        .sprite_id = sprite_id,
        .box_id = box_id,
        .mgr = undefined,
    };
}

pub fn getSprite(self: Entity) ?Sprite {
    return self.mgr.?.get(Sprite, self.sprite_id.?);
}

pub fn getBox(self: Entity) ?Box {
    return self.mgr.?.get(Box, self.box_id.?);
}

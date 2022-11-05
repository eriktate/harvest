const math = @import("math.zig");
const Box = @import("box.zig");
const Sprite = @import("sprite.zig");
const Manager = @import("manager.zig");

const Pos = math.Vec3(f32);

// An Config represents the non-managed fields an Entity can be configured with
pub const Config = struct {
    pos: math.Vec3(f32) = Pos.zero(),

    // entity pos can differ from where things are actually drawn/evaluated
    sprite_offset: math.Vec3(f32) = Pos.zero(),
    box_offset: math.Vec3(f32) = Pos.zero(),
};

const Entity = @This();
id: usize,
sprite_id: ?usize,
box_id: ?usize,
mgr: ?*Manager,

config: Config,

pub fn init(id: usize, sprite_id: ?usize, box_id: ?usize) Entity {
    return Entity{
        .id = id,
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

const std = @import("std");
const math = @import("math.zig");
const render = @import("render.zig");
const Entity = @import("entity.zig");
const Sprite = @import("sprite.zig");
const Box = @import("box.zig");
const ArrayList = std.ArrayList;
const Quad = render.Quad;

const ManagerError = error{
    DoesNotExist,
};

const Manager = @This();
entities: ArrayList(?Entity),
sprites: ArrayList(?Sprite),
boxes: ArrayList(?Box),
quads: ArrayList(Quad),

// because of fragmentation, the length of the ArrayLists aren't necessarily the count of
// each type so we track the actual count separately
entity_count: usize,
sprite_count: usize,
box_count: usize,
quad_count: usize,

pub fn init(alloc: std.mem.Allocator, num: usize) !Manager {
    var entities = try ArrayList(?Entity).initCapacity(alloc, num);
    var boxes = try ArrayList(?Box).initCapacity(alloc, num);
    var sprites = try ArrayList(?Sprite).initCapacity(alloc, num);
    var quads = try ArrayList(Quad).initCapacity(alloc, num);

    return Manager{
        .entities = entities,
        .boxes = boxes,
        .sprites = sprites,
        .quads = quads,

        .entity_count = 0,
        .sprite_count = 0,
        .box_count = 0,
        .quad_count = 0,
    };
}

fn getList(self: *Manager, comptime T: type) *ArrayList(?T) {
    return switch (T) {
        Entity => &self.entities,
        Sprite => &self.sprites,
        Box => &self.boxes,
        Quad => &self.quads,
        else => @compileError(@typeName(T) ++ " is a non-managed type"),
    };
}

fn incrementCount(self: *Manager, comptime T: type) void {
    switch (T) {
        Entity => self.entity_count += 1,
        Sprite => self.sprite_count += 1,
        Box => self.box_count += 1,
        else => @compileError(@typeName(T) ++ " is a nonpmanaged type"),
    }
}

fn decrementCount(self: *Manager, comptime T: type) void {
    switch (T) {
        Entity => self.entity_count -= 1,
        Sprite => self.sprite_count -= 1,
        Box => self.box_count -= 1,
        else => @compileError(@typeName(T) ++ " is a nonpmanaged type"),
    }
}

fn add(self: *Manager, comptime T: type, val: T) !usize {
    var v = val;
    var list = self.getList(T);
    var id = list.items.len;

    // try to find an empty slot first
    for (list.items) |item, idx| {
        if (item == null) {
            id = idx;
            break;
        }
    }

    if (T == Entity) {
        v.mgr = self;
        v.id = id;
    }

    if (id == list.items.len) {
        try list.append(v);
    } else {
        list.items[id] = v;
    }

    self.incrementCount(T);
    return id;
}

pub fn addSprite(self: *Manager, spr: Sprite) !usize {
    return self.add(Sprite, spr);
}

pub fn addBox(self: *Manager, box: Box) !usize {
    return self.add(Box, box);
}

pub fn addEntity(self: *Manager, ent_config: Entity.Config, opt_spr: ?Sprite, opt_box: ?Box) !usize {
    // entity position overrides sprite and box positions when provided at instantiation
    var spr_id: ?usize = null;
    if (opt_spr) |spr| {
        var spr_cp = spr;
        spr_cp.pos = ent_config.pos.add(ent_config.sprite_offset);
        spr_id = try self.addSprite(spr_cp);
    }

    var box_id: ?usize = null;
    if (opt_box) |box| {
        var box_cp = box;
        box_cp.pos = ent_config.pos.add(ent_config.box_offset);
        box_id = try self.addBox(box_cp);
    }

    const entity = Entity{
        .id = 0, // this will be overwritten
        .sprite_id = spr_id,
        .box_id = box_id,
        .config = ent_config,
        .mgr = null,
    };

    return try self.add(Entity, entity);
}

pub fn attach(self: *Manager, comptime T: type, entity_id: usize, val: T) !void {
    var entity = self.entities.items[entity_id] orelse return error.DoesNotExist;
    const id = try self.add(T, val);

    switch (T) {
        Sprite => self.entities.items[entity_id].?.sprite_id = id,
        Box => entity.box_id = id,
        else => @compileError(@typeName(T) ++ " cannot be attached to an Entity"),
    }
}

pub fn destroy(self: *Manager, comptime T: type, id: usize) void {
    self.getList(T).items[id] = null;
    self.decrementCount(T);
}

pub fn get(self: *Manager, comptime T: type, id: usize) !T {
    return self.getList(T).items[id] orelse ManagerError.DoesNotExist;
}

pub fn getMut(self: *Manager, comptime T: type, id: usize) !*T {
    if (self.getList(T).items[id]) |*item| {
        return item;
    }
    return ManagerError.DoesNotExist;
}

pub fn move(self: *Manager, id: usize, translation: math.Vec3(f32)) !void {
    var entity = try self.getMut(Entity, id);
    entity.config.pos = entity.config.pos.add(translation);

    if (entity.sprite_id) |sprite_id| {
        var sprite = try self.getMut(Sprite, sprite_id);
        sprite.pos = sprite.pos.add(translation);
        if (translation.x < 0) {
            sprite.flip = true;
        }

        if (translation.x > 0) {
            sprite.flip = false;
        }
    }

    if (entity.box_id) |box_id| {
        var box = try self.getMut(Box, box_id);
        box.pos = box.pos.add(translation);
    }
}

pub fn setPos(self: *Manager, id: usize, pos: math.Vec3(f32)) !void {
    var entity = try self.getMut(Entity, id);
    entity.pos = pos;
    if (entity.sprite_id) |sprite_id| {
        var sprite = try self.getMut(Sprite, sprite_id);
        sprite.pos = entity.pos.add(entity.sprite_offset);
    }

    if (entity.box_id) |box_id| {
        var box = try self.getMut(Box, box_id);
        box.pos = entity.pos.add(entity.box_offset);
    }
}

pub fn deinit(self: Manager) void {
    self.entities.deinit();
    self.sprites.deinit();
    self.boxes.deinit();
    self.quads.deinit();
}

// genQuads creates a gap-less slices of quads representing all of the sprites
// held by the manager
pub fn genQuads(self: *Manager) []render.Quad {
    self.quads.items.len = self.quads.capacity;
    var idx: usize = 0;
    for (self.sprites.items) |opt_spr| {
        const spr = opt_spr orelse continue;
        self.quads.items[idx] = spr.toQuad();
        idx += 1;
    }

    self.quads.items.len = idx;
    return self.quads.items;
}

pub fn printSize(self: Manager) void {
    std.debug.print("\nEntities (fragmented): {d}", .{self.entities.items.len});
    std.debug.print("\nEntities: {d}", .{self.entity_count});
    std.debug.print("\nEntity bytes (fragmented): {d}", .{(@sizeOf(Entity) * self.entities.items.len)});
    std.debug.print("\nEntity bytes: {d}", .{(@sizeOf(Entity) * self.entity_count)});

    std.debug.print("\nSprites (fragmented): {d}", .{self.sprites.items.len});
    std.debug.print("\nSprites: {d}", .{self.sprite_count});
    std.debug.print("\nSprite bytes (fragmented): {d}", .{(@sizeOf(Sprite) * self.sprites.items.len)});
    std.debug.print("\nSprites bytes: {d}", .{(@sizeOf(Sprite) * self.sprite_count)});

    std.debug.print("\nQuads: {d}", .{self.quads.items.len});
    std.debug.print("\nQuads bytes: {d}", .{(@sizeOf(Sprite) * self.sprite_count)});
}

pub fn tick(self: Manager, delta: f64) void {
    for (self.sprites.items) |*opt_spr| {
        if (opt_spr.*) |*spr| {
            spr.tick(delta);
        }
    }
}

pub fn flipSprite(self: Manager, spr_id: u32, flip: bool) void {
    if (self.sprites.items[spr_id]) |*spr| {
        spr.flip = flip;
    }
}

test "add all item types" {
    const assert = std.debug.assert;

    var mgr = try Manager.init(std.testing.allocator, 10);
    defer mgr.deinit();

    _ = try mgr.add(Entity, Entity.init(null, null));
    const ent_id = try mgr.add(Entity, Entity.init(null, null));
    _ = try mgr.add(Sprite, Sprite.init(math.Vec3(f32).zero(), math.Vec2(u16).zero(), 16, 16));
    const spr_id = try mgr.add(Sprite, Sprite.init(math.Vec3(f32).zero(), math.Vec2(u16).zero(), 16, 16));
    _ = try mgr.add(Box, Box{ .pos = math.Vec3(f32).zero(), .size = math.Vec3(f32).zero() });
    const box_id = try mgr.add(Box, Box{ .pos = math.Vec3(f32).zero(), .size = math.Vec3(f32).zero() });

    assert(ent_id == 1);
    assert(spr_id == 1);
    assert(box_id == 1);
}

test "add, get, attach, and destroy an entity" {
    const assert = std.debug.assert;

    var mgr = try Manager.init(std.testing.allocator, 10);
    defer mgr.deinit();

    const ent_id = try mgr.add(Entity, Entity.init(null, null));
    try mgr.attach(Sprite, ent_id, Sprite.init(math.Vec3(f32).zero(), math.Vec2(u16).zero(), 16, 16));
    const entity = try mgr.get(Entity, ent_id);
    assert(entity.sprite_id != null);
    mgr.destroy(Entity, ent_id);
    assert(mgr.get(Entity, ent_id) == error.DoesNotExist);

    // ensure ID is reclaimed
    const ent_id_two = try mgr.add(Entity, Entity.init(null, null));
    assert(ent_id_two == ent_id);
}

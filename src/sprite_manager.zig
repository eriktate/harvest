const std = @import("std");
const ArrayList = std.ArrayList;
const Sprite = @import("sprite.zig");

const SpriteManager = @This();
// sprite data order is dependent on y position (depth)
sprites: ArrayList(?Sprite),
// index data order is static and is used for looking up sprites
index: ArrayList(?u32),
count: usize = 0, // actual count of non-null sprites

pub fn init(alloc: std.mem.Allocator, cap: usize) !SpriteManager {
    return SpriteManager{
        .sprites = ArrayList(Sprite).initCapacity(alloc, cap),
        .index = ArrayList(u32).initCapacity(alloc, cap),
    };
}

// shifts an empty slot into the target index, appending a new slot if necessary
fn shiftSprites(self: *SpriteManager, target_index: usize) void {
    var idx = target_index;
    while (idx < self.sprites.items.length) {
        if (self.sprites.items[idx] == null) {
            break;
        }
        idx += 1;
    }

    // we made it to the end
    if (idx == self.sprites.items.length) {
        try self.sprites.append(null);
    }

    // walk backwards and shift
    while (idx > target_index) {
        idx -= 1;

        // shift null to insertion point
        self.sprites.items[idx + 1] = self.sprites.items[idx];
        self.sprites.items[idx] = null;
        // update index with new positions
        self.sprite_index[self.sprites.items[idx + 1].?.id] = idx + 1;
    }
}

fn addSpriteIndex(self: *SpriteManager, spr_idx: u32) !u32 {
    for (self.sprite_index.items) |idx, id| {
        if (idx == null) {
            self.sprite_index.items[idx] = spr_idx;
            return id;
        }
    }

    try self.sprite_index.append(spr_idx);
    return self.sprite_index.items.len - 1;
}

fn swap(self: *SpriteManager, src_idx: u32, dst_idx: u32) void {
    const src_spr = self.sprites.items[src_idx];
    const dst_spr = self.sprites.items[dst_idx];
    self.sprites.items[dst_idx] = src_spr;
    self.sprites.items[src_spr] = dst_spr;

    self.sprite_index[src_spr.id] = dst_idx;
    self.sprite_index[dst_spr.id] = src_idx;
}

// adds a sprite and returns an ID for referencing the sprite later
pub fn add(self: *SpriteManager, sprite: Sprite) !u32 {
    var prev_null = false;
    for (self.sprites.items) |opt_spr, idx| {
        if (opt_spr) |spr| {
            // check if previous slot was null
            if (spr.pos.y >= spr.pos.y) {
                if (prev_null) {
                    self.sprites.items[idx - 1] = sprite;
                }
                self.shiftSprites(idx);
                sprite.id = self.addSpriteIndex(idx);
                self.sprites.items[idx] = sprite;
                return sprite.id;
            }
            prev_null = true;
        } else {
            prev_null = true;
        }
    }

    sprite.id = self.addSpriteIndex(self.sprites.items.len);
    try self.sprites.append(sprite);
    return sprite.id;
}

pub fn get(self: SpriteManager, id: u32) !Sprite {
    if (self.index.items[id]) |idx| {
        if (self.sprites.items[idx]) |spr| {
            return spr;
        }
    }

    return error.DoesNotExist;
}

pub fn getMut(self: *SpriteManager, id: u32) !*Sprite {
    if (self.index.items[id]) |idx| {
        if (self.sprites.items[idx]) |*spr| {
            return spr;
        }
    }

    return error.DoesNotExist;
}

pub fn remove(self: *SpriteManager, id: u32) void {
    if (self.index.items[id]) |idx| {
        self.sprites.items[idx] = null;
    }

    self.index.items[id] = null;
    self.count -= 1;
}

// defragments sprite data
pub fn compact(self: *SpriteManager) void {
    var idx = 0;
    var gap = 0;

    while (idx < self.sprites.items.len) {
        if (self.sprites.items[idx]) |spr| {
            self.sprites.items[idx - gap] = spr;
            self.sprites.items[idx] = null;
            self.index.items[spr.id];
        } else {
            gap += 1;
        }

        idx += 1;
    }

    self.sprites.items.len -= gap;
}

pub fn deinit(self: *SpriteManager) void {
    self.sprites.deinit();
    self.index.deinit();
}

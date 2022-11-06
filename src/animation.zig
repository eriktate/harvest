const std = @import("std");
const math = @import("math.zig");
const Atlas = @import("atlas.zig");

// An Animation is a simple data structure that captures the minimum functionality to achieve animation.
// The frames are a slice to texture coordinates that act as the top-left corner of a frame. The dimensions
// are decided by the dimensions of the owning Sprite. The state of the current_frame is managed completely
// internally and can be fetched at any point with anim.getFrame(). The only requirement is that the
// anim.tick() function be called on each iteration of the main loop

const Animation = @This();
frames: []const Atlas.Frame,
current_frame: f64, // this needs to be a float so we can animate smoothly regardless of framerate
rate: u16,

pub fn init(frames: []const Atlas.Frame, rate: u16) Animation {
    return Animation{
        .frames = frames,
        .current_frame = 0,
        .rate = rate,
    };
}

pub fn tick(self: *Animation, delta: f64) void {
    var current_frame = self.current_frame + (delta * @intToFloat(f64, self.rate));
    const len = @intToFloat(f64, self.frames.len);
    if (current_frame >= len) {
        current_frame = @mod(current_frame, len);
    }

    self.current_frame = current_frame;
}

pub fn getFrame(self: Animation) Atlas.Frame {
    return self.frames[@floatToInt(usize, self.current_frame)];
}

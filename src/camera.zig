const Window = @import("window.zig");
const math = @import("math.zig");
const Vec3 = math.Vec3(f32);
const Vec2 = math.Vec2(f32);
const Mat4 = math.Mat4(f32);

const Camera = @This();
win: *const Window,
target: Vec3,
tolerance: Vec2,
width: f32,
height: f32,

pub fn init(win: *const Window, target: Vec3, tolerance: Vec2, width: u32, height: u32) Camera {
    return Camera{
        .win = win,
        .target = target,
        .tolerance = tolerance,
        .width = @intToFloat(f32, width),
        .height = @intToFloat(f32, height),
    };
}

pub fn setTarget(self: *Camera, target: Vec3) void {
    self.target = target;
}

pub fn trackTarget(self: *Camera, target: Vec3) void {
    var diff = self.target.sub(target);
    var intolerant_diff = Vec2.init(@fabs(diff.x), @fabs(diff.y));

    intolerant_diff = intolerant_diff.sub(self.tolerance);
    if (intolerant_diff.x > 0) {
        if (self.target.x > target.x) {
            self.target.x -= intolerant_diff.x;
        } else {
            self.target.x += intolerant_diff.x;
        }
    }

    if (intolerant_diff.y > 0) {
        if (self.target.y > target.y) {
            self.target.y -= intolerant_diff.y;
        } else {
            self.target.y += intolerant_diff.y;
        }
    }
}

pub fn projection(self: Camera) Mat4 {
    const viewport_width = @intToFloat(f32, self.win.width);
    const viewport_height = @intToFloat(f32, self.win.height);
    const half_width = self.width / 2;
    const half_height = self.height / 2;

    const top = -(((self.target.y - half_height) / viewport_height) * 2 - 1);
    const bottom = -(((self.target.y + half_height) / viewport_height) * 2 - 1);
    const left = ((self.target.x - half_width) / viewport_width) * 2 - 1;
    const right = ((self.target.x + half_width) / viewport_width) * 2 - 1;

    return Mat4.orthographic(top, left, bottom, right);
}

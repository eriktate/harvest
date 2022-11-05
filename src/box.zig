const math = @import("math.zig");
const Pos = math.Vec3(f32);

const Box = @This();
pos: Pos,
size: Pos,

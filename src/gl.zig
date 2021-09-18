const c = @import("c.zig");

pub fn clear() void {
    c.glClear(c.GL_COLOR_BUFFER_BIT);
}

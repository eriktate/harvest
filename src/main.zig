const std = @import("std");
const window = @import("window.zig");
const c = @import("c.zig");

pub fn main() anyerror!void {
    const win = try window.Window.init(640, 480, "harvest - float");
    defer win.close();

    // loop forever
    while (!win.shouldClose()) {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        win.tick();
    }
}

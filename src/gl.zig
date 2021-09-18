const c = @import("c.zig");

pub fn clear() void {
    c.glClear(c.GL_COLOR_BUFFER_BIT);
}

pub fn genVBO() u32 {
    var id = 0;
    c.glGenBuffers(1, &id);

    return id;
}

pub fn bindArrayBuffer(id: u32) void {
    c.glBindBuffer(c.GL_ARRAY_BUFFER, id);
}

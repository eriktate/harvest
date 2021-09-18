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

pub fn vertexAttribPointer(location: u32, size: i32, stride: u32, offset: u32) void {
    c.glVertexAttribPointer(location, size, c.GL_FLOAT, c.GL_FALSE, @intCast(c_int, stride), &@intCast(c_int, offset));
}

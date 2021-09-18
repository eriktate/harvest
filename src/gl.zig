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

// TODO: (etate) make this work for more than just floats
pub fn vertexAttribPointer(location: u32, size: i32, stride: i32, offset: usize) void {
    c.glVertexAttribPointer(location, size, c.GL_FLOAT, c.GL_FALSE, stride, @intToPtr(?*const c_void, offset));
    c.glEnableVertexAttribArray(location);
}

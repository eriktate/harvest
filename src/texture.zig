const c = @import("c.zig");
const gl = @import("gl.zig");

const TexError = error{
    NotPng,
    NoData,
};

const Texture = @This();
id: u32,
width: u16,
height: u16,
nr_channels: i32,

pub fn fromMemory(buffer: []const u8) TexError!Texture {
    var width: i32 = undefined;
    var height: i32 = undefined;
    var nr_channels: i32 = undefined;

    if (c.stbi_info_from_memory(buffer.ptr, @intCast(c_int, buffer.len), &width, &height, null) == 0) {
        return error.NotPng;
    }

    const data = c.stbi_load_from_memory(buffer.ptr, @intCast(c_int, buffer.len), &width, &height, &nr_channels, 0);
    defer c.stbi_image_free(data);

    if (data == null) {
        return error.NoData;
    }

    const id = gl.genTexture();
    gl.bindTexture(gl.TexTarget.Texture2D, id);
    gl.texImage2D(gl.TexTarget.Texture2D, width, height, data);
    gl.texFilter(gl.TexTarget.Texture2D, gl.TexFilter.MagFilter, gl.FilterParam.Nearest);
    gl.texFilter(gl.TexTarget.Texture2D, gl.TexFilter.MinFilter, gl.FilterParam.Nearest);
    gl.generateMipmap(gl.TexTarget.Texture2D);

    return Texture{
        .id = id,
        .width = @intCast(u16, width),
        .height = @intCast(u16, height),
        .nr_channels = nr_channels,
    };
}

pub fn bind(self: *Texture) void {
    gl.bindTexture(gl.TexTarget.Texture2D, self.id);
}

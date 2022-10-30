const std = @import("std");
const gl = @import("gl.zig");

const ShaderError = error{
    VertexCompilation,
    FragmentCompilation,
    Linking,
};

const Shader = @This();
id: u32,

fn logError(log: []u8) void {
    std.debug.print("Shader Log: {s}", .{log});
}

pub fn init(vert_src: []const u8, frag_src: []const u8) ShaderError!Shader {
    var log: [1024]u8 = undefined;
    errdefer logError(&log);

    var vert = gl.createShader(gl.ShaderType.Vertex);
    gl.shaderSource(vert, vert_src);
    gl.compileShader(vert, &log) catch return ShaderError.VertexCompilation;

    var frag = gl.createShader(gl.ShaderType.Fragment);
    gl.shaderSource(frag, frag_src);
    gl.compileShader(frag, &log) catch return ShaderError.FragmentCompilation;

    var program = gl.createProgram();
    gl.attachShader(program, vert);
    gl.attachShader(program, frag);
    gl.linkProgram(program, &log) catch return ShaderError.Linking;

    // shaders are linked to the program now, don't need to keep them
    gl.deleteShader(vert);
    gl.deleteShader(frag);

    return Shader{ .id = program };
}

pub fn use(self: Shader) void {
    gl.useProgram(self.id);
}

// TODO (etate): could probably use comptime to make a setUniform() function that uses the right gl calls
// for the type specified
pub fn setInt(self: Shader, name: [*]const u8, val: i32) void {
    self.use();
    gl.uniformInt(self.id, name, val);
}

pub fn setUint(self: Shader, name: [*]const u8, val: u32) void {
    self.use();
    gl.uniformUint(self.id, name, val);
}

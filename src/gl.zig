// This file does not always represent a 1:1 mapping to openGL
// functions. Where it makes sense, new functions are added,
// or signatures changed, to make them more ergonomic to work
// with

const std = @import("std");
const c = @import("c.zig");
const math = @import("math.zig");

pub const GlError = error{
    ShaderCompilation,
    ShaderLinking,
};

pub const ClearMask = c.GLbitfield;

pub const COLOR_BUFFER_BIT: ClearMask = c.GL_COLOR_BUFFER_BIT;
pub const DEPTH_BUFFER_BIT: ClearMask = c.GL_DEPTH_BUFFER_BIT;
pub const STENCIL_BUFFER_BIT: ClearMask = c.GL_STENCIL_BUFFER_BIT;

pub const BufferTarget = enum(c_uint) {
    Array = c.GL_ARRAY_BUFFER,
    Element = c.GL_ELEMENT_ARRAY_BUFFER,
};

pub const BufferUsage = enum(c_uint) {
    DynamicDraw = c.GL_DYNAMIC_DRAW,
    StaticDraw = c.GL_STATIC_DRAW,
};

pub const DataType = enum(c_uint) {
    Float = c.GL_FLOAT,
    Uint = c.GL_UNSIGNED_INT,
    Ushort = c.GL_UNSIGNED_SHORT,
};

pub const Capability = enum(c_uint) {
    Blend = c.GL_BLEND,
};

pub const SFactor = enum(c_uint) {
    SrcAlpha = c.GL_SRC_ALPHA,
};

pub const DFactor = enum(c_uint) {
    OneMinusSrcAlpha = c.GL_ONE_MINUS_SRC_ALPHA,
};

pub const ShaderType = enum(c_uint) {
    Vertex = c.GL_VERTEX_SHADER,
    Fragment = c.GL_FRAGMENT_SHADER,
};

pub const DrawMode = enum(c_uint) {
    Points = c.GL_POINTS,
    LineStrip = c.GL_LINE_STRIP,
    LineLoop = c.GL_LINE_LOOP,
    Lines = c.GL_LINES,
    TriangleStrip = c.GL_TRIANGLE_STRIP,
    TriangleFan = c.GL_TRIANGLE_FAN,
    Triangles = c.GL_TRIANGLES,
};

// TODO (etate): explore if there's a way to make Handles more
// type safe. e.g. different handles for different types
pub const Handle = u32;

pub fn genVAO() Handle {
    var vao: Handle = 0;
    c.glGenVertexArrays(1, &vao);
    return vao;
}

pub fn bindVAO(vao: Handle) void {
    c.glBindVertexArray(vao);
}

pub fn genBuffer() Handle {
    var handle: Handle = 0;
    c.glGenBuffers(1, &handle);
    return handle;
}

pub fn bindBuffer(target: BufferTarget, handle: Handle) void {
    c.glBindBuffer(@enumToInt(target), handle);
}

pub fn bufferData(comptime T: type, target: BufferTarget, data: []const T, usage: BufferUsage) void {
    c.glBufferData(@enumToInt(target), @intCast(c_long, @sizeOf(T) * data.len), data.ptr, @enumToInt(usage));
}

pub fn vertexAttribPointer(idx: u32, size: u32, data_type: DataType, normalized: bool, stride: u32, offset: ?usize) void {
    if (offset) |off| {
        c.glVertexAttribPointer(idx, @intCast(c_int, size), @enumToInt(data_type), @boolToInt(normalized), @intCast(c_int, stride), @intToPtr(*const anyopaque, off));
    } else {
        c.glVertexAttribPointer(idx, @intCast(c_int, size), @enumToInt(data_type), @boolToInt(normalized), @intCast(c_int, stride), null);
    }

    c.glEnableVertexAttribArray(idx);
}

pub fn viewport(x: u16, y: u16, width: u16, height: u16) void {
    c.glViewport(x, y, width, height);
}

pub fn clearColor(r: f32, g: f32, b: f32, a: f32) void {
    c.glClearColor(r, g, b, a);
}

pub fn clear(mask: ClearMask) void {
    c.glClear(mask);
}

pub fn enable(cap: Capability) void {
    c.glEnable(@enumToInt(cap));
}

pub fn blendFunc(sfactor: SFactor, dfactor: DFactor) void {
    c.glBlendFunc(@enumToInt(sfactor), @enumToInt(dfactor));
}

pub fn createShader(shader_type: ShaderType) Handle {
    return c.glCreateShader(@enumToInt(shader_type));
}

// TODO (etate): technically glShaderSource accepts an array
// of strings, maybe this should do the same?
pub fn shaderSource(shader: Handle, src: []const u8) void {
    c.glShaderSource(shader, 1, @ptrCast([*c]const [*c]const u8, &src), null);
}

pub fn compileShader(shader: Handle, out: []u8) GlError!void {
    var success: i32 = 0;
    var length: i32 = 0;
    c.glCompileShader(shader);
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);

    if (success != 1) {
        c.glGetShaderInfoLog(shader, @intCast(c_int, out.len), &length, @ptrCast([*c]u8, out.ptr));
        return GlError.ShaderCompilation;
    }
}

pub fn createProgram() Handle {
    return c.glCreateProgram();
}

pub fn attachShader(program: Handle, shader: Handle) void {
    c.glAttachShader(program, shader);
}

pub fn linkProgram(program: Handle, out: []u8) GlError!void {
    var success: i32 = 0;
    var length: i32 = 0;

    c.glLinkProgram(program);
    c.glGetProgramiv(program, c.GL_LINK_STATUS, &success);

    if (success != 1) {
        c.glGetProgramInfoLog(program, @intCast(c_int, out.len), &length, @ptrCast([*c]u8, out.ptr));
        return GlError.ShaderLinking;
    }
}

pub fn deleteShader(shader: Handle) void {
    c.glDeleteShader(shader);
}

pub fn useProgram(program: Handle) void {
    c.glUseProgram(program);
}

pub fn uniformInt(program: Handle, name: [*]const u8, val: i32) void {
    c.glUniform1i(c.glGetUniformLocation(program, name), val);
}

pub fn uniformUint(program: Handle, name: [*]const u8, val: u32) void {
    c.glUniform1ui(c.glGetUniformLocation(program, name), val);
}

pub fn uniformMat4(program: Handle, name: [*]const u8, val: math.Mat4(f32)) void {
    c.glUniformMatrix4fv(c.glGetUniformLocation(program, name), 1, c.GL_FALSE, &val.data);
}

pub fn drawElements(mode: DrawMode, count: usize) void {
    c.glDrawElements(@enumToInt(mode), @intCast(c_int, count), c.GL_UNSIGNED_INT, null);
}

pub fn drawArrays(mode: DrawMode, count: usize) void {
    c.glDrawArrays(@enumToInt(mode), 0, @intCast(c_int, count));
}

pub fn genTexture() Handle {
    var tex_id: Handle = 0;
    c.glGenTextures(1, &tex_id);
    return tex_id;
}

pub const TexTarget = enum(c_uint) {
    Texture2D = c.GL_TEXTURE_2D,
};

pub fn bindTexture(target: TexTarget, tex_id: Handle) void {
    c.glBindTexture(@enumToInt(target), tex_id);
}

pub fn texImage2D(target: TexTarget, width: i32, height: i32, data: [*c]u8) void {
    c.glTexImage2D(@enumToInt(target), 0, c.GL_RGBA, @intCast(c_int, width), @intCast(c_int, height), 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, data);
}

pub const TexFilter = enum(c_uint) {
    MagFilter = c.GL_TEXTURE_MAG_FILTER,
    MinFilter = c.GL_TEXTURE_MIN_FILTER,
};

pub const FilterParam = enum(c_int) {
    Nearest = c.GL_NEAREST,
    Linear = c.GL_LINEAR,
    NearestMipmapNearest = c.GL_NEAREST_MIPMAP_NEAREST,
    LinearMipmapNearest = c.GL_LINEAR_MIPMAP_NEAREST,
    NearestMipmapLinear = c.GL_NEAREST_MIPMAP_LINEAR,
    LinearMipmapLinear = c.GL_LINEAR_MIPMAP_LINEAR,
};

pub fn texFilter(target: TexTarget, filter: TexFilter, param: FilterParam) void {
    c.glTexParameteri(@enumToInt(target), @enumToInt(filter), @enumToInt(param));
}

pub fn generateMipmap(target: TexTarget) void {
    c.glGenerateMipmap(@enumToInt(target));
}

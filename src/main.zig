const std = @import("std");
const gl = @import("gl.zig");
const render = @import("render.zig");
const math = @import("math.zig");

const Window = @import("window.zig");
const QuadRenderer = @import("quad_renderer.zig");
const Shader = @import("shader.zig");
const Texture = @import("texture.zig");
const Sprite = @import("sprite.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...", .{});
    const width = 360;
    const height = 180;

    var win = try Window.init(width, height, "harvest - float");
    defer win.close();

    const knight_raw = @embedFile("../assets/sprites/knight.png");
    _ = try Texture.fromMemory(knight_raw);

    const knight_spr = Sprite.init(math.Vec3(f32).init(180.0, 90.0, 0.0), math.Vec2(u16).init(0, 0), 16, 16);
    var quads = [1]render.Quad{knight_spr.toQuad()};
    var indices: [6]u32 = undefined;

    const quad_renderer = try QuadRenderer.init(width, height, &quads, &indices);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    // shader.use();
    while (!win.shouldClose()) {
        gl.clearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        quad_renderer.draw();
        win.swap();
        gl.bindVAO(0);
    }
}

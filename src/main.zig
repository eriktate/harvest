const std = @import("std");
const gl = @import("gl.zig");
const render = @import("render.zig");
const math = @import("math.zig");

const Window = @import("window.zig");
const QuadRenderer = @import("quad_renderer.zig");
const Shader = @import("shader.zig");
const Texture = @import("texture.zig");
const Atlas = @import("atlas.zig");
const Entity = @import("entity.zig");
const Sprite = @import("sprite.zig");
const Manager = @import("manager.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...", .{});
    // var buf: [1024 * 1024 * 512]u8 = undefined; // 512mb
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var mgr = try Manager.init(allocator, 1000);
    const width = 360;
    const height = 180;

    var win = try Window.init(width, height, "harvest - float");
    defer win.close();

    const knight_raw = @embedFile("../assets/sprites/knight.png");
    const tex = try Texture.fromMemory(knight_raw);
    const atlas = Atlas.init(tex.width, tex.height, 16, 16, math.Vec2(u16).init(4, 4), null);
    const frame = try atlas.index(0);
    const knight_spr = Sprite.init(math.Vec3(f32).init(180.0, 90.0, 0.0), frame.tl, 16, 16);
    const knight_id = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(180.0, 90.0, 0.0),
    }, knight_spr, null);

    var quad_renderer = try QuadRenderer.init(allocator, width, height, 1000, mgr.genQuads(), tex);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    // shader.use();
    while (!win.shouldClose()) {
        try mgr.move(knight_id, math.Vec3(f32).init(0.5, 0.0, 0.0));
        gl.clearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        quad_renderer.draw(mgr.genQuads());
        win.swap();
        gl.bindVAO(0);
    }
}

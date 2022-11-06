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
const Animation = @import("animation.zig");
const Controller = @import("controller.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...\n", .{});

    // TODO (etate): use a FixedBufferAllocator instead of the page_allocator?
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var mgr = try Manager.init(alloc, 1000);
    const width = 360;
    const height = 180;

    var win = try Window.init(width, height, "harvest - float");
    defer win.close();

    var controller = try Controller.init();
    const knight_raw = @embedFile("../assets/sprites/knight.png");
    const tex = try Texture.fromMemory(knight_raw);

    const atlas = Atlas.init(tex.width, tex.height, 16, 16, math.Vec2(u16).init(4, 4), null);
    const animation_frames = [_]Atlas.Frame{ try atlas.index(0), try atlas.index(1) };
    var anim = Animation.init(&animation_frames, 5);

    const knight_spr = Sprite.init(math.Vec3(f32).init(0.0, 0.0, 0.0), Sprite.animation(anim), 16, 16);
    const knight_id = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(0.0, 0.0, 0.0),
    }, knight_spr, null);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(64, 64, 0.0),
    }, knight_spr, null);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(40, 80, 0.0),
    }, knight_spr, null);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(300, 112, 0.0),
    }, knight_spr, null);
    std.debug.print("knight: {d}", .{knight_id});

    var quad_renderer = try QuadRenderer.init(alloc, width, height, 1000, mgr.genQuads(), tex);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    mgr.printSize();
    var delta: f64 = 0;
    while (!win.shouldClose()) {
        delta = win.getDelta();
        controller.tick();
        mgr.tick(delta);
        try mgr.move(knight_id, controller.moveVec().scale(0.5));
        gl.clearColor(100.0 / 255.0, 149.0 / 255.0, 237.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        quad_renderer.draw(mgr.genQuads());
        win.swap();
        gl.bindVAO(0);
    }
}

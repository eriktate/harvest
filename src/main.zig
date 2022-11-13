const std = @import("std");
const gl = @import("gl.zig");
const render = @import("render.zig");
const math = @import("math.zig");

const Window = @import("window.zig");
const Camera = @import("camera.zig");
const QuadRenderer = @import("quad_renderer.zig");
const Shader = @import("shader.zig");
const Texture = @import("texture.zig");
const Atlas = @import("atlas.zig");
const Entity = @import("entity.zig");
const Sprite = @import("sprite.zig");
const Manager = @import("manager.zig");
const Animation = @import("animation.zig");
const Controller = @import("controller.zig");
const Box = @import("box.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting harvest...\n", .{});

    // TODO (etate): use a FixedBufferAllocator instead of the page_allocator?
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var mgr = try Manager.init(alloc, 1000);
    defer mgr.deinit();

    const width = 360 * 4;
    const height = 180 * 4;

    var win = try Window.init(width, height, "harvest - float");
    defer win.close();

    var controller = try Controller.init();
    const knight_raw = @embedFile("../assets/sprites/knight.png");
    const tex = try Texture.fromMemory(knight_raw);

    const atlas = Atlas.init(tex.width, tex.height, 16, 16, math.Vec2(u16).init(4, 4), null);
    const animation_frames = [_]Atlas.Frame{ try atlas.index(0), try atlas.index(1) };
    var anim = Animation.init(&animation_frames, 2);

    const knight_spr = Sprite.init(math.Vec3(f32).init(0.0, 0.0, 0.0), Sprite.animation(anim), 16, 16);
    const knight_box = Box.init(math.Vec3(f32).zero(), 8, 16, true);
    const knight_id = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(0.0, 0.0, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, knight_spr, knight_box);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(64, 64, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, knight_spr, knight_box);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(40, 80, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, knight_spr, knight_box);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(300, 112, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, knight_spr, knight_box);

    var camera = Camera.init(&win, math.Vec3(f32).zero(), math.Vec2(f32).init(16, 16), width / 2, height / 2);

    var quad_renderer = try QuadRenderer.init(alloc, width, height, 1000, mgr.genQuads(), tex);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    mgr.printSize();
    var delta: f64 = 0;
    // var knight = try mgr.get(Entity, knight_id);
    while (!win.shouldClose()) {
        delta = win.getDelta();
        controller.tick();
        mgr.tick(delta);
        const knight_pos = try mgr.move(knight_id, controller.moveVec().scale(0.5));

        // track player with camera
        camera.trackTarget(knight_pos.add(math.Vec3(f32).from_vec2(controller.right_stick).scale(64)));
        quad_renderer.shader.setMat4("projection", camera.projection());

        gl.clearColor(165.0 / 255.0, 140.0 / 255.0, 39.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        quad_renderer.draw(mgr.genQuads());
        win.swap();
        gl.bindVAO(0);
    }
}

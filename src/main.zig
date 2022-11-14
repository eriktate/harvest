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
const Debug = @import("debug_renderer.zig");

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

    var debug = try Debug.init(alloc, 1000, width, height);

    var controller = try Controller.init();
    const sprites_raw = @embedFile("../assets/sprites/sprite_atlas.png");
    const tex = try Texture.fromMemory(sprites_raw);

    const npc_atlas = Atlas.init(tex.width, tex.height, 16, 16, math.TexPos.init(4, 4), math.TexPos.init(24, 4));
    const npc_frames = [_]Atlas.Frame{ try npc_atlas.index(0), try npc_atlas.index(1) };
    var npc_anim = Animation.init(&npc_frames, 2);
    const npc_spr = Sprite.init(math.Pos.init(0.0, 0.0, 0.0), Sprite.animation(npc_anim), 16, 16);

    // walls
    const wall_atlas = Atlas.init(tex.width, tex.height, 16, 32, math.TexPos.init(4, 4), null);
    const wall_spr = Sprite.init(math.Pos.zero(), Sprite.static(try wall_atlas.index(0)), 16, 32);
    _ = try mgr.addEntity(.{
        .pos = math.Pos.init(128, 128, 0),
        .box_offset = math.Pos.init(0, 16, 0),
    }, wall_spr, Box.init(math.Pos.zero(), 16, 16, true));
    _ = try mgr.addEntity(.{
        .pos = math.Pos.init(144, 128, 0),
        .box_offset = math.Pos.init(0, 16, 0),
    }, wall_spr, Box.init(math.Pos.zero(), 16, 16, true));
    _ = try mgr.addEntity(.{
        .pos = math.Pos.init(160, 128, 0),
        .box_offset = math.Pos.init(0, 16, 0),
    }, wall_spr, Box.init(math.Pos.zero(), 16, 16, true));

    // player and NPCs
    const player_atlas = Atlas.init(tex.width, tex.height, 24, 24, null, math.TexPos.init(72, 4));
    const player_spr = Sprite.init(math.Pos.zero(), Sprite.static(try player_atlas.index(0)), 24, 24);

    const npc_box = Box.init(math.Pos.zero(), 8, 13, true);
    const player_box = Box.init(math.Pos.zero(), 6, 5, true);

    const player_id = try mgr.addEntity(.{
        .pos = math.Pos.init(0.0, 0.0, 0.0),
        .box_offset = math.Pos.init(9, 19, 0),
    }, player_spr, player_box);
    _ = try mgr.addEntity(.{
        .pos = math.Pos.init(64, 64, 0.0),
        .box_offset = math.Pos.init(4, 3, 0),
    }, npc_spr, npc_box);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(40, 80, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, npc_spr, npc_box);
    _ = try mgr.addEntity(.{
        .pos = math.Vec3(f32).init(300, 112, 0.0),
        .box_offset = math.Vec3(f32).init(4, 3, 0),
    }, npc_spr, npc_box);

    var camera = Camera.init(&win, math.Vec3(f32).zero(), math.Vec2(f32).init(16, 16), width / 2, height / 2);

    var quad_renderer = try QuadRenderer.init(alloc, width, height, 1000, mgr.genQuads(), tex);

    gl.enable(gl.Capability.Blend);
    gl.blendFunc(gl.SFactor.SrcAlpha, gl.DFactor.OneMinusSrcAlpha);

    mgr.printSize();
    var delta: f64 = 0;
    debug.toggle();
    // var knight = try mgr.get(Entity, knight_id);
    while (!win.shouldClose()) {
        delta = win.getDelta();
        controller.tick();
        if (controller.button_select) {
            debug.toggle();
        }
        mgr.tick(delta);
        const player_pos = try mgr.move(player_id, controller.moveVec().scale(0.5));

        // track player with camera
        camera.trackTarget(player_pos.add(math.Vec3(f32).from_vec2(controller.right_stick).scale(64)));
        quad_renderer.shader.setMat4("projection", camera.projection());

        try mgr.drawDebug(&debug);
        debug.shader.setMat4("projection", camera.projection());

        gl.clearColor(165.0 / 255.0, 140.0 / 255.0, 39.0 / 255.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        quad_renderer.draw(mgr.genQuads());
        debug.draw();
        win.swap();
        gl.bindVAO(0);
    }
}

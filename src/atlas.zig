const math = @import("math.zig");

pub const AtlasError = error{
    OutOfBounds,
};

const TexPos = math.Vec2(u32);
pub const Frame = struct {
    tl: TexPos,
    br: TexPos,
};

// TODO (etate): add offset and assume that width and height is relative to offset, which will allow
// multiple atlases of different sizes to exist in the same texture
const Atlas = @This();
width: u32,
height: u32,
frame_width: u32,
frame_height: u32,
gap: TexPos,

pub fn init(width: u32, height: u32, frame_width: u32, frame_height: u32, gap: ?TexPos) Atlas {
    return Atlas{
        .width = width,
        .height = height,
        .frame_width = frame_width,
        .frame_height = frame_height,
        .gap = gap orelse TexPos.zero(),
    };
}

// number of rows in Atlas
fn rows(self: Atlas) u32 {
    return (self.height - self.gap.y) / (self.frame_height + self.gap.y);
}

fn cols(self: Atlas) u32 {
    return (self.width - self.gap.x) / (self.frame_width + self.gap.x);
}

pub fn getFrame(self: Atlas, row: u32, col: u32) !Frame {
    if (row >= self.rows() or col >= self.cols()) {
        return AtlasError.OutOfBounds;
    }

    const tl = TexPos.init(
        col * (self.frame_width + self.gap.x) + self.gap.x,
        row * (self.frame_height + self.gap.y) + self.gap.y,
    );

    return Frame{
        .tl = tl,
        .br = tl.add(TexPos.init(self.frame_width, self.frame_height)),
    };
}

pub fn index(self: Atlas, idx: u32) !Frame {
    const row = self.rows() / idx;
    const col = self.rows() % idx;

    return self.getFrame(row, col);
}

test "get frames with no gaps" {
    const std = @import("std");
    const testing = std.testing;
    const assert = std.debug.assert;

    const atlas = Atlas.init(128, 128, 16, 16, null);

    const firstFrame = try atlas.getFrame(0, 0);
    const thirdFrame = try atlas.getFrame(0, 2);
    const thirdRowFirstFrame = try atlas.getFrame(2, 0);
    const thirdRowThirdFrame = try atlas.getFrame(2, 2);
    const lastFrame = try atlas.getFrame(7, 7);

    assert(firstFrame.tl.eq(TexPos.init(0, 0)));
    assert(firstFrame.br.eq(TexPos.init(16, 16)));

    assert(thirdFrame.tl.eq(TexPos.init(32, 0)));
    assert(thirdFrame.br.eq(TexPos.init(48, 16)));

    assert(thirdRowFirstFrame.tl.eq(TexPos.init(0, 32)));
    assert(thirdRowFirstFrame.br.eq(TexPos.init(16, 48)));

    assert(thirdRowThirdFrame.tl.eq(TexPos.init(32, 32)));
    assert(thirdRowThirdFrame.br.eq(TexPos.init(48, 48)));

    assert(lastFrame.tl.eq(TexPos.init(112, 112)));
    assert(lastFrame.br.eq(TexPos.init(128, 128)));

    try testing.expectError(AtlasError.OutOfBounds, atlas.getFrame(8, 8));
}

test "get frames with gaps" {
    const std = @import("std");
    const testing = std.testing;
    const assert = std.debug.assert;

    const atlas = Atlas.init(164, 164, 16, 16, TexPos.init(4, 4));

    const firstFrame = try atlas.getFrame(0, 0);
    const thirdFrame = try atlas.getFrame(0, 2);
    const thirdRowFirstFrame = try atlas.getFrame(2, 0);
    const thirdRowThirdFrame = try atlas.getFrame(2, 2);
    const lastFrame = try atlas.getFrame(7, 7);

    assert(firstFrame.tl.eq(TexPos.init(4, 4)));
    assert(firstFrame.br.eq(TexPos.init(20, 20)));

    // std.debug.print("{}", .{thirdFrame.tl});
    assert(thirdFrame.tl.eq(TexPos.init(44, 4)));
    assert(thirdFrame.br.eq(TexPos.init(60, 20)));

    assert(thirdRowFirstFrame.tl.eq(TexPos.init(4, 44)));
    assert(thirdRowFirstFrame.br.eq(TexPos.init(20, 60)));

    assert(thirdRowThirdFrame.tl.eq(TexPos.init(44, 44)));
    assert(thirdRowThirdFrame.br.eq(TexPos.init(60, 60)));

    assert(lastFrame.tl.eq(TexPos.init(144, 144)));
    assert(lastFrame.br.eq(TexPos.init(160, 160)));

    try testing.expectError(AtlasError.OutOfBounds, atlas.getFrame(8, 8));
}

test "get frames by index" {}
test "get frame with offset" {}

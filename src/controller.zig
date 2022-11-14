const std = @import("std");
const c = @import("c.zig");
const math = @import("math.zig");

const possible_gamepads = [_]c_int{
    c.GLFW_JOYSTICK_1,
    c.GLFW_JOYSTICK_2,
    c.GLFW_JOYSTICK_3,
    c.GLFW_JOYSTICK_4,
    c.GLFW_JOYSTICK_5,
    c.GLFW_JOYSTICK_6,
    c.GLFW_JOYSTICK_7,
    c.GLFW_JOYSTICK_8,
    c.GLFW_JOYSTICK_9,
    c.GLFW_JOYSTICK_10,
    c.GLFW_JOYSTICK_11,
    c.GLFW_JOYSTICK_12,
    c.GLFW_JOYSTICK_13,
    c.GLFW_JOYSTICK_14,
    c.GLFW_JOYSTICK_15,
    c.GLFW_JOYSTICK_16,
};

// this is how my controller shows up, so I need to specifically load it for local dev
const dev_controller_mapping = "06000000d62000000340000003010000,Microsoft X-Box One pad,platform:Linux,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,";

pub const ControllerError = error{
    ControllerNotFound,
};

const Controller = @This();
gamepad_id: i32,
left_stick: math.Vec2(f32) = math.Vec2(f32).zero(),
right_stick: math.Vec2(f32) = math.Vec2(f32).zero(),
button_a: bool = false,
button_b: bool = false,
button_x: bool = false,
button_y: bool = false,
button_select: bool = false,

pub fn init() !Controller {
    const id = findGamepad();
    if (id == null) {
        return ControllerError.ControllerNotFound;
    }

    return Controller{
        .gamepad_id = id.?,
    };
}

pub fn tick(self: *Controller) void {
    var state: c.GLFWgamepadstate = undefined;
    if (c.glfwGetGamepadState(self.gamepad_id, &state) != 1) {
        std.debug.print("failed to get gamepad state\n", .{});
    }
    self.left_stick = math.Vec2(f32).init(
        state.axes[c.GLFW_GAMEPAD_AXIS_LEFT_X],
        state.axes[c.GLFW_GAMEPAD_AXIS_LEFT_Y],
    );

    self.right_stick = math.Vec2(f32).init(
        state.axes[c.GLFW_GAMEPAD_AXIS_RIGHT_X],
        state.axes[c.GLFW_GAMEPAD_AXIS_RIGHT_Y],
    );

    self.button_a = state.buttons[c.GLFW_GAMEPAD_BUTTON_A] == c.GLFW_PRESS;
    self.button_b = state.buttons[c.GLFW_GAMEPAD_BUTTON_B] == c.GLFW_PRESS;
    self.button_x = state.buttons[c.GLFW_GAMEPAD_BUTTON_X] == c.GLFW_PRESS;
    self.button_y = state.buttons[c.GLFW_GAMEPAD_BUTTON_Y] == c.GLFW_PRESS;
    self.button_select = state.buttons[c.GLFW_GAMEPAD_BUTTON_BACK] == c.GLFW_PRESS;
}

fn findGamepad() ?i32 {
    // if (c.glfwUpdateGamepadMappings(@ptrCast([*c]const u8, dev_controller_mapping)) != 1) {
    if (c.glfwUpdateGamepadMappings(dev_controller_mapping) != 1) {
        std.debug.print("failed to update mappings\n", .{});
        return null;
    }

    for (possible_gamepads) |gamepad| {
        if (c.glfwJoystickIsGamepad(gamepad) == 1) {
            return gamepad;
        }
    }

    return null;
}

// returns the unit vector representing the left stick with
// deadzone applied
pub fn moveVec(self: Controller) math.Vec3(f32) {
    var vec = math.Vec3(f32).init(self.left_stick.x, self.left_stick.y, 0);

    if (@fabs(vec.x) < 0.3) {
        vec.x = 0;
    }

    if (@fabs(vec.y) < 0.3) {
        vec.y = 0;
    }

    if (vec.x == 0 and vec.y == 0) {
        return vec;
    }

    return vec.unit();
}

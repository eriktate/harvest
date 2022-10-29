const std = @import("std");

pub fn VecBase(comptime T: type, comptime cardinality: u8, comptime Self: type) type {
    return struct {
        // setting up for SIMD
        const Arr = [cardinality]T;
        const Simd = std.meta.Vector(cardinality, T);

        pub inline fn asArray(self: Self) Arr {
            return @bitCast(Arr, self);
        }

        pub inline fn fromArray(arr: Arr) Self {
            return @bitCast(Self, arr);
        }

        pub inline fn asSimd(self: Self) Simd {
            return @as(Simd, @bitCast(Arr, self));
        }

        pub inline fn fromSimd(v: Simd) Self {
            return @bitCast(Self, @as(Arr, v));
        }

        // begin vec methods
        pub fn add(self: Self, other: Self) Self {
            return fromSimd(self.asSimd() + other.asSimd());
        }

        pub fn sub(self: Self, other: Self) Self {
            return fromSimd(self.asSimd() - other.asSimd());
        }

        pub fn scale(self: Self, scalar: T) Self {
            return fromSimd(self.asSimd() * @splat(cardinality, scalar));
        }

        pub fn mag(self: Self) T {
            return @sqrt(@reduce(.Add, self.asSimd() * self.asSimd()));
        }

        pub fn unit(self: Self) Self {
            return self.scale(1 / self.mag());
        }

        pub fn eq(self: Self, other: Self) bool {
            return @reduce(.And, self.asSimd() == other.asSimd());
        }

        pub fn zero() Self {
            return fromArray([1]T{0} ** cardinality);
        }

        pub fn dot(self: Self, other: Self) T {
            return @sqrt(@reduce(.Add, self.asSimd() * other.asSimd()));
        }
    };
}

pub fn Vec2(comptime T: type) type {
    // we use extern because packed struct is still buggy, and regular struct field layout isn't
    // guaranteed
    return extern struct {
        x: T,
        y: T,

        const Self = @This();
        pub fn init(x: T, y: T) Self {
            return .{
                .x = x,
                .y = y,
            };
        }

        pub usingnamespace VecBase(T, 2, Self);
    };
}

pub fn Vec3(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        z: T,

        const Self = @This();
        pub fn init(x: T, y: T, z: T) Self {
            return .{
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub usingnamespace VecBase(T, 3, Self);
    };
}

pub fn Vec4(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        z: T,
        w: T,

        const Self = @This();
        pub fn init(x: T, y: T, z: T, w: T) Self {
            return .{
                .x = x,
                .y = y,
                .z = z,
                .w = w,
            };
        }

        pub usingnamespace VecBase(T, 4, Self);
    };
}

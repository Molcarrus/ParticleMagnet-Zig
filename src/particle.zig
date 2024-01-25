const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

pub fn rgb(r: u8, g: u8, b: u8) raylib.Color {
    return .{
        .r = r,
        .g = g,
        .b = b,
        .a = 255,
    };
}

pub fn rgba(r: u8, g: u8, b: u8, a: u8) raylib.Color {
    return .{
        .r = r,
        .g = g,
        .b = b,
        .a = a,
    };
}

pub fn initVec2(x: f32, y: f32) raylib.Vector2 {
    return .{
        .x = x,
        .y = y,
    };
}

pub const Particle = struct {
    const Self = @This();

    pos: raylib.Vector2 = undefined,
    vel: raylib.Vector2 = undefined,
    color: raylib.Color = undefined,

    fn get_dist(self: *Self, pos: raylib.Vector2) f32 {
        const dx: f32 = self.pos.x - pos.x;
        const dy: f32 = self.pos.y - pos.y;
        const sqrt: f32 = @as(f32, @sqrt((dx*dx)+(dy*dy)));
        return sqrt;
    }

    fn get_normal(self: *Self, otherPos: raylib.Vector2) raylib.Vector2 {
        var dist: f32 = self.get_dist(otherPos);
        if (dist == 0) dist = 1;
        const dx: f32 = self.pos.x - otherPos.x;
        const dy: f32 = self.pos.y - otherPos.y;
        const normal: raylib.Vector2 = initVec2(dx*(1/dist), dy*(1/dist));
        return normal;
    }

    pub fn init_with_dim(self: *Self, screenWidth: c_int, screenHeight: c_int) void {
        self.pos.x = @as(f32, @floatFromInt(raylib.GetRandomValue(0,  screenWidth)));
        self.pos.y = @as(f32, @floatFromInt(raylib.GetRandomValue(0, screenHeight)));
        self.vel.x = @as(f32, @divExact(@as(f32, @floatFromInt(raylib.GetRandomValue(-100, 100))), 100));
        self.vel.y = @as(f32, @divExact(@as(f32, @floatFromInt(raylib.GetRandomValue(-100, 100))), 100));
        self.color = rgba(0, 0, 0, 100);
    }

    pub fn init_with_fields(self: *Self, pos: raylib.Vector2, vel: raylib.Vector2, color: raylib.Color) void {
        self.pos = pos;
        self.vel = vel;
        self.color = color;
    }

    pub fn attract(self: *Self, posToAttract: raylib.Vector2) void {
        const dist: f32 = @max(self.get_dist(posToAttract), 0.5);
        const normal: raylib.Vector2 = self.get_normal(posToAttract);

        self.vel.x -= normal.x / dist;
        self.vel.y -= normal.y / dist;
    }

    pub fn doFriction(self: *Self, amount: f32) void {
        self.vel.x *= amount;
        self.vel.y *= amount;
    }

    pub fn move(self: *Self, screenWidth: u32, screenHeight: u32) void {
        self.pos.x += self.vel.x;
        self.pos.y += self.vel.y;

        if (self.pos.x < 0) {
            self.pos.x += @as(f32, @floatFromInt(screenWidth));
        } 
        if (self.pos.x >= @as(f32, @floatFromInt(screenWidth))) {
            self.pos.x -= @as(f32, @floatFromInt(screenWidth));
        }
        if (self.pos.y < 0) {
            self.pos.y += @as(f32, @floatFromInt(screenHeight));
        }
        if (self.pos.y >= @as(f32, @floatFromInt(screenHeight))) {
            self.pos.y -= @as(f32, @floatFromInt(screenHeight));
        }
    }

    pub fn drawPixel(self: *Self) void {
        raylib.DrawPixel(@as(c_int, @intFromFloat(self.pos.x)), @as(c_int, @intFromFloat(self.pos.y)), self.color);
    }
};
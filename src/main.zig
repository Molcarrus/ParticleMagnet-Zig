const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const particle = @import("particle.zig");
const Part = particle.Particle;
var Particle = particle.Particle{};

pub fn main() !void {
    const screenWidth: c_int = 800;
    const screenHeight: c_int = 800;

    raylib.SetRandomSeed(1);

    const particleCount: u32 = 100_000;

    var particles: [particleCount]Part = undefined;

    for (0..particleCount) |i| {
        particles[i].init_with_dim(screenWidth, screenHeight);
    }

    raylib.InitWindow(screenWidth, screenHeight, "Particle Toy");

    raylib.SetTargetFPS(60);

    while (!raylib.WindowShouldClose()) {
        const mousePos: raylib.Vector2 = particle.initVec2(@as(f32, @floatFromInt(raylib.GetMouseX())), @as(f32, @floatFromInt(raylib.GetMouseY())));
        for (0..particleCount) |i| {
            particles[i].attract(mousePos);
            particles[i].doFriction(0.99);
            particles[i].move(screenWidth, screenHeight);
        }

        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        raylib.ClearBackground(raylib.RAYWHITE);
        for (0..particleCount) |i| {
            particles[i].drawPixel();
        }
        raylib.DrawFPS(10, 10);
    }

    raylib.CloseWindow();
}
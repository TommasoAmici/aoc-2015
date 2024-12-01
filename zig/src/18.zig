const std = @import("std");

const Lights = [100][100]bool;

fn parse(input: []const u8) Lights {
    var lights: Lights = undefined;

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    var y: usize = 0;
    while (it_lines.next()) |line| : (y += 1) {
        for (line, 0..) |light, x| {
            lights[y][x] = light == '#';
        }
    }

    return lights;
}

fn printLights(lights: *const Lights) !void {
    const outw = std.io.getStdOut().writer();
    try outw.writeAll(&[_]u8{ 27, 91, 50, 74 });
    try outw.writeAll(&[_]u8{ 27, 91, 72 });
    var out: [5050]u8 = undefined;
    var i: usize = 0;
    for (lights) |row| {
        for (row) |lit| {
            out[i] = if (lit) 35 else 46;
            i += 1;
        }
        out[i] = 10;
        i += 1;
        if (i == 5050) {
            break;
        }
    }
    try outw.writeAll(&out);
}

fn animate(lights: *const Lights) Lights {
    const Dir = struct { x: i8, y: i8 };
    const directions: [8]Dir = [_]Dir{
        Dir{ .x = 0, .y = -1 },
        Dir{ .x = 1, .y = -1 },
        Dir{ .x = 1, .y = 0 },
        Dir{ .x = 1, .y = 1 },
        Dir{ .x = 0, .y = 1 },
        Dir{ .x = -1, .y = 1 },
        Dir{ .x = -1, .y = 0 },
        Dir{ .x = -1, .y = -1 },
    };

    var next: Lights = undefined;
    var y: i8 = 0;
    for (lights) |row| {
        var x: i8 = 0;
        for (row) |on| {
            var on_neighbors: u4 = 0;
            for (directions) |dir| {
                const dx: i8 = x + dir.x;
                const dy: i8 = y + dir.y;
                if (dx < 0 or dy < 0 or dx >= 100 or dy >= 100) {
                    continue;
                } else if (lights[@intCast(dy)][@intCast(dx)]) {
                    on_neighbors += 1;
                }
            }
            next[@intCast(y)][@intCast(x)] = on_neighbors == 3 or (on and on_neighbors == 2);
            x += 1;
        }
        y += 1;
    }
    return next;
}

fn part1(lights: *const Lights) !u64 {
    var _lights = lights.*;
    for (0..100) |_| {
        _lights = animate(&_lights);
    }
    var lit: u64 = 0;
    for (_lights) |row| {
        for (row) |l| {
            if (l) {
                lit += 1;
            }
        }
    }
    return lit;
}

fn part2(lights: *const Lights) !u64 {
    var _lights = lights.*;
    for (0..100) |_| {
        _lights = animate(&_lights);
        _lights[0][0] = true;
        _lights[0][99] = true;
        _lights[99][0] = true;
        _lights[99][99] = true;
        // uncomment for extra fun
        // try printLights(&_lights);
        // std.time.sleep(50_000_000);
    }
    var lit: u64 = 0;
    for (_lights) |row| {
        for (row) |l| {
            if (l) {
                lit += 1;
            }
        }
    }
    return lit;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/18.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    const lights = parse(input);

    const out1 = try part1(&lights);
    std.log.debug("part 1: {}", .{out1});

    const out2 = try part2(&lights);
    std.log.debug("part 2: {}", .{out2});
}

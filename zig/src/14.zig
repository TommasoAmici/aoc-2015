const std = @import("std");

const Reindeer = struct {
    name: []const u8,
    speed: i64,
    flying_time: i64,
    rest_time: i64,
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Reindeer) {
    const tokens_len = 15;
    const reindeers_len = 9;

    const name_idx = 0;
    const speed_idx = 3;
    const flying_time_idx = 6;
    const rest_time_idx = 13;

    var reindeers = try std.ArrayList(Reindeer).initCapacity(allocator, reindeers_len);

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    while (it_lines.next()) |line| {
        var it_tokens = std.mem.tokenizeAny(u8, line, " ");
        var tokens: [tokens_len][]const u8 = undefined;
        var t: usize = 0;
        while (it_tokens.next()) |token| : (t += 1) {
            tokens[t] = token;
        }
        const reindeer = Reindeer{
            .name = tokens[name_idx],
            .speed = try std.fmt.parseInt(i64, tokens[speed_idx], 10),
            .flying_time = try std.fmt.parseInt(i64, tokens[flying_time_idx], 10),
            .rest_time = try std.fmt.parseInt(i64, tokens[rest_time_idx], 10),
        };
        try reindeers.append(reindeer);
    }

    return reindeers;
}

fn part1(reindeers: *std.ArrayList(Reindeer), time: i64) i64 {
    var max_distance: i64 = 0;
    for (reindeers.items) |reindeer| {
        var r_max_distance: i64 = 0;
        var r_time = time;
        while (r_time > 0) {
            const flying_time = @min(r_time, reindeer.flying_time);
            r_max_distance += reindeer.speed * flying_time;
            r_time -= flying_time;
            r_time -= reindeer.rest_time;
        }
        max_distance = @max(max_distance, r_max_distance);
    }
    return max_distance;
}

fn part2(allocator: std.mem.Allocator, reindeers: *std.ArrayList(Reindeer), time: i64) !i64 {
    var points = try std.ArrayList(i64).initCapacity(allocator, reindeers.items.len);
    try points.appendNTimes(0, reindeers.items.len);

    var distance = try std.ArrayList(i64).initCapacity(allocator, reindeers.items.len);
    try distance.appendNTimes(0, reindeers.items.len);

    var flying = try std.ArrayList(i64).initCapacity(allocator, reindeers.items.len);
    try flying.appendNTimes(0, reindeers.items.len);

    var t = time;
    while (t > 0) : (t -= 1) {
        var max_distance: i64 = 0;
        for (reindeers.items, 0..) |r, i| {
            if (flying.items[i] >= 0) {
                distance.items[i] += r.speed;
                flying.items[i] += 1;
                if (flying.items[i] == r.flying_time) {
                    flying.items[i] = -r.rest_time;
                }
            } else {
                flying.items[i] += 1;
            }
            max_distance = @max(max_distance, distance.items[i]);
        }
        for (0..reindeers.items.len) |i| {
            if (distance.items[i] == max_distance) {
                points.items[i] += 1;
            }
        }
    }
    var max_points: i64 = 0;
    for (points.items) |p| {
        max_points = @max(max_points, p);
    }
    return max_points;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/14.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    var reindeers = try parse(allocator, input);
    defer reindeers.deinit();

    const out1 = part1(&reindeers, 2503);
    std.log.info("part 1: {d}", .{out1});

    const out2 = try part2(allocator, &reindeers, 2503);
    std.log.info("part 2: {d}", .{out2});
}

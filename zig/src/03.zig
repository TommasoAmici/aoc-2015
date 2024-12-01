const std = @import("std");

const allocator = std.heap.page_allocator;

fn part1(content: *const []u8) !void {
    const Point = struct { x: i32, y: i32 };

    var map = std.AutoHashMap(Point, bool).init(
        allocator,
    );
    defer map.deinit();

    var curr_x: i32 = 0;
    var curr_y: i32 = 0;
    try map.put(Point{ .x = curr_x, .y = curr_y }, true);

    for (content.*) |value| {
        switch (value) {
            '^' => curr_y -= 1,
            '>' => curr_x += 1,
            '<' => curr_x -= 1,
            'v' => curr_y += 1,
            else => continue,
        }
        try map.put(Point{ .x = curr_x, .y = curr_y }, true);
    }
    std.log.info("part 1: {d}", .{map.count()});
}

fn part2(content: *const []u8) !void {
    const Point = struct { x: i32, y: i32 };

    var map = std.AutoHashMap(Point, bool).init(
        allocator,
    );
    defer map.deinit();

    var at_least_one_present: u32 = 1;
    try map.put(Point{ .x = 0, .y = 0 }, true);

    var santa_curr_x: i32 = 0;
    var santa_curr_y: i32 = 0;
    var robo_curr_x: i32 = 0;
    var robo_curr_y: i32 = 0;

    for (content.*, 0..) |value, turn| {
        var dir_y: i32 = 0;
        var dir_x: i32 = 0;
        switch (value) {
            '^' => dir_y -= 1,
            '>' => dir_x += 1,
            '<' => dir_x -= 1,
            'v' => dir_y += 1,
            else => continue,
        }
        var exists: bool = undefined;
        if (turn % 2 == 0) {
            santa_curr_x += dir_x;
            santa_curr_y += dir_y;
            const prev = try map.fetchPut(Point{ .x = santa_curr_x, .y = santa_curr_y }, true);
            exists = prev != null and prev.?.value;
        } else {
            robo_curr_x += dir_x;
            robo_curr_y += dir_y;
            const prev = try map.fetchPut(Point{ .x = robo_curr_x, .y = robo_curr_y }, true);
            exists = prev != null and prev.?.value;
        }
        if (!exists) {
            at_least_one_present += 1;
        }
    }
    std.log.info("part 1: {d}", .{at_least_one_present});
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/03.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    try part1(&content);
    try part2(&content);
}

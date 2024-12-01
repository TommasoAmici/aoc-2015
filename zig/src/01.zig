const std = @import("std");

/// Returns the floor Santa is at at the end of the sequence
fn part1(content: *const []u8) void {
    var curr_floor: i64 = 0;
    for (content.*) |value| {
        if (value == '(') {
            curr_floor += 1;
        } else {
            curr_floor -= 1;
        }
    }
    std.log.info("part 1: {d}", .{curr_floor});
}

/// Returns the position of the character that causes Santa to first enter
/// the basement
fn part2(content: *const []u8) void {
    var curr_floor: i64 = 0;
    for (content.*, 1..) |value, index| {
        if (value == '(') {
            curr_floor += 1;
        } else {
            curr_floor -= 1;
        }
        if (curr_floor == -1) {
            std.log.info("part 2: {d}", .{index});
            break;
        }
    }
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/01.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    part1(&content);
    part2(&content);
}

const std = @import("std");

fn lookAndSay(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(u8) {
    var out = try std.ArrayList(u8).initCapacity(allocator, input.len);
    var p: usize = 0;
    var count: u8 = 0;
    while (p < input.len) {
        if (count == 0 or input[p] == input[p - 1]) {
            count += 1;
            p += 1;
        } else {
            try out.append('0' + count);
            try out.append(input[p - 1]);
            count = 0;
        }
    }
    // flush
    try out.append('0' + count);
    try out.append(input[p - 1]);
    return out;
}

test "lookAndSay_1" {
    const expected = "11";

    const actual = try lookAndSay(std.testing.allocator, "1");
    defer actual.deinit();

    try std.testing.expectEqualStrings(expected, actual.items);
}
test "lookAndSay_11" {
    const expected = "21";
    const actual = try lookAndSay(std.testing.allocator, "11");
    defer actual.deinit();
    try std.testing.expectEqualStrings(expected, actual.items);
}
test "lookAndSay_21" {
    const expected = "1211";
    const actual = try lookAndSay(std.testing.allocator, "21");
    defer actual.deinit();
    try std.testing.expectEqualStrings(expected, actual.items);
}
test "lookAndSay_1211" {
    const expected = "111221";
    const actual = try lookAndSay(std.testing.allocator, "1211");
    defer actual.deinit();
    try std.testing.expectEqualStrings(expected, actual.items);
}
test "lookAndSay_111221" {
    const expected = "312211";

    const actual = try lookAndSay(std.testing.allocator, "111221");
    defer actual.deinit();

    try std.testing.expectEqualStrings(expected, actual.items);
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    var out = std.ArrayList(u8).init(allocator);
    for (input) |ch| {
        try out.append(ch);
    }
    for (0..40) |_| {
        out = try lookAndSay(allocator, out.items);
    }
    return out.items.len;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    var out = std.ArrayList(u8).init(allocator);
    for (input) |ch| {
        try out.append(ch);
    }
    for (0..50) |_| {
        out = try lookAndSay(allocator, out.items);
    }
    return out.items.len;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = "1321131112";

    const results_part1 = try part1(allocator, input);
    std.log.info("part 1: {d}", .{results_part1});
    const results_part2 = try part2(allocator, input);
    std.log.info("part 2: {d}", .{results_part2});
}

const std = @import("std");

var CONTAINERS: [20]i64 = [_]i64{
    33,
    14,
    18,
    20,
    45,
    35,
    16,
    35,
    1,
    13,
    18,
    13,
    50,
    44,
    48,
    6,
    24,
    41,
    30,
    42,
};

fn find_containers_1(combinations: *u64, liters: i64, containers: []i64) void {
    for (containers, 0..) |container, container_idx| {
        const l = liters - container;
        if (l == 0) {
            combinations.* += 1;
        } else if (l > 0) {
            find_containers_1(combinations, l, containers[container_idx + 1 ..]);
        }
    }
}

fn part1(liters: i64) u64 {
    var combinations: u64 = 0;
    const containers: []i64 = CONTAINERS[0..];
    find_containers_1(&combinations, liters, containers);
    return combinations;
}

fn find_containers_2(combinations: *std.AutoHashMap(usize, u64), liters: i64, containers_used: u64, containers: []i64) !void {
    for (containers, 0..) |container, container_idx| {
        const l = liters - container;
        if (l == 0) {
            const v = combinations.get(containers_used) orelse 0;
            try combinations.put(containers_used, v + 1);
        } else if (l > 0) {
            try find_containers_2(combinations, l, containers_used + 1, containers[container_idx + 1 ..]);
        }
    }
}

fn part2(allocator: std.mem.Allocator, liters: i64) !u64 {
    var combinations = std.AutoHashMap(usize, u64).init(allocator);
    const containers: []i64 = CONTAINERS[0..];
    try find_containers_2(&combinations, liters, 1, containers);

    var it = combinations.keyIterator();
    var min_num_containers: u64 = 20;
    while (it.next()) |k| {
        min_num_containers = @min(min_num_containers, k.*);
    }
    return combinations.get(min_num_containers) orelse unreachable;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const out1 = part1(150);
    std.log.info("part 1: {d}", .{out1});

    const out2 = try part2(allocator, 150);
    std.log.info("part 2: {d}", .{out2});
}

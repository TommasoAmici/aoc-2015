const std = @import("std");

fn sumJson(json: *const std.json.Value) i64 {
    var tot: i64 = 0;
    switch (json.*) {
        .integer => |i| tot += i,
        .array => |i| {
            for (i.items) |value| {
                tot += sumJson(&value);
            }
        },
        .object => |i| {
            for (i.values()) |value| {
                tot += sumJson(&value);
            }
        },
        else => {},
    }
    return tot;
}

fn part1(json: *std.json.Parsed(std.json.Value)) i64 {
    return sumJson(&json.value);
}

fn sumJsonRed(json: *const std.json.Value) i64 {
    var tot: i64 = 0;
    switch (json.*) {
        .integer => |i| tot += i,
        .array => |i| {
            for (i.items) |value| {
                tot += sumJsonRed(&value);
            }
        },
        .object => |i| {
            var obj_tot: i64 = 0;
            var is_red = false;
            for (i.values()) |value| {
                obj_tot += sumJsonRed(&value);
                switch (value) {
                    .string => |s| {
                        if (std.mem.eql(u8, s, "red")) {
                            is_red = true;
                            break;
                        }
                    },
                    else => {},
                }
            }
            if (!is_red) {
                tot += obj_tot;
            }
        },
        else => {},
    }
    return tot;
}

fn part2(json: *std.json.Parsed(std.json.Value)) i64 {
    return sumJsonRed(&json.value);
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/12.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, input, .{});
    defer parsed.deinit();

    const out1 = part1(&parsed);
    std.log.info("part 1: {d}", .{out1});

    const out2 = part2(&parsed);
    std.log.info("part 2: {d}", .{out2});
}

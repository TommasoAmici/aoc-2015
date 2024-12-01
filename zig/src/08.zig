const std = @import("std");

fn part1(input: []const u8) struct { u64, u64 } {
    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    var tot_code: u64 = 0;
    var tot_memory: u64 = 0;
    while (it_lines.next()) |line| {
        tot_code += 2;
        var p: usize = 1;
        while (p < line.len - 1) : (p += 1) {
            if (line[p] == '\\') {
                tot_code += 2;
                tot_memory += 1;
                p += 1;
                if (line[p] == 'x') {
                    tot_code += 2;
                    p += 2;
                }
            } else {
                tot_code += 1;
                tot_memory += 1;
            }
        }
    }
    return .{ tot_code, tot_memory };
}

test "part1" {
    const s =
        \\"\x27"
    ;
    const out = part1(s);
    try std.testing.expectEqual(6, out[0]);
    try std.testing.expectEqual(1, out[1]);
}

fn part2(input: []const u8) u64 {
    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    var tot_code: u64 = 0;
    while (it_lines.next()) |line| {
        tot_code += 6;
        var p: usize = 1;
        while (p < line.len - 1) : (p += 1) {
            if (line[p] == '\\') {
                if (line[p + 1] == 'x') {
                    tot_code += 4 + 1;
                    p += 3;
                } else if (line[p + 1] == '"') {
                    tot_code += 2 + 2;
                    p += 1;
                } else if (line[p + 1] == '\\') {
                    tot_code += 2 + 2;
                    p += 1;
                }
            } else {
                tot_code += 1;
            }
        }
    }
    return tot_code;
}

test "part2" {
    //  "" encodes to "\"\"", an increase from 2 characters to 6.
    const s1 =
        \\""
    ;
    try std.testing.expectEqual(6, part2(s1));
    // "abc" encodes to "\"abc\"", an increase from 5 characters to 9.
    const s2 =
        \\"abc"
    ;
    try std.testing.expectEqual(9, part2(s2));
    // "aaa\"aaa" encodes to "\"aaa\\\"aaa\"", an increase from 10 characters to 16.
    const s3 =
        \\"aaa\"aaa"
    ;
    try std.testing.expectEqual(16, part2(s3));
    // "\x27" encodes to "\"\\x27\"", an increase from 6 characters to 11.
    const s4 =
        \\"\x27"
    ;
    try std.testing.expectEqual(11, part2(s4));
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/08.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    const part1_result = part1(input);
    std.log.info("part 1: {d}", .{part1_result[0] - part1_result[1]});

    const part2_result = part2(input);
    std.log.info("part 2: {d}", .{part2_result - part1_result[0]});
}

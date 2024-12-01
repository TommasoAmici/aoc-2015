const std = @import("std");

const allocator = std.heap.page_allocator;

fn solve(input: *const [8:0]u8, digest_len: comptime_int) !usize {
    const eq = [_]u8{'0'} ** digest_len;
    var i: usize = 0;
    while (true) : (i += 1) {
        var buf: [256]u8 = undefined;
        const str = try std.fmt.bufPrint(&buf, "{s}{d}", .{ input, i });

        var hash: [std.crypto.hash.Md5.digest_length]u8 = undefined;
        std.crypto.hash.Md5.hash(str, &hash, .{});

        const hex = try std.fmt.allocPrint(allocator, "{}", .{std.fmt.fmtSliceHexLower(&hash)});
        defer allocator.free(hex);

        if (std.mem.eql(u8, hex[0..digest_len], &eq)) {
            return i;
        }
    }
}

fn part1(input: *const [8:0]u8) !void {
    const solution = try solve(input, 5);
    std.log.info("part 1: {d}", .{solution});
}

fn part2(input: *const [8:0]u8) !void {
    const solution = try solve(input, 6);
    std.log.info("part 2: {d}", .{solution});
}

pub fn main() !void {
    try part1("ckczppom");
    try part2("ckczppom");
}

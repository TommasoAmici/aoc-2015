const std = @import("std");

fn validPassword(password: []const u8) bool {
    var has_straight = false;
    var pairs: u8 = 0;
    var prev_pair: u8 = undefined;
    for (password, 0..) |ch, i| {
        if (ch == 'i' or ch == 'l' or ch == 'o') {
            return false;
        }
        if (i <= password.len - 3 and ch == password[i + 1] - 1 and ch == password[i + 2] - 2) {
            has_straight = true;
        }
        if (i <= password.len - 2 and ch == password[i + 1]) {
            if (prev_pair != ch) {
                pairs += 1;
                prev_pair = ch;
            }
        }
    }
    return has_straight and pairs >= 2;
}

test "validPassword" {
    try std.testing.expect(!validPassword("i"));
    try std.testing.expect(!validPassword("l"));
    try std.testing.expect(!validPassword("o"));

    try std.testing.expect(!validPassword("hijklmmn"));
    try std.testing.expect(!validPassword("abbceffg"));
    try std.testing.expect(!validPassword("abbcegjk"));

    try std.testing.expect(validPassword("abcdffaa"));
    try std.testing.expect(validPassword("ghjaabcc"));
    // invalid as aa pair is repeated
    try std.testing.expect(!validPassword("abcaabaa"));
}

fn nextPassword(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var str = try std.mem.Allocator.dupe(allocator, u8, input);
    var do = true;
    while (do or !validPassword(str)) {
        do = false;
        var i = str.len - 1;
        while (i >= 0) {
            if (str[i] == 'z') {
                str[i] = 'a';
                i -= 1;
            } else {
                str[i] += 1;
                break;
            }
        }
    }
    return str;
}

test "nextPassword_abcdefgh" {
    const expected = "abcdffaa";

    const actual = try nextPassword(std.testing.allocator, "abcdefgh");
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings(expected, actual);
}

test "nextPassword_ghijklmn" {
    const expected = "ghjaabcc";

    const actual = try nextPassword(std.testing.allocator, "ghijklmn");
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings(expected, actual);
}

fn part1(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    return nextPassword(allocator, input);
}

fn part2(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    const next = try nextPassword(allocator, input);
    return nextPassword(allocator, next);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = "hepxcrrq";

    const part1_password = try part1(allocator, input);
    std.log.info("part 1: {s}", .{part1_password});
    const results_part2 = try part2(allocator, input);
    std.log.info("part 2: {s}", .{results_part2});
}

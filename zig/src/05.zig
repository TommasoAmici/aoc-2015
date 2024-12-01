const std = @import("std");

fn isNice1(word: []const u8) bool {
    var vowels: u8 = 0;
    var pair_found: bool = false;
    for (word[0 .. word.len - 1], word[1..]) |a, b| {
        switch (a) {
            'a' => vowels += 1,
            'e' => vowels += 1,
            'i' => vowels += 1,
            'o' => vowels += 1,
            'u' => vowels += 1,
            else => {},
        }
        if (a == b) {
            pair_found = true;
        }
        // illegal sequences ab, cd, pq, or xy
        if ((a == 'a' and b == 'b') or (a == 'c' and b == 'd') or (a == 'p' and b == 'q') or (a == 'x' and b == 'y')) {
            return false;
        }
    }
    switch (word[word.len - 1]) {
        'a' => vowels += 1,
        'e' => vowels += 1,
        'i' => vowels += 1,
        'o' => vowels += 1,
        'u' => vowels += 1,
        else => {},
    }
    return vowels >= 3 and pair_found;
}

fn isNice2(word: []const u8) bool {
    var two_pairs_found = false;
    var letter_repeating = false;
    var l: u8 = 0;
    while (l < word.len - 1) : (l += 1) {
        // find two pairs
        const a = word[l];
        const b = word[l + 1];

        var r: u8 = l + 2;
        while (r < word.len - 1) : (r += 1) {
            const c = word[r];
            const d = word[r + 1];
            if (a == c and b == d) {
                two_pairs_found = true;
                break;
            }
        }

        // find letters repeating
        if ((l + 2) < word.len and a == word[l + 2]) {
            letter_repeating = true;
        }
    }
    return two_pairs_found and letter_repeating;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/05.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    var nice1: u64 = 0;
    var nice2: u64 = 0;
    var it_lines = std.mem.tokenizeAny(u8, content, "\n");
    while (it_lines.next()) |line| {
        if (isNice1(line)) {
            nice1 += 1;
        }
        if (isNice2(line)) {
            nice2 += 1;
        }
    }
    std.log.info("part 1: {d}", .{nice1});
    std.log.info("part 2: {d}", .{nice2});
}

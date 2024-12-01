const std = @import("std");

const sentinel = -1;

const Aunt = struct {
    children: i64 = sentinel,
    cats: i64 = sentinel,
    samoyeds: i64 = sentinel,
    pomeranians: i64 = sentinel,
    akitas: i64 = sentinel,
    vizslas: i64 = sentinel,
    goldfish: i64 = sentinel,
    trees: i64 = sentinel,
    cars: i64 = sentinel,
    perfumes: i64 = sentinel,
};

const aunts_len = 500;

fn parse(input: []const u8) ![aunts_len]Aunt {
    var aunts: [aunts_len]Aunt = undefined;

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    var aunt_idx: usize = 0;

    const AuntCase = enum { children, cats, samoyeds, pomeranians, akitas, vizslas, goldfish, trees, cars, perfumes };

    while (it_lines.next()) |line| : (aunt_idx += 1) {
        var it_tokens = std.mem.tokenizeAny(u8, line, ": ,");
        var aunt = Aunt{};

        // skip aunt id
        _ = it_tokens.next();
        _ = it_tokens.next();

        while (it_tokens.next()) |token| {
            const case = std.meta.stringToEnum(AuntCase, token) orelse unreachable;
            const value = it_tokens.next() orelse unreachable;
            const value_i = try std.fmt.parseInt(i64, value, 10);
            switch (case) {
                .children => aunt.children = value_i,
                .cats => aunt.cats = value_i,
                .samoyeds => aunt.samoyeds = value_i,
                .pomeranians => aunt.pomeranians = value_i,
                .akitas => aunt.akitas = value_i,
                .vizslas => aunt.vizslas = value_i,
                .goldfish => aunt.goldfish = value_i,
                .trees => aunt.trees = value_i,
                .cars => aunt.cars = value_i,
                .perfumes => aunt.perfumes = value_i,
            }
        }
        aunts[aunt_idx] = aunt;
    }

    return aunts;
}

fn is_gifter_part_1(aunt: *const Aunt) bool {
    if (aunt.children != sentinel and aunt.children != 3) {
        return false;
    }
    if (aunt.cats != sentinel and aunt.cats != 7) {
        return false;
    }
    if (aunt.samoyeds != sentinel and aunt.samoyeds != 2) {
        return false;
    }
    if (aunt.pomeranians != sentinel and aunt.pomeranians != 3) {
        return false;
    }
    if (aunt.akitas != sentinel and aunt.akitas != 0) {
        return false;
    }
    if (aunt.vizslas != sentinel and aunt.vizslas != 0) {
        return false;
    }
    if (aunt.goldfish != sentinel and aunt.goldfish != 5) {
        return false;
    }
    if (aunt.trees != sentinel and aunt.trees != 3) {
        return false;
    }
    if (aunt.cars != sentinel and aunt.cars != 2) {
        return false;
    }
    if (aunt.perfumes != sentinel and aunt.perfumes != 1) {
        return false;
    }
    return true;
}

fn part1(aunts: [aunts_len]Aunt) usize {
    for (aunts, 0..) |aunt, i| {
        if (is_gifter_part_1(&aunt)) {
            return i + 1;
        }
    }
    unreachable;
}

fn is_gifter_part_2(aunt: *const Aunt) bool {
    if (aunt.children != sentinel and aunt.children != 3) {
        return false;
    }
    if (aunt.cats != sentinel and aunt.cats <= 7) {
        return false;
    }
    if (aunt.samoyeds != sentinel and aunt.samoyeds != 2) {
        return false;
    }
    if (aunt.pomeranians != sentinel and aunt.pomeranians > 3) {
        return false;
    }
    if (aunt.akitas != sentinel and aunt.akitas != 0) {
        return false;
    }
    if (aunt.vizslas != sentinel and aunt.vizslas != 0) {
        return false;
    }
    if (aunt.goldfish != sentinel and aunt.goldfish > 5) {
        return false;
    }
    if (aunt.trees != sentinel and aunt.trees <= 3) {
        return false;
    }
    if (aunt.cars != sentinel and aunt.cars != 2) {
        return false;
    }
    if (aunt.perfumes != sentinel and aunt.perfumes != 1) {
        return false;
    }
    return true;
}

fn part2(aunts: [aunts_len]Aunt) usize {
    for (aunts, 0..) |aunt, i| {
        if (is_gifter_part_2(&aunt)) {
            return i + 1;
        }
    }
    unreachable;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/16.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    const aunts: [aunts_len]Aunt = try parse(input);

    const out1 = part1(aunts);
    std.log.info("{d}", .{out1});

    const out2 = part2(aunts);
    std.log.info("{d}", .{out2});
}

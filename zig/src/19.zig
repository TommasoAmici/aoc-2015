const std = @import("std");

const Rules = std.ArrayList([]const u8);
const Replacements = std.StringHashMap(Rules);
const ReverseReplacements = std.StringArrayHashMap([]const u8);

const Parsed = struct {
    replacements: Replacements,
    formula: []const u8,
    reverse: ReverseReplacements,
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !Parsed {
    var replacements: Replacements = Replacements.init(allocator);
    var reverse = ReverseReplacements.init(allocator);

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    const formula: []const u8 = while (it_lines.next()) |line| {
        if (line.len > 20) {
            break line;
        }
        var it_rules = std.mem.tokenizeAny(u8, line, " ");
        var i: u4 = 0;
        var key: []const u8 = undefined;
        var val: []const u8 = undefined;
        while (it_rules.next()) |token| : (i += 1) {
            if (i == 0) {
                key = token;
            }
            if (i == 2) {
                val = token;
            }
        }
        try reverse.put(val, key);
        const map = try replacements.getOrPut(key);
        if (!map.found_existing) {
            const repl = Rules.init(allocator);
            map.value_ptr.* = repl;
        }
        try map.value_ptr.*.append(val);
    } else unreachable;

    return Parsed{
        .formula = formula,
        .replacements = replacements,
        .reverse = reverse,
    };
}

fn replace(allocator: std.mem.Allocator, original: []const u8, index: usize, to_replace: []const u8, replacement: []const u8) ![]const u8 {
    var replaced = try allocator.alloc(u8, original.len - to_replace.len + replacement.len);
    std.mem.copyForwards(u8, replaced[0..], original[0..index]);
    std.mem.copyForwards(u8, replaced[index..], replacement);
    std.mem.copyForwards(u8, replaced[index + replacement.len ..], original[index + to_replace.len ..]);
    return replaced;
}
test "replace" {
    const replaced = try replace(std.testing.allocator, "BROHO", 3, "HO", "GH");
    defer std.testing.allocator.free(replaced);

    try std.testing.expectEqualStrings("BROGH", replaced);
}

fn part1(allocator: std.mem.Allocator, parsed: *const Parsed) !u64 {
    var replacements = std.StringArrayHashMap(bool).init(allocator);
    defer replacements.clearAndFree();

    var l: usize = 0;
    const empty = try Rules.initCapacity(allocator, 0);
    while (l < parsed.formula.len) {
        var key = parsed.formula[l .. l + 1];
        var rules = parsed.replacements.get(key) orelse empty;
        for (rules.items) |rule| {
            const replaced = try replace(allocator, parsed.formula, l, key, rule);
            try replacements.put(replaced, true);
        }

        if (l + 2 < parsed.formula.len) {
            key = parsed.formula[l .. l + 2];
            rules = parsed.replacements.get(key) orelse empty;
            for (rules.items) |rule| {
                const replaced = try replace(allocator, parsed.formula, l, key, rule);
                try replacements.put(replaced, true);
            }
        }
        l += 1;
    }
    return @intCast(replacements.keys().len);
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/19.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    const parsed = try parse(allocator, input);

    const out1 = try part1(allocator, &parsed);
    std.log.err("part 1: {d}", .{out1});
}

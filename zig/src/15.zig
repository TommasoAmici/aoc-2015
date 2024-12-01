const std = @import("std");

const Ingredient = struct {
    capacity: i64,
    durability: i64,
    flavor: i64,
    texture: i64,
    calories: i64,
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Ingredient) {
    const tokens_len = 11;
    const ingredients_len = 4;

    const capacity_idx = 2;
    const durability_idx = 4;
    const flavor_idx = 6;
    const texture_idx = 8;
    const calories_idx = 10;

    var ingredients = try std.ArrayList(Ingredient).initCapacity(allocator, ingredients_len);

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    while (it_lines.next()) |line| {
        var it_tokens = std.mem.tokenizeAny(u8, line, " ,");
        var tokens: [tokens_len][]const u8 = undefined;
        var t: usize = 0;
        while (it_tokens.next()) |token| : (t += 1) {
            tokens[t] = token;
        }
        const ingredient = Ingredient{
            .capacity = try std.fmt.parseInt(i64, tokens[capacity_idx], 10),
            .durability = try std.fmt.parseInt(i64, tokens[durability_idx], 10),
            .flavor = try std.fmt.parseInt(i64, tokens[flavor_idx], 10),
            .texture = try std.fmt.parseInt(i64, tokens[texture_idx], 10),
            .calories = try std.fmt.parseInt(i64, tokens[calories_idx], 10),
        };
        try ingredients.append(ingredient);
    }

    return ingredients;
}

fn cookie_score(capacity: i64, durability: i64, flavor: i64, texture: i64) i64 {
    return @max(0, capacity) * @max(0, durability) * @max(0, flavor) * @max(0, texture);
}

test "cookie_score" {
    try std.testing.expectEqual(cookie_score(2, 10, 10, 2), 400);
    // negatives are counted as 0
    try std.testing.expectEqual(cookie_score(-2, 10, 10, 2), 0);
}

fn part1(ingredients: *std.ArrayList(Ingredient)) i64 {
    const spoonfuls = 101;
    var max_score: i64 = 0;
    var i: i64 = 1;
    while (i < spoonfuls) : (i += 1) {
        const i_capacity = i * ingredients.items[0].capacity;
        const i_durability = i * ingredients.items[0].durability;
        const i_flavor = i * ingredients.items[0].flavor;
        const i_texture = i * ingredients.items[0].texture;

        var j: i64 = 1;
        while (j < spoonfuls - i) : (j += 1) {
            const j_capacity = j * ingredients.items[1].capacity;
            const j_durability = j * ingredients.items[1].durability;
            const j_flavor = j * ingredients.items[1].flavor;
            const j_texture = j * ingredients.items[1].texture;

            var k: i64 = 1;
            while (k < spoonfuls - i - j) : (k += 1) {
                const k_capacity = k * ingredients.items[2].capacity;
                const k_durability = k * ingredients.items[2].durability;
                const k_flavor = k * ingredients.items[2].flavor;
                const k_texture = k * ingredients.items[2].texture;

                var l: i64 = 1;
                while (l < spoonfuls - i - j - k) : (l += 1) {
                    std.debug.assert(i + j + k + l <= 100);

                    const l_capacity = l * ingredients.items[3].capacity;
                    const l_durability = l * ingredients.items[3].durability;
                    const l_flavor = l * ingredients.items[3].flavor;
                    const l_texture = l * ingredients.items[3].texture;

                    const score =
                        cookie_score(
                        i_capacity + j_capacity + k_capacity + l_capacity,
                        i_durability + j_durability + k_durability + l_durability,
                        i_flavor + j_flavor + k_flavor + l_flavor,
                        i_texture + j_texture + k_texture + l_texture,
                    );

                    max_score = @max(max_score, score);
                }
            }
        }
    }

    return max_score;
}

fn part2(ingredients: *std.ArrayList(Ingredient)) i64 {
    const spoonfuls = 101;
    const max_calories = 500;
    var max_score: i64 = 0;
    var i: i64 = 1;
    while (i < spoonfuls) : (i += 1) {
        const i_capacity = i * ingredients.items[0].capacity;
        const i_durability = i * ingredients.items[0].durability;
        const i_flavor = i * ingredients.items[0].flavor;
        const i_texture = i * ingredients.items[0].texture;
        const i_calories = i * ingredients.items[0].calories;
        if (i_calories > max_calories) {
            continue;
        }

        var j: i64 = 1;
        while (j < spoonfuls - i) : (j += 1) {
            const j_capacity = j * ingredients.items[1].capacity;
            const j_durability = j * ingredients.items[1].durability;
            const j_flavor = j * ingredients.items[1].flavor;
            const j_texture = j * ingredients.items[1].texture;
            const j_calories = j * ingredients.items[1].calories;
            if (i_calories + j_calories > max_calories) {
                continue;
            }

            var k: i64 = 1;
            while (k < spoonfuls - i - j) : (k += 1) {
                const k_capacity = k * ingredients.items[2].capacity;
                const k_durability = k * ingredients.items[2].durability;
                const k_flavor = k * ingredients.items[2].flavor;
                const k_texture = k * ingredients.items[2].texture;
                const k_calories = k * ingredients.items[2].calories;
                if (i_calories + j_calories + k_calories > max_calories) {
                    continue;
                }

                var l: i64 = 1;
                while (l < spoonfuls - i - j - k) : (l += 1) {
                    std.debug.assert(i + j + k + l <= 100);

                    const l_capacity = l * ingredients.items[3].capacity;
                    const l_durability = l * ingredients.items[3].durability;
                    const l_flavor = l * ingredients.items[3].flavor;
                    const l_texture = l * ingredients.items[3].texture;
                    const l_calories = l * ingredients.items[3].calories;
                    if (i_calories + j_calories + k_calories + l_calories != max_calories) {
                        continue;
                    }

                    const score =
                        cookie_score(
                        i_capacity + j_capacity + k_capacity + l_capacity,
                        i_durability + j_durability + k_durability + l_durability,
                        i_flavor + j_flavor + k_flavor + l_flavor,
                        i_texture + j_texture + k_texture + l_texture,
                    );

                    max_score = @max(max_score, score);
                }
            }
        }
    }

    return max_score;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/15.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    var ingredients = try parse(allocator, input);
    defer ingredients.deinit();

    const out1 = part1(&ingredients);
    std.log.info("part 1: {d}", .{out1});

    const out2 = part2(&ingredients);
    std.log.info("part 2: {d}", .{out2});
}

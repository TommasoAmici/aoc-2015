const std = @import("std");

fn parse(allocator: std.mem.Allocator, input: []const u8) !std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(i64)) {
    const from_idx = 0;
    const dir_idx = 2;
    const value_idx = 3;
    const to_idx = 10;

    var graph = std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(i64)).init(allocator);

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    while (it_lines.next()) |line| {
        var it_tokens = std.mem.tokenizeAny(u8, line, " .");
        var tokens: [11][]const u8 = undefined;
        var t: usize = 0;
        while (it_tokens.next()) |token| : (t += 1) {
            tokens[t] = token;
        }
        const dir: i64 = if (std.mem.eql(u8, tokens[dir_idx], "gain")) 1 else -1;
        const value = try std.fmt.parseInt(i64, tokens[value_idx], 10);
        const from = tokens[from_idx];
        const to = tokens[to_idx];
        const from_map = try graph.getOrPut(from);
        if (!from_map.found_existing) {
            const inner_map = std.array_hash_map.StringArrayHashMap(i64).init(allocator);
            from_map.value_ptr.* = inner_map;
        }
        try from_map.value_ptr.*.put(to, dir * value);
    }

    return graph;
}

const Seat = struct {
    happiness: i64,
    neighbor: []const u8,
    seated: std.array_hash_map.StringArrayHashMap(bool),

    pub fn init(allocator: std.mem.Allocator, happiness: i64, neighbor: []const u8) !Seat {
        return Seat{
            .happiness = happiness,
            .neighbor = neighbor,
            .seated = std.array_hash_map.StringArrayHashMap(bool).init(allocator),
        };
    }

    pub fn deinit(self: *Seat) void {
        self.seated.deinit();
    }

    pub fn seated_count(self: *Seat) usize {
        return self.seated.keys().len;
    }
};

fn solve(allocator: std.mem.Allocator, graph: *std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(i64))) !i64 {
    var max_happiness: i64 = std.math.minInt(i64);

    for (graph.keys()) |first| {
        var stack = std.ArrayList(Seat).init(allocator);

        try stack.append(try Seat.init(allocator, 0, first));

        while (stack.items.len > 0) {
            var seat = stack.pop();
            try seat.seated.put(seat.neighbor, true);
            if (seat.seated_count() == graph.keys().len) {
                // close the circle
                var arrangement_happiness = seat.happiness;
                const first_preferences: *std.array_hash_map.StringArrayHashMap(i64) = graph.getPtr(first) orelse unreachable;
                const last_preferences: *std.array_hash_map.StringArrayHashMap(i64) = graph.getPtr(seat.neighbor) orelse unreachable;
                arrangement_happiness += first_preferences.get(seat.neighbor) orelse unreachable;
                arrangement_happiness += last_preferences.get(first) orelse unreachable;

                max_happiness = @max(arrangement_happiness, max_happiness);
                continue;
            }
            const preferences: *std.array_hash_map.StringArrayHashMap(i64) = graph.getPtr(seat.neighbor) orelse unreachable;
            for (preferences.keys()) |next| {
                if (seat.seated.contains(next)) {
                    continue;
                }
                const left_happiness = preferences.get(next) orelse unreachable;
                const neighbor_preferences: *std.array_hash_map.StringArrayHashMap(i64) = graph.getPtr(next) orelse unreachable;
                const right_happiness = neighbor_preferences.get(seat.neighbor) orelse unreachable;
                const happiness_from_seat = left_happiness + right_happiness;
                const next_seated = try seat.seated.clone();
                const next_seat = Seat{
                    .happiness = seat.happiness + happiness_from_seat,
                    .neighbor = next,
                    .seated = next_seated,
                };
                try stack.append(next_seat);
            }
        }
    }

    return max_happiness;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/13.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    var graph = try parse(allocator, input);
    defer graph.deinit();

    const part1 = try solve(allocator, &graph);
    std.log.info("part 1: {d}", .{part1});

    const persons = graph.keys();
    var me_preferences = std.array_hash_map.StringArrayHashMap(i64).init(allocator);
    for (persons) |person| {
        var preferences: *std.array_hash_map.StringArrayHashMap(i64) = graph.getPtr(person) orelse unreachable;
        try preferences.put("Me", 0);
        try me_preferences.put(person, 0);
    }
    try graph.put("Me", me_preferences);

    const part2 = try solve(allocator, &graph);
    std.log.info("part 2: {d}", .{part2});
}

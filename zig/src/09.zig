const std = @import("std");

fn parse(allocator: std.mem.Allocator, input: []const u8) !std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(u64)) {
    var graph = std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(u64)).init(allocator);

    var it_lines = std.mem.tokenizeAny(u8, input, "\n");
    while (it_lines.next()) |line| {
        var it_tokens = std.mem.tokenizeAny(u8, line, " ");
        var tokens: [5][]const u8 = undefined;
        var t: usize = 0;
        while (it_tokens.next()) |token| : (t += 1) {
            tokens[t] = token;
        }
        const distance = try std.fmt.parseInt(u64, tokens[4], 10);
        const from = tokens[0];
        const to = tokens[2];
        const from_map = try graph.getOrPut(from);
        if (!from_map.found_existing) {
            const inner_map = std.array_hash_map.StringArrayHashMap(u64).init(allocator);
            from_map.value_ptr.* = inner_map;
        }
        try from_map.value_ptr.*.put(to, distance);

        const to_map = try graph.getOrPut(to);
        if (!to_map.found_existing) {
            const inner_map = std.array_hash_map.StringArrayHashMap(u64).init(allocator);
            to_map.value_ptr.* = inner_map;
        }
        try to_map.value_ptr.*.put(from, distance);
    }

    return graph;
}

const Path = struct {
    cost: u64,
    destination: []const u8,
    visited: std.array_hash_map.StringArrayHashMap(bool),

    pub fn init(allocator: std.mem.Allocator, cost: u64, destination: []const u8) !Path {
        return Path{
            .cost = cost,
            .destination = destination,
            .visited = std.array_hash_map.StringArrayHashMap(bool).init(allocator),
        };
    }

    pub fn deinit(self: *Path) void {
        self.visited.deinit();
    }

    pub fn visited_count(self: *Path) usize {
        return self.visited.keys().len;
    }
};

fn solve(allocator: std.mem.Allocator, graph: *std.array_hash_map.StringArrayHashMap(std.array_hash_map.StringArrayHashMap(u64))) !struct { u64, u64 } {
    var min_cost: u64 = std.math.maxInt(u64);
    var max_cost: u64 = std.math.minInt(u64);

    for (graph.keys()) |key| {
        var stack = std.ArrayList(Path).init(allocator);

        try stack.append(try Path.init(allocator, 0, key));

        while (stack.items.len > 0) {
            var path = stack.pop();
            try path.visited.put(path.destination, true);
            if (path.visited_count() == graph.keys().len) {
                min_cost = @min(path.cost, min_cost);
                max_cost = @max(path.cost, max_cost);
                continue;
            }
            const map: *std.array_hash_map.StringArrayHashMap(u64) = graph.getPtr(path.destination) orelse unreachable;
            for (map.keys()) |next| {
                if (path.visited.contains(next)) {
                    continue;
                }
                const dest_cost = map.get(next) orelse unreachable;
                const next_path_visited = try path.visited.clone();
                const next_path = Path{
                    .cost = path.cost + dest_cost,
                    .destination = next,
                    .visited = next_path_visited,
                };
                try stack.append(next_path);
            }
        }
    }

    return .{ min_cost, max_cost };
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/09.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const input = try file.readToEndAlloc(allocator, 1024 * 1024);

    var graph = try parse(allocator, input);
    defer graph.deinit();

    const solution = try solve(allocator, &graph);
    std.log.info("part 1: {d}", .{solution[0]});
    std.log.info("part 2: {d}", .{solution[1]});
}

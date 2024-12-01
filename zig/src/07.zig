const std = @import("std");

const Operation = enum {
    NOT,
    OR,
    EQ,
    AND,
    RSHIFT,
    LSHIFT,
};

const Instruction = struct {
    op: Operation,
    left: ?[]const u8 = null,
    right: ?[]const u8 = null,
    destination: []const u8,
};

fn parse(allocator: std.mem.Allocator, content: *const []u8) !std.ArrayList(Instruction) {
    var list = std.ArrayList(Instruction).init(allocator);

    var it_lines = std.mem.tokenizeAny(u8, content.*, "\n");
    while (it_lines.next()) |line| {
        var it_instruction = std.mem.tokenizeAny(u8, line, " ");
        var tokenized = std.ArrayList([]const u8).init(allocator);
        while (it_instruction.next()) |token| {
            try tokenized.append(token);
        }

        var op: Operation = undefined;
        var left: ?[]const u8 = null;
        var right: ?[]const u8 = null;
        var destination: []const u8 = undefined;

        if (tokenized.items.len == 3) {
            op = Operation.EQ;
            left = tokenized.items[0];
            destination = tokenized.items[2];
        } else {
            for (tokenized.items, 0..) |token, i| {
                if (std.mem.eql(u8, token, "NOT")) {
                    op = Operation.NOT;
                    right = tokenized.items[i + 1];
                    destination = tokenized.items[i + 3];
                    break;
                } else if (std.mem.eql(u8, token, "OR")) {
                    op = Operation.OR;
                    left = tokenized.items[i - 1];
                    right = tokenized.items[i + 1];
                    destination = tokenized.items[i + 3];
                    break;
                } else if (std.mem.eql(u8, token, "AND")) {
                    op = Operation.AND;
                    left = tokenized.items[i - 1];
                    right = tokenized.items[i + 1];
                    destination = tokenized.items[i + 3];
                    break;
                } else if (std.mem.eql(u8, token, "RSHIFT")) {
                    op = Operation.RSHIFT;
                    left = tokenized.items[i - 1];
                    right = tokenized.items[i + 1];
                    destination = tokenized.items[i + 3];
                    break;
                } else if (std.mem.eql(u8, token, "LSHIFT")) {
                    op = Operation.LSHIFT;
                    left = tokenized.items[i - 1];
                    right = tokenized.items[i + 1];
                    destination = tokenized.items[i + 3];
                    break;
                }
            }
        }
        try list.append(Instruction{
            .op = op,
            .left = left,
            .right = right,
            .destination = destination,
        });

        tokenized.deinit();
    }

    return list;
}

fn solve(destination: []const u8, instructions: *const []Instruction, instructions_map: std.StringHashMap(usize), solved_map: *std.StringHashMap(u16)) !u16 {
    const solved = solved_map.get(destination);
    if (solved != null) {
        return solved.?;
    }

    const numeric = std.fmt.parseInt(u16, destination, 10);
    if (numeric) |value| {
        return value;
    } else |_| {}

    const instr_index = instructions_map.get(destination) orelse unreachable;
    const instr = instructions.*[instr_index];
    switch (instr.op) {
        .EQ => {
            const value = try solve(instr.left orelse unreachable, instructions, instructions_map, solved_map);
            try solved_map.*.put(instr.destination, value);
            return value;
        },
        .AND => {
            const left = try solve(instr.left orelse unreachable, instructions, instructions_map, solved_map);

            const right = try solve(instr.right orelse unreachable, instructions, instructions_map, solved_map);

            try solved_map.*.put(instr.destination, left & right);
            return left & right;
        },
        .OR => {
            const left = try solve(instr.left orelse unreachable, instructions, instructions_map, solved_map);

            const right = try solve(instr.right orelse unreachable, instructions, instructions_map, solved_map);

            try solved_map.*.put(instr.destination, left | right);
            return left | right;
        },
        .LSHIFT => {
            const left = try solve(instr.left orelse unreachable, instructions, instructions_map, solved_map);

            const right: u4 = try std.fmt.parseInt(u4, instr.right.?, 10);

            try solved_map.*.put(instr.destination, left << right);
            return left << right;
        },
        .RSHIFT => {
            const left = try solve(instr.left orelse unreachable, instructions, instructions_map, solved_map);

            const right: u4 = try std.fmt.parseInt(u4, instr.right.?, 10);

            try solved_map.*.put(instr.destination, left >> right);
            return left >> right;
        },
        .NOT => {
            const right = try solve(instr.right orelse unreachable, instructions, instructions_map, solved_map);
            try solved_map.*.put(instr.destination, right);

            return ~right;
        },
    }
}

fn part1(allocator: std.mem.Allocator, instructions: *const []Instruction, wire: []const u8) !u16 {
    var instructions_map = std.StringHashMap(usize).init(allocator);
    var solved_map = std.StringHashMap(u16).init(allocator);
    for (instructions.*, 0..) |instr, index| {
        try instructions_map.put(instr.destination, index);
        if (instr.op == Operation.EQ) {
            const value = std.fmt.parseInt(u16, instr.left.?, 10) catch continue;
            try solved_map.put(instr.destination, value);
        }
    }
    const out: u16 = try solve(wire, instructions, instructions_map, &solved_map);
    return out;
}

fn part2(allocator: std.mem.Allocator, instructions: *const []Instruction, wire: []const u8) !u16 {
    var instructions_map = std.StringHashMap(usize).init(allocator);
    var solved_map = std.StringHashMap(u16).init(allocator);
    for (instructions.*, 0..) |instr, index| {
        try instructions_map.put(instr.destination, index);
        if (instr.op == Operation.EQ) {
            const value = std.fmt.parseInt(u16, instr.left.?, 10) catch continue;
            try solved_map.put(instr.destination, value);
        }
    }
    try solved_map.put("b", try part1(allocator, instructions, "a"));
    const out: u16 = try solve(wire, instructions, instructions_map, &solved_map);
    return out;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/07.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    const instructions = try parse(allocator, &content);
    defer instructions.deinit();

    const part1_result = try part1(allocator, &instructions.items, "a");
    std.log.info("part 1: {d}", .{part1_result});

    const part2_result = try part2(allocator, &instructions.items, "a");
    std.log.info("part 2: {d}", .{part2_result});
}

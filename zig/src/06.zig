const std = @import("std");

const Point = struct { x: u64, y: u64 };

const InstructionType = enum {
    On,
    Off,
    Toggle,
};

const Instruction = struct {
    start: Point,
    end: Point,
    type: InstructionType,
};

fn parse(content: []u8) !std.ArrayList(Instruction) {
    var list = std.ArrayList(Instruction).init(std.heap.page_allocator);

    var it_lines = std.mem.tokenizeAny(u8, content, "\n");
    while (it_lines.next()) |line| {
        var start: u64 = 0;
        var instruction_type: InstructionType = undefined;
        if (std.mem.startsWith(u8, line, "turn on")) {
            start = 1 + 7;
            instruction_type = InstructionType.On;
        } else if (std.mem.startsWith(u8, line, "turn off")) {
            start = 1 + 8;
            instruction_type = InstructionType.Off;
        } else {
            start = 1 + 6;
            instruction_type = InstructionType.Toggle;
        }
        var end = start;
        while (line[end] != ',') {
            end += 1;
        }
        const start_x = try std.fmt.parseInt(u32, line[start..end], 10);

        start = end + 1;
        end = start;
        while (line[end] != ' ') {
            end += 1;
        }
        const start_y = try std.fmt.parseInt(u32, line[start..end], 10);

        start = end + 9;
        end = start;
        while (line[end] != ',') {
            end += 1;
        }
        const end_x = try std.fmt.parseInt(u32, line[start..end], 10);

        start = end + 1;
        end = line.len;
        const end_y = try std.fmt.parseInt(u32, line[start..end], 10);

        const start_point = Point{ .x = start_x, .y = start_y };
        const end_point = Point{ .x = end_x, .y = end_y };
        try list.append(Instruction{
            .start = start_point,
            .end = end_point,
            .type = instruction_type,
        });
    }

    return list;
}

fn part1(instructions: *const []Instruction) !void {
    var lights: [1000][1000]bool = undefined;

    for (instructions.*) |instr| {
        for (instr.start.x..instr.end.x + 1) |x| {
            for (instr.start.y..instr.end.y + 1) |y| {
                switch (instr.type) {
                    .On => lights[x][y] = true,
                    .Off => lights[x][y] = false,
                    .Toggle => lights[x][y] = !lights[x][y],
                }
            }
        }
    }
    var lit: u64 = 0;
    for (lights) |lights_x| {
        for (lights_x) |light| {
            if (light) {
                lit += 1;
            }
        }
    }
    std.log.info("part 1: {d}", .{lit});
}

fn part2(instructions: *const []Instruction) !void {
    var lights: [1000][1000]u64 = [_][1000]u64{[_]u64{0} ** 1000} ** 1000;

    for (instructions.*) |instr| {
        for (instr.start.x..instr.end.x + 1) |x| {
            for (instr.start.y..instr.end.y + 1) |y| {
                switch (instr.type) {
                    .On => lights[x][y] = lights[x][y] + 1,
                    .Off => lights[x][y] = @max(lights[x][y], 1) - 1,
                    .Toggle => lights[x][y] = lights[x][y] + 2,
                }
            }
        }
    }
    var lit: u64 = 0;
    for (lights) |lights_x| {
        for (lights_x) |light| {
            lit += light;
        }
    }
    std.log.info("part 2: {d}", .{lit});
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/06.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    const instructions = try parse(content);
    defer instructions.deinit();

    try part1(&instructions.items);
    try part2(&instructions.items);
}

const std = @import("std");

const Box = [3]u64;

fn parse(content: []u8) !std.ArrayList(Box) {
    var list = std.ArrayList(Box).init(std.heap.page_allocator);

    var it_lines = std.mem.tokenizeAny(u8, content, "\n");
    while (it_lines.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, "x");
        var box: Box = undefined;
        var i: u8 = 0;
        while (it.next()) |dim| : (i += 1) {
            const n = try std.fmt.parseInt(u64, dim, 10);
            box[i] = n;
        }
        try list.append(box);
    }

    return list;
}

/// Returns how many total square feet of wrapping paper the elves should order
fn part1(boxes: *const std.ArrayList(Box)) void {
    var total: u64 = 0;
    for (boxes.items) |box| {
        // the surface area of the box, which is 2*l*w + 2*w*h + 2*h*l
        total += (2 * box[0] * box[1]) + (2 * box[1] * box[2]) + (2 * box[2] * box[0]);
        // the area of the smallest side.
        total += @min(
            @min(
                box[0] * box[1],
                box[1] * box[2],
            ),
            box[2] * box[0],
        );
    }
    std.log.debug("{any}", .{total});
}

/// Returns how many total feet of ribbon they should order
fn part2(boxes: *const std.ArrayList(Box)) void {
    var total: u64 = 0;
    for (boxes.items) |box| {
        // the smallest perimeter of any one face
        total += @min(
            @min(2 * box[0] + 2 * box[1], 2 * box[1] + 2 * box[2]),
            2 * box[2] + 2 * box[0],
        );
        // the volume of the box
        total += box[0] * box[1] * box[2];
    }
    std.log.debug("{any}", .{total});
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./inputs/02.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);

    const boxes = try parse(content);
    defer boxes.deinit();

    part1(&boxes);
    part2(&boxes);
}

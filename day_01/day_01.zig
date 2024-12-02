const std = @import("std");

fn parseInt(raw_int: []const u8) !u32 {
    return std.fmt.parseUnsigned(u32, raw_int, 10);
}

fn lessThanFn(_: void, lhs: u32, rhs: u32) bool {
    return lhs < rhs;
}

fn getDistance(a: u32, b: u32) u32 {
    if (a > b) {
        return a - b;
    }
    return b - a;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) return error.MissingFilePath;

    const input_path = args[1];

    std.debug.print("Reading from {s}\n", .{input_path});

    var dir = std.fs.cwd();
    const file = try dir.openFile(input_path, .{});
    errdefer file.close();

    const file_content = try file.readToEndAlloc(
        allocator,
        1_000_000_000,
    );
    defer allocator.free(file_content);
    file.close();

    var list_1 = std.ArrayList(u32).init(allocator);
    var list_2 = std.ArrayList(u32).init(allocator);
    defer {
        list_1.deinit();
        list_2.deinit();
    }

    var iter = std.mem.splitSequence(
        u8,
        file_content,
        "\n",
    );
    while (iter.next()) |row| {
        var row_iter = std.mem.splitSequence(
            u8,
            row,
            "   ",
        );

        const first_val = row_iter.next();
        const second_val = row_iter.next();

        if (first_val == null or second_val == null) break;

        try list_1.append(try parseInt(first_val.?));
        try list_2.append(try parseInt(second_val.?));
    }

    std.mem.sort(
        u32,
        list_1.items,
        {},
        lessThanFn,
    );
    std.mem.sort(
        u32,
        list_2.items,
        {},
        lessThanFn,
    );

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var sum: u32 = 0;
    for (0..list_1.items.len) |i| {
        const distance = getDistance(
            list_1.items[i],
            list_2.items[i],
        );
        sum += distance;
    }

    try stdout.print("{d}\n", .{sum});

    try bw.flush(); // don't forget to flush!
}

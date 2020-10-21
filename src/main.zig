usingnamespace @cImport({
    @cDefine("WEBVIEW_HEADER", "");
    @cInclude("webview.h");
});
const std = @import("std");
const editor = @import("editor.zig");

const allocator = std.heap.c_allocator;


export fn onKeyDown(seq: [*c]const u8, req: [*c]const u8, arg: ?*c_void) void {
    var parser = std.json.TokenStream.init(std.mem.span(req));
    const parsedReq = std.json.parse([][]u8, &parser, std.json.ParseOptions{ .allocator=allocator }) catch unreachable;
    const key = parsedReq[0];
    webview_return(arg, seq, 0, req);
}

// https://ziglang.org/documentation/0.6.0/#Choosing-an-Allocator
// https://ziglearn.org/chapter-2/
pub fn main() anyerror!void {

    var buffer = editor.Buffer.create(allocator);
    defer buffer.deinit();

    const html = @embedFile("index.html");
    const data_uri = try std.fmt.allocPrint(allocator, " data:text/html,{}\x00", .{html});
    defer allocator.free(data_uri);
    const data_uri_c = @ptrCast([*c]const u8, data_uri);

    const debug = 1;
    var w = webview_create(debug, null);
    webview_set_title(w, "uu");
    webview_set_size(w, 480, 320, WEBVIEW_HINT_NONE);
    webview_navigate(w, data_uri_c);
    webview_bind(w, "uu_onKeyDown", onKeyDown, w);
    webview_run(w);
    webview_destroy(w);
}

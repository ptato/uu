usingnamespace @cImport({
    @cDefine("WEBVIEW_HEADER", "");
    @cInclude("webview.h");
});
const std = @import("std");

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator; 

    const html = @embedFile("index.html");
    const data_uri = try std.fmt.allocPrint(allocator, " data:text/html,{}\x00", .{html});
    defer allocator.free(data_uri);
    const data_uri_c = @ptrCast([*c]const u8, data_uri);

    const debug = 1;
    var w = webview_create(debug, null);
    webview_set_title(w, "uu");
    webview_set_size(w, 480, 320, WEBVIEW_HINT_NONE);
    webview_navigate(w, data_uri_c);
    webview_run(w);
    webview_destroy(w);
}

const std = @import("std");
const webview = @cImport({
    @cDefine("WEBVIEW_HEADER", "");
    @cInclude("webview.h");
});

pub fn main() anyerror!void {
    std.debug.warn("All your codebase are belong to us.\n", .{});
    var w = webview.webview_create(0, null);
    webview.webview_set_title(w, "uu");
    webview.webview_set_size(w, 480, 320, webview.WEBVIEW_HINT_NONE);
    webview.webview_navigate(w, "https://en.m.wikipedia.org/wiki/Main_Page");
    webview.webview_run(w);
    webview.webview_destroy(w);
}

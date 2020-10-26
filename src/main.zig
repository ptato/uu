usingnamespace @cImport({
    @cDefine("WEBVIEW_HEADER", "");
    @cInclude("webview.h");
});
const std = @import("std");
const editor = @import("editor.zig");

const default_allocator = std.heap.c_allocator;

const App = struct {
    allocator: *std.mem.Allocator,
    webview: webview_t,
    buffer: editor.Buffer,

    pub fn create(allocator: *std.mem.Allocator, webview: webview_t) App {
        return App {
            .allocator = allocator,
            .webview = webview,
            .buffer = editor.Buffer.create(allocator),
        };
    }

    pub fn deinit(self: App) void {
        self.buffer.deinit();
    }
};

export fn onKeyDown(seq: [*c]const u8, req: [*c]const u8, arg: ?*c_void) void {
    var app = @ptrCast(*App, @alignCast(8, arg));

    var parser = std.json.TokenStream.init(std.mem.span(req));
    const parsedReq = std.json.parse([][]u8, &parser, std.json.ParseOptions{ .allocator=app.allocator }) catch unreachable;
    const key = parsedReq[0];
    app.buffer.append(key);

    const text = app.buffer.toString();
    const js = std.fmt.allocPrint(app.allocator, "text.value = '{}'\x00", .{text}) catch return;
    defer app.allocator.free(js);
    webview_eval(app.webview, @ptrCast([*c]const u8, js));
}

// https://ziglang.org/documentation/0.6.0/#Choosing-an-Allocator
// https://ziglearn.org/chapter-2/
pub fn main() anyerror!void {

    const html = @embedFile("index.html");
    const data_uri = try std.fmt.allocPrint(default_allocator, " data:text/html,{}\x00", .{html});
    defer default_allocator.free(data_uri);
    const data_uri_c = @ptrCast([*c]const u8, data_uri);

    const debug = 1;
    var w = webview_create(debug, null);

    var app = App.create(default_allocator, w);
    defer app.deinit();

    webview_set_title(w, "uu");
    webview_set_size(w, 480, 320, WEBVIEW_HINT_NONE);
    webview_navigate(w, data_uri_c);
    webview_bind(w, "uu_onKeyDown", onKeyDown, &app);
    webview_run(w);
    webview_destroy(w);
}

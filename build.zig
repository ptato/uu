// It works right now... but I don't fully understand it
// It's hard to find good documentation for this build system
//
// I'm not sure if I'm defining the object file (.o) as rigurously
// as I would like in order for it to count as an actual "step" or
// whatever and not be recompiled every time. Also I would like
// the .o file to go on the zig-cache/ folder and that way I
// wouldn't need the webview/ folder
const std = @import("std");
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();



    const exe = b.addExecutable("uu", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    // exe.linkSystemLibrary("c");
    // try exe.linkSystemLibraryPkgConfigOnly("gtk+-3.0");
    // try exe.linkSystemLibraryPkgConfigOnly("webkit2gtk-4.0");
    // exe.c_std = Builder.CStd.C11;
    
    const webviewObjStep = WebviewLibraryStep.create(b);
    exe.step.dependOn(&webviewObjStep.step);
    exe.addIncludeDir("webview");
    exe.addObjectFile("webview/webview.o");
    exe.linkSystemLibrary("c++");
    exe.linkSystemLibrary("gtk+-3.0");
    exe.linkSystemLibrary("webkit2gtk-4.0");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const WebviewLibraryStep = struct {
    builder: *std.build.Builder,
    step: std.build.Step,

    fn create(builder: *std.build.Builder) *WebviewLibraryStep {
        const self = builder.allocator.create(WebviewLibraryStep) catch unreachable;
        self.* = init(builder);
        return self;
    }

    fn init(builder: *std.build.Builder) WebviewLibraryStep {
        return WebviewLibraryStep{
            .builder = builder,
            .step = std.build.Step.init("Webview Library Compile", builder.allocator, make),
        };
    }

    fn make(step: *std.build.Step) !void {
        const self = @fieldParentPtr(WebviewLibraryStep, "step", step);
        const libs = std.fmt.trim(try self.builder.exec(
            &[_][]const u8{ "pkg-config", "--cflags", "--libs", "gtk+-3.0", "webkit2gtk-4.0" },
        ));

        var cmd = std.ArrayList([]const u8).init(self.builder.allocator);
        defer cmd.deinit();

        try cmd.append("zig");
        try cmd.append("c++");
        // try cmd.append("-v");
        try cmd.append("-c");
        try cmd.append("webview/webview.cc");
        try cmd.append("-DWEBVIEW_GTK");
        try cmd.append("-std=c++11");
        var line_it = std.mem.tokenize(libs, " ");
        while (line_it.next()) |item| {
            try cmd.append(item);
        }
        try cmd.append("-o");
        try cmd.append("webview/webview.o");

        _ = std.fmt.trim(try self.builder.exec(cmd.items));
    }
};
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    var main_tests = b.addTest("src/main.zig");
    main_tests.addPackagePath("unicode", "lib/zunicode/src/index.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    b.default_step.dependOn(test_step);
}

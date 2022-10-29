// NOTE: It's important that the header-only libs do not include
// their implementations here. There are include/*_impl.c files
// that include their implementations to be compiled as C and
// linked. This prevents us from trying to translate the impls
// to zig which can cause some weird outcomes
pub usingnamespace @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
    @cInclude("stb_image.h");
    @cInclude("miniaudio.h");
});

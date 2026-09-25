#version 440
// Wave-wipe wallpaper transition (single texture: the incoming wallpaper).
// A rippling wavefront sweeps left to right; the outgoing wallpaper shows
// through wherever the new one is not yet revealed.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    vec2 uv = qt_TexCoord0;
    float edge = progress * 1.2 - 0.1;
    float dist = edge - uv.x;
    float ripple = sin(uv.y * 28.0 + progress * 14.0) * 0.012 * exp(-abs(dist) * 9.0);
    float reveal = smoothstep(-0.035, 0.035, dist + ripple);
    vec4 c = texture(source, vec2(uv.x + ripple, uv.y));
    fragColor = vec4(c.rgb, c.a * reveal * qt_Opacity);
}

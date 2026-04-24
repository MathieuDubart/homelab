//
//  HomelabShaders.metal
//  Homelab
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Cheap 2D value noise — good enough for flowing colour fields.
static float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float noise2(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

static float fbm(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise2(p);
        p *= 2.03;
        a *= 0.5;
    }
    return v;
}

// Aurora layerEffect: returns an RGBA colour given the destination pixel.
// Use via `.layerEffect(ShaderLibrary.aurora(.float(time), .float2(size), .color(tint)), maxSampleOffset: .zero)`
// or `.colorEffect(...)` on a filled rect.
[[ stitchable ]] half4 aurora(float2 position,
                              SwiftUI::Layer layer,
                              float time,
                              float2 size,
                              half4 tintA,
                              half4 tintB) {
    float2 uv = position / size;
    float2 p = uv * 2.0 - 1.0;
    p.x *= size.x / max(size.y, 1.0);

    float t = time * 0.15;
    float n = fbm(p * 1.6 + float2(t, -t * 0.7));
    float m = fbm(p * 2.3 - float2(t * 0.8, t));
    float band = smoothstep(0.25, 0.85, n * 0.6 + m * 0.4);

    half3 a = tintA.rgb;
    half3 b = tintB.rgb;
    half3 colour = mix(a, b, half(band));

    // soft vignette so edges fade into the canvas
    float r = length(uv - 0.5);
    float vignette = smoothstep(0.95, 0.35, r);

    half alpha = half(vignette) * half(0.85);
    return half4(colour * alpha, alpha);
}

// Sheen — a moving diagonal light pass, used on hero cards.
[[ stitchable ]] half4 sheen(float2 position,
                             SwiftUI::Layer layer,
                             float time,
                             float2 size) {
    half4 base = layer.sample(position);
    float2 uv = position / size;
    float diag = uv.x + uv.y;
    float phase = fract(time * 0.25);
    float band = smoothstep(0.0, 0.08, abs(diag - phase * 2.0));
    float highlight = (1.0 - band) * 0.35;
    return base + half4(half3(highlight), 0.0);
}

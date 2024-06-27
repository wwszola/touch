#version 300 es

precision mediump float;

uniform sampler2D sInput;
uniform vec2 uOutputRes;

#define N 4
const mat2 bayer2 = mat2(
    0.00, 0.50,
    0.75, 0.25
);

const mat4 bayer4 = mat4(
    0.000, 0.500, 0.125, 0.625,
    0.750, 0.250, 0.875, 0.375,
    0.188, 0.688, 0.062, 0.562,
    0.938, 0.438, 0.812, 0.312
);

const float THIRD = 1.0/3.0;

float rgbAverage(vec4 color){
    return (color.r + color.g + color.b) * THIRD;
}

in vec2 vUV;
out vec4 fragColor;

void main() {
    ivec2 pixelUV = ivec2(vUV*uOutputRes);
    ivec2 pos = pixelUV % N;

    vec4 color = texture(sInput, vUV);
    float value = round((1.0 - rgbAverage(color))*100.)/100.;

    if(value <= bayer4[pos.y][pos.x]){
        // color = vec4(0.7, 0.2, 0.2, 1.0);
        color = vec4(1.0, 1.0, 1.0, 1.0);
    }else{
        // color = vec4(0.3, 0.1, 0.3, 1.0);
        color = vec4(0.0, 0.0, 0.0, 1.0);
    }

    fragColor = color;
    // fragColor = vec4(pos.x, pos.y, 0.0, 1.0);
    // gl_FragColor = vec4(atlasCoord.x, 0.0, 0.0, 1.0);
}
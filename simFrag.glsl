#version 300 es

precision mediump float;

uniform vec2 uAspectRatio;
uniform vec2 circles[8];

in vec2 vUV;
out vec4 fragColor;

float sdCircle(vec2 p, vec2 c, float r){
    return length((p - c)/uAspectRatio) - r;
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

void main() {
    float dist = 100.0;
    for(int i = 0; i < 8; i += 1){
        float d = sdCircle(vUV, circles[i]+vec2(0.0, 0.2), 0.05);
        dist = opSmoothUnion(dist, d, 0.5);
    }

    float v = dist;
    fragColor = vec4(v, v, v, 1.0);

}
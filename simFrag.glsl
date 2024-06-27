#version 300 es

precision highp float;

uniform vec2 uAspectRatio;

#define MAXCIRCLES 8
uniform int uNumCircles;
uniform vec2 circles[MAXCIRCLES];

uniform sampler2D sShadowMap;

in vec2 vUV;
out vec4 fragColor;

float sdCircle(vec2 p, vec2 c, float r){
    return length((p - c)/uAspectRatio) - r;
}

float sdBox(vec2 p, vec2 origin, vec2 size){
    vec2 b = size*0.5;
    vec2 d = abs(p - origin) - b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float circlesMap(vec2 p){
    if(uNumCircles == 0)
        return 0.0;
    float dist = 100.0;
    for(int i = 0; i < uNumCircles; i += 1){
        float d = sdCircle(p, circles[i], 0.0);
        dist = opSmoothUnion(dist, d, 0.2);
    }
    return dist;
}


float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float shadow(vec2 p, vec2 ro){
    vec2 rd = p - ro;
    float maxt = length(rd);
    rd = normalize(rd);

    float N = 64.0;
    float h = maxt/(N + 1.0);

    bool inside = false;

    float res = 1.0;
    float t = 0.0;
    for(int i = 0; t < maxt; i += 1){
        vec2 p = ro + rd*t;
        float s = texture(sShadowMap, p).r;
        if(s > 1e-4){
            res = 0.9*res;
            if(!inside){
                res = res + 0.3;
            }
            inside = true;
        }else{
            if(inside){
                res = res - 0.3;
            }
            inside = false;
        }
        if(res < 1e-2)
            return 0.0;
        // res = min(res, 4.0 * t/maxt);
        t += h;
    }
    // res = res + rand(vUV)*0.2-0.1;
    return res;
}

void main() {
    float light = clamp(1.0 - circlesMap(vUV), 0.0, 1.0);
    float s = 0.0;
    for(int i = 0; i < uNumCircles; i += 1){
        float sc = shadow(vUV, circles[i]);
        s = min(s + sc, 1.0);
    }
    float v = light * s;
    v = clamp(v, 0.0, 1.0);
    //v = texture(sShadowMap, vUV).r;
    fragColor = vec4(v, v, v, 1.0);

}
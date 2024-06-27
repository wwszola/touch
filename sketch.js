let canvas;

let font1;

let orderedDithering;
let simShader;

let simBuffer;
let mainBuffer;
let g;

let gridRes;

function preload(){
    font1 = loadFont('fonts/Roboto-Bold.ttf');
    orderedDithering = loadShader('baseVert.glsl', 'orderedDithering.glsl');
    simShader = loadShader('baseVert.glsl', 'simFrag.glsl');
}


function setup(){
    canvas = createCanvas(windowWidth, windowHeight, WEBGL);
    pixelDensity(1);

    let K = 2.0;
    gridRes = {width: Math.floor(windowWidth/K), height: Math.floor(windowHeight/K)};

    let options = {
        width: gridRes.width, 
        height: gridRes.height,
        //depth: false,
        antialias: false,
        density: 1,
        textureFiltering: NEAREST
    };
    simBuffer = createFramebuffer(options);
    mainBuffer = createFramebuffer(options);

    g = createGraphics(windowWidth/2, windowHeight/2);

}

function text1(){
    g.background(0);
    g.push();
    g.fill(255);
    g.textFont(font1);
    g.textSize(48);
    g.textAlign(LEFT, TOP);
    g.textLeading(64);
    g.text(
        "I don't\nhave a\nphysical\nform or\npersonal\nidentity\nlike\nhumans\ndo.", 
        // "I don't\nhave a\nphysical\nForm or\npersonal\nIdentity\nlike\nHumans\ndo.", 
        // "I DON'T\nHAVE A\nPHYSICAL\nFORM OR\nPERSONAL\nIDENTITY\nLIKE\nHUMANS\nDO.",
        8, 300 - 0.7*frameCount % 1000
    );
    g.pop();
    // g.filter(BLUR, 1);
}

function draw(){
    background(0);
    translate(-windowWidth/2, -windowHeight/2);

    text1();
    simBuffer.begin();
    clear();
    let touchesData = touches.concat([{x: mouseX, y: mouseY}])
        .map(touch => [touch.x/windowWidth, touch.y/windowHeight])
        .flat()
        .concat((Array(16 - 2*(touches.length+1)).fill(-100)));
    simShader.setUniform('uNumCircles', touches.length);
    simShader.setUniform('circles', touchesData);
    simShader.setUniform('uAspectRatio', [1, gridRes.width/gridRes.height]);
    simShader.setUniform('sShadowMap', g);

    shader(simShader);
    rect(0, 0, gridRes.width, gridRes.height);
    simBuffer.end();

    mainBuffer.begin();
    clear();
    orderedDithering.setUniform('sInput', simBuffer);
    orderedDithering.setUniform('uOutputRes', [gridRes.width, gridRes.height]);

    shader(orderedDithering);
    rect(0, 0, gridRes.width, gridRes.height);
   
    mainBuffer.end();

    image(mainBuffer, 0, 0, windowWidth, windowHeight);
}


let canvas;

let orderedDithering;
let simShader;

let simBuffer;
let mainBuffer;

let gridRes;

function preload(){
    orderedDithering = loadShader('baseVert.glsl', 'orderedDithering.glsl');
    simShader = loadShader('baseVert.glsl', 'simFrag.glsl');
}


function setup(){
    canvas = createCanvas(windowWidth, windowHeight, WEBGL);
    pixelDensity(1);

    gridRes = {width: Math.floor(windowWidth/4), height: Math.floor(windowHeight/4)};

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

}

function draw(){
    background(0);
    translate(-windowWidth/2, -windowHeight/2);

    simBuffer.begin();
    clear();

    let touchesData = touches.map(touch => [touch.x/windowWidth, touch.y/windowHeight])
        .flat()
        .concat((Array(16 - 2*touches.length).fill(-100)))
    simShader.setUniform('circles', touchesData);
    simShader.setUniform('uAspectRatio', [1, gridRes.width/gridRes.height]);
    
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


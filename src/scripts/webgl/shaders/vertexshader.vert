attribute vec3 position;
attribute vec3 color_1;
attribute vec3 color_2;
attribute vec3 color_3;
attribute vec3 color_4;
attribute vec3 color_5;
attribute float p_indecies;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
// uniform float noiseRangeX;
// uniform float noiseRangeY;
// uniform float noiseRangeZ;
// uniform float distortionLevel;
// uniform float distortionRange;
uniform float time;
varying vec3 v_color_1;
varying vec3 v_color_2;
varying vec3 v_color_3;
varying vec3 v_color_4;
varying vec3 v_color_5;

// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289_1_0(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289_1_0(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute_1_1(vec3 x) {
  return mod289_1_0(((x*34.0)+1.0)*x);
}

float snoise_1_2(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289_1_0(i); // Avoid truncation effects in permutation
  vec3 p = permute_1_1( permute_1_1( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float random(float n) {
	return fract(sin(n) * 43758.5453123);
}

void main() {
    v_color_1 = color_1;
    v_color_2 = color_2;
    v_color_3 = color_3;
    v_color_4 = color_4;
    v_color_5 = color_5;
    // float noiseX = position.x * noiseRangeX + time;
    // float noiseY = position.y * noiseRangeY + time;
    // float noiseZ = (position.x + position.y) * noiseRangeZ + time;
    // vec3 distortionPosition = position * snoise3(vec3(noiseX, noiseY, noiseZ)) * distortionLevel * distortionRange;
    // vec3 resultPosition = position + distortionPosition;

    // vec3 greyEdge = vec3(0.21, 0.71, 0.7); // 閾値
    // float psize = 5.0;
    // psize *= psize *= max(grey, 0.2);
    float baseSize = 3.0;
    float colorSize = (color_1.r + color_1.g + color_1.b);
    float pSize = (snoise_1_2(vec2(time, p_indecies) * 0.5) * 3.0 + baseSize);
    pSize *= max(colorSize, 0.2);

    vec3 displaced = position;
    displaced.xy += vec2(random(p_indecies) - 0.5, random(position.x + p_indecies) - 0.5);

    vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);

    // mvPosition.xyz += position * (sin(time * 0.010 * random(p_indecies)) * 0.1);

    gl_Position = projectionMatrix * mvPosition;
    gl_PointSize = pSize;
}
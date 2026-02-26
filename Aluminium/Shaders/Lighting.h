//
//  Lighting.h
//  Aluminium
//
//  Created by Hayden Chalin on 2/16/26.
//

#ifndef Lighting_h
#define Lighting_h
#import "Common.h"


float3 phongLighting(
    float3           normal,
    float3           position,
    constant Params &params,
    constant Light   *lights,
    float3           baseColor);


// PBR functions
float3 computeSpecular(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal,
  float3 worldPosition);

float3 computeDiffuse(
  constant Light *lights,
  constant Params &params,
  Material material,
  float3 normal);
 
float3 computeAmbient(
  constant Light *lights,
  constant Params &params,
  Material material);

#endif /* Lighting_h */

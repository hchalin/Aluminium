//
//  Lighting.metal
//  Aluminium
//
//  Created by Hayden Chalin on 2/16/26.
//

#import "Lighting.h"
#include <metal_stdlib>

using namespace metal;

/*
   Computes per-fragment lighting using the Phong reflection model.

   Parameters:
   - normal: The surface normal at the fragment in world space. Must be normalized for correct results.
   - position: The fragment position in world space.
   - params: Global render parameters, including camera position and the number of active lights (`lightCount`). See `Params`
   - lights: Pointer to an array of `Light` structures describing all lights available to this draw.
   - baseColor: The base (albedo) color for the surface before lighting is applied.

   Returns:
   - float3 RGB color representing the sum of ambient, diffuse, and specular contributions from all active lights.
 */
// calculate the phong Lighting model
float3 phongLighting(float3 normal, float3 position, constant Params &params, constant Light *lights, float3 baseColor) {
    /*
       These will be added together and returned to determine the
       final fragment color
     */
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    // Material properties - these should be obtained from the materials
    float materialShininess = 8;
    float3 materialSpecularColor = float3(0.2);

    // Loop through all the lights in the scene
    for (uint i { 0 }; i < params.lightCount; ++i) {
        // Create a light
        Light light = lights[i];
        // Todo: Create surfacecolor variable to replace light.color
        float3 surfaceColor = light.color * light.intensity * baseColor;
        switch (light.type) {
            /*
                Sunlight
             */
            case Sun: {
                // Calc light direction normalized
                float3 lightDirection = normalize(-light.position);  // inverse of the light dir

                /*  Saturate is the same as clamp(x, 0.0, 1.0)
                    This will give a value per pixel for the brightess of a given pixel
                 */
                float diffuseIntensity = saturate(-dot(lightDirection, normal));
                /*
                    Each pixel: Take the base color of the pixel, multiply that times the color
                    of the light, that will give you the final colors mixed. Then multiply that
                    times the diffuse intensity to get the brightness of the pixel based off
                    the lights position.
                 */
                diffuseColor += surfaceColor * diffuseIntensity;

                // If the pixel has a color to it, calculate specularity
                if (diffuseIntensity > 0) {
                    // Calculate the reflection
                    float3 reflection = reflect(lightDirection, normal);

                    // Calc the view direction
                    float3 viewDirection = normalize(params.cameraPosition);

                    float specIntensity = pow(saturate(dot(reflection, viewDirection)), materialShininess);

                    specularColor += light.specularColor * materialSpecularColor * specIntensity;
                }

                break;
            }

            /*
                Spotlight
             */
            case Spot: {
                float d = distance(light.position, position);
                float3 lightDirection = normalize(light.position - position);
                
                float3 coneDirection = normalize(light.coneDirection);
                float spotResult = dot(lightDirection, -coneDirection);
                
                if (spotResult > cos(light.coneAngle)){
                    float attenuation = 1.0 / ( light.attenuation.x + light.attenuation.y * d +
                        light.attenuation.z * d * d);
                    attenuation *= pow(spotResult, light.coneAttenuation);
                    float diffuseIntensity =
                    saturate(dot(lightDirection, normal));
                    float3 color = surfaceColor * diffuseIntensity;
                    color *= attenuation;
                    diffuseColor += color;
                }
                break;
            }

            /*
               Pointlight
             */
            case Point:{
                // Calculate the distance
                float d = distance(light.position, position);

                // Light direction
                float3 lightDirection = normalize(light.position - position);

                // Attenuation - NOTE: attenuation is a vector3. See `Light`
                float attenuation = 1.0 / ( light.attenuation.x + light.attenuation.y * d +
                    light.attenuation.z * d * d);

                float diffuseIntensity =
                saturate(dot(lightDirection, normal));
                
                float3 color = surfaceColor * diffuseIntensity;
                
                color *= attenuation;
                diffuseColor += color;

                break;
            }

            /*
               Ambientlight
                Adds the value of the ambient `Light` to the ambient color
             */
            case Ambient: {
                ambientColor += surfaceColor;
                break;
            }

            /*
               Unused / undetermined light type
             */
            case Unused: {
                break;
            }
        }
    }

    return specularColor + ambientColor + diffuseColor;
}

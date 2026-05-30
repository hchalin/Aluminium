#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

#import "ShaderDefs.h"



fragment float4 fragment_main(
    constant Params &   params [[buffer(ParamsBuffer)]],
    VertexOut           in [[stage_in]],
    texture2d < float > baseColorTexture [[texture(BaseColor)]],
    constant Light      *lights[[buffer(LightBuffer)]],
    constant Material & _material [[buffer(MaterialBuffer)]],
    texture2d < float > roughnessTexture [[texture(RoughnessTexture)]],
    texture2d < float > normalTexture [[texture(NormalTexture)]],
    texture2d < uint >  idTexture  [[texture(11)]],
    depth2d < float >   shadowTexture [[texture(12)]]
    ) {
    // Add material to override
    Material material = _material;

    // Samples
    constexpr sampler textureSampler(
        filter::linear,
        address::repeat,
        mip_filter::linear,
        max_anisotropy(8)
        );

    // Calc base color of textureSampler
    if (!is_null_texture(baseColorTexture)) {
        material.baseColor = baseColorTexture.sample(
            textureSampler,
            in.uv * params.tiling).rgb;
    }

    
    if (params.selectableObjects && !is_null_texture(idTexture)) {
        uint2 coord = uint2(
            params.touchX * params.scaleFactor,
            params.touchY * params.scaleFactor
                            );
        uint objectId = idTexture.read(coord).r;
        
        if (params.objectId != 0 && objectId == params.objectId){
            material.baseColor = float3(0.9, 0.5, 0.0);
        }
    }
        

    // Calc roughness texture
    if (!is_null_texture(roughnessTexture)) {
        material.roughness = roughnessTexture.sample(
            textureSampler,
            in.uv * params.tiling
            ).r;
    }

    // Normalize the vector from world pos
    float3 normal;

    if (is_null_texture(normalTexture)) {
        normal = in.worldNormal;
    } else {
        normal = normalTexture.sample(
            textureSampler,
            in.uv * params.tiling
            ).rgb;
        normal = normal * 2 - 1;
        normal = float3x3(
            in.worldTangent,
            in.worldBitangent,
            in.worldNormal) * normal;
    }

    normal = normalize(normal);
//    float3 color = normal;

    // compute diffuse
    float3 diffuseColor = computeDiffuse(lights, params, material, normal);

    // Specular
    float3 specularColor = computeSpecular(lights, params, material, normal, in.worldPosition);

    float3 ambientColor = computeAmbient(
        lights, params, material);
    
    
    float3 shadowPosition = in.shadowPosition.xyz / in.shadowPosition.w;        // Perspective divide
    float2 xy = shadowPosition.xy;
    xy = xy * 0.5 + 0.5;            // rescale from [-1, 1] -> [0, 1]
    xy.y = 1 - xy.y;                // Reverse the y coord
    if (xy.x < 0 || xy.x > 1 || xy.y < 0 || xy.y > 1){
        return float4(1.0, 0.0, 0.0, 1.0);
    }
    xy = saturate(xy);
    
    constexpr sampler s(
                        coord::normalized,
                        filter::linear,
                        address::clamp_to_edge,
                        compare_func::less
                        );
    float shadowSample = shadowTexture.sample(s,xy);
    if (shadowPosition.z > shadowSample + 0.0001){
        diffuseColor *= .5;
    }

    return float4(diffuseColor + specularColor + ambientColor, 1);
}

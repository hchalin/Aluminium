#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct {
    uint32_t width;
    uint32_t height;
    uint32_t tiling;
    uint32_t lightCount;
    vector_float3 cameraPosition;
} Params;

typedef enum {
    VertexBuffer    = 0,
    UVBuffer        = 1,
    TangentBuffer   = 2,
    BitangentBuffer = 3,
    UniformsBuffer  = 11,
    ParamsBuffer    = 12,
    LightBuffer     = 13,
    MaterialBuffer  = 14
} BufferIndices;


// Vertex Attributes
typedef enum {
    Position  = 0,
    Normal    = 1,
    UV        = 2,
    Tangent   = 3,
    Bitangent = 4
} Attributes;

// Type Defines for Texture Indices, you can use 'BaseColor' as its own type!
typedef enum {
    BaseColor        = 0,
    NormalTexture    = 1,
    RoughnessTexture = 2,
    MetallicTexture  = 3,
    AOTexture        = 4                    // Ambient Occlusion
} TextureIndices;

typedef enum {
    Unused  = 0,
    Sun     = 1,
    Spot    = 2,
    Point   = 3,
    Ambient = 4
} LightType;

typedef struct {
    LightType type;
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float intensity;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

typedef struct {
    vector_float3 baseColor;
    float shininess;
    float roughness;
    float ambientOcclusion;
    float metallic;
} Material;

#endif /* Common_h */

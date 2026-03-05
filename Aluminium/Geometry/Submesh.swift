import MetalKit

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    var textures: Textures
    var material: Material

    // Properties for Submesh.Texture
    struct Textures {
        var baseColor: MTLTexture?
        var roughness: MTLTexture?
        var normal: MTLTexture?
        var metallic: MTLTexture?
        var ambientOcclusion: MTLTexture?
    }
}

// Extend submesh
extension Submesh {
    // Initializer for Submesh
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        indexCount = mtkSubmesh.indexCount
        indexType = mtkSubmesh.indexType
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
        textures = Textures(material: mdlSubmesh.material)
        material = Material(material: mdlSubmesh.material)
    }
}

// 1 Load up the base color (diffuse) texture with the provided submesh material. You’ll load other textures for the submesh in the same way.
private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        baseColor = material?.texture(type: .baseColor)
        roughness = material?.texture(type: .roughness)
        normal = material?.texture(type: .tangentSpaceNormal)
        metallic = material?.texture(type: .metallic)
        ambientOcclusion = material?.texture(type: .ambientOcclusion)
    }
}

// 2 MDLMaterialProperty.textureName returns either the texture name in the file or a unique identifier when no name is provided.
private extension MDLMaterialProperty {
    var textureName: String {
        stringValue ?? UUID().uuidString
    }
}

/* 3
 MDLMaterial.property(with:) looks up the provided property in the submesh’s material. You then check whether the property type is a texture and load the texture into TextureController.textures. Material properties can also be float values where there is no texture available for the submesh.
 */
private extension MDLMaterial {
  func texture(type semantic: MDLMaterialSemantic) -> MTLTexture? {
    if let property = property(with: semantic),
    property.type == .texture,
    let mdlTexture = property.textureSamplerValue?.texture {
      var texture = TextureController.loadTexture(
        texture: mdlTexture,
        name: property.textureName)
      if semantic == .baseColor,
        texture?.pixelFormat == .rgba8Unorm {
        texture = texture?.makeTextureView(pixelFormat: .rgba8Unorm_srgb)
        TextureController.textures[property.textureName] = texture
      }
      return texture
    }
    return nil
  }
}

private extension Material {
    init(material: MDLMaterial?){
        self.init()
        if let baseColor = material?.property(with: .baseColor),
           baseColor.type == .float3{
            self.baseColor = baseColor.float3Value
        }
        ambientOcclusion = 1
        if let roughness = material?.property(with: .roughness),
           roughness.type == .float {
            self.roughness = roughness.floatValue
        }
    }
}

import MetalKit

// Rendering
/**
  - NOTE: This is an EXTENSION of a Model used for rendering, some of the properties you see here
          e.g. (tiling) is defined in the Model class.
 */
extension Model {
  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms vertex: Uniforms,
    params fragment: Params
  ) {
    // make the structures mutable
    var uniforms = vertex
    var params = fragment
    params.tiling = tiling
//    params.objectId = objectId

    uniforms.modelMatrix = transform.modelMatrix
    uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

    encoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index)

    encoder.setFragmentBytes(
      &params,
      length: MemoryLayout<Params>.stride,
      index: ParamsBuffer.index)

    for mesh in meshes {
      for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(
          vertexBuffer,
          offset: 0,
          index: index)
      }

      for submesh in mesh.submeshes {
        // set the fragment texture here
        var material = submesh.material
        encoder.setFragmentBytes(
          &material,
          length: MemoryLayout<Material>.stride,
          index: MaterialBuffer.index)

        encoder.setFragmentTexture(
          submesh.textures.baseColor,
          index: BaseColor.index)

        encoder.setFragmentTexture(
          submesh.textures.normal,
          index: NormalTexture.index)

        encoder.setFragmentTexture(
          submesh.textures.roughness,
          index: RoughnessTexture.index)

        encoder.setFragmentTexture(
          submesh.textures.metallic,
          index: MetallicTexture.index)

        encoder.setFragmentTexture(
          submesh.textures.ambientOcclusion,
          index: AOTexture.index)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset
        )
      }
    }
  }
}

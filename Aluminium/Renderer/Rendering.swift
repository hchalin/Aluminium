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
        // make the structures mutable because Swift function parameters are immutable by default.
        var uniforms = vertex
        var params = fragment
        params.tiling = tiling /// Tiling is defined in `Model`

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
                // Set base color texture
                encoder.setFragmentTexture(submesh.textures.baseColor, index: BaseColor.index)
                
                // Set roughness texture
                encoder.setFragmentTexture(submesh.textures.roughness, index: RoughnessTexture.index)
                
                // Set normal texture
                encoder.setFragmentTexture(submesh.textures.normal, index: NormalTexture.index)

                // set materials from texture
                var material = submesh.material         // This is needed since `submesh.material` is const
                encoder.setFragmentBytes(&material, length: MemoryLayout<Material>.stride, index: MaterialBuffer.index)

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

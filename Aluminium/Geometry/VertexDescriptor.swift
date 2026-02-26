import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0

        /*
         Vertex 0:
         [ Px Py Pz | Nx Ny Nz ]  <- Described by the layout
         Vertex 1:
         [ Px Py Pz | Nx Ny Nz ]

         Notice how the position and normal are interleaved into one
         Vertex. The layout will describe how to step through each Vertex.
         You could add the Uv's into each Vertex if you wanted
         */
        
        /*
            Position
         */
        vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride

        /*
            Normal
        */
        vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index) // See how the normal is sent with the VertexBuffer?
        offset += MemoryLayout<float3>.stride

        vertexDescriptor.layouts[VertexBuffer.index]
            = MDLVertexBufferLayout(stride: offset)

        /*
            UVs
        */
        vertexDescriptor.attributes[UV.index] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: 0,
            bufferIndex: UVBuffer.index) // This is sent with the UVBuffer

        vertexDescriptor.layouts[UVBuffer.index]
            = MDLVertexBufferLayout(stride: MemoryLayout<float2>.stride)
        
        /*
            Tangent
         */
        vertexDescriptor.attributes[Tangent.index] = MDLVertexAttribute(
            name: MDLVertexAttributeTangent,
            format: .float3,
            offset: 0,
            bufferIndex: TangentBuffer.index
            )
        
        vertexDescriptor.layouts[TangentBuffer.index]
            = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)

        /*
            Bitangent
         */
        vertexDescriptor.attributes[Bitangent.index] = MDLVertexAttribute(
            name: MDLVertexAttributeBitangent,
            format: .float3,
            offset: 0,
            bufferIndex: BitangentBuffer.index
            )
        
        vertexDescriptor.layouts[BitangentBuffer.index]
            = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        return vertexDescriptor
    }
}

extension Attributes {
    var index: Int {
        return Int(rawValue)
    }
}

extension BufferIndices {
    var index: Int {
        return Int(rawValue)
    }
}

extension TextureIndices {
    var index: Int {
        return Int(rawValue)
    }
}

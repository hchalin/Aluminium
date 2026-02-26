// swiftlint:disable force_try

import MetalKit

class Model: Transformable {
    var transform = Transform()
    var meshes: [Mesh] = []
    var name: String = "Untitled"
    var tiling: UInt32 = 1
    var objectId: UInt32 = 0

    init() {}

    init(name: String, objectId: UInt32) {
        guard let assetURL = Bundle.main.url(
            forResource: name,
            withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }
        
        self.objectId = objectId
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(
            url: assetURL,
            vertexDescriptor: .defaultLayout,
            bufferAllocator: allocator)
        
        asset.loadTextures()
        
        var mtkMeshes: [MTKMesh] = []
        let mdlMeshes =
            asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        _ = mdlMeshes.map { mdlMesh in
            // 1
            mdlMesh.addTangentBasis(
              forTextureCoordinateAttributeNamed:
                MDLVertexAttributeTextureCoordinate,
              tangentAttributeNamed: MDLVertexAttributeTangent,
              bitangentAttributeNamed: MDLVertexAttributeBitangent)
            // 2
            mtkMeshes.append(
                try! MTKMesh(
                    mesh: mdlMesh,
                    device: Renderer.device))
        }
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        self.name = name
    }
}

extension Model {
    func setTexture(name: String, type: TextureIndices) {
        if let texture = TextureController.loadTexture(name: name) {
            switch type {
            case BaseColor:
                meshes[0].submeshes[0].textures.baseColor = texture
            default: break
            }
        }
    }
}

// swiftlint:enable force_try

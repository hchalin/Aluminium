// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast

import MetalKit

struct Mesh {
    var vertexBuffers: [MTLBuffer]
    var submeshes: [Submesh]
}

extension Mesh {
    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
        vertexBuffers = mtkMesh.vertexBuffers.map {
            $0.buffer
        }
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
            Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
        }
    }
}

// swiftlint:enable force_unwrapping
// swiftlint:enable force_cast

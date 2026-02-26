import GameController
import MetalKit

struct GameScene {
    static var objectId: UInt32 = 1

    lazy var treefir1: Model = {
        createModel(name: "treefir.usdz")
    }()

    lazy var treefir2: Model = {
        createModel(name: "treefir.usdz")
    }()

    lazy var treefir3: Model = {
        createModel(name: "treefir.usdz")
    }()

    lazy var train: Model = {
        createModel(name: "train.usdz")
    }()

    lazy var ground: Model = {
        var ground = Model(name: "ground", primitiveType: .plane)
        ground.objectId = 0
        ground.scale = 40
        ground.rotation.z = Float(270).degreesToRadians
        ground.meshes[0].submeshes[0].material.baseColor = [0.6, 0.6, 0.6]
        return ground
    }()

    var models: [Model] = []
    var camera = ArcballCamera()

    var defaultView: Transform {
        Transform(
        position: [2.2, 2.4, -3],
        rotation: [-0.36, 12.0, 0.0])
    }

    let lighting = SceneLighting()

    init() {
        camera.target = [0, 1, 0]
        camera.distance = 4
        treefir1.position = [0.5, 0, 2.5]
        treefir2.position = [-0.8, 0, -1.8]
        treefir3.position = [2, 0, -0.5]
        models = [ground, train, treefir1, treefir2, treefir3]
    }

    mutating func update(size: CGSize) {
        camera.update(size: size)
    }

    mutating func update(dT: Float) {
        let input = InputController.shared
        if input.keysPressed.contains(.one) {
            camera.transform = Transform()
        }
        if input.keysPressed.contains(.two) {
            camera.transform = defaultView
        }
        camera.update(dT: dT)
        calculateGizmo()
    }

    func createModel(name: String) -> Model {
        let model = Model(name: name, objectId: Self.objectId)
        Self.objectId += 1 // Increment obj id
        return model
    }

    mutating func calculateGizmo() {
        // Example: check whether `models` contains a model named "gizmo"
        // Adjust the predicate to match your Model's identity/equality.
        let hasGizmo = models.contains { model in
            model.name == "gizmo" || model.name == "gizmo.usdz"
        }

        // You can use the boolean as an if-condition
        if hasGizmo {
            // Do gizmo-related calculations here
            // Compute camera-aligned helper vectors
            var forwardVector: float3 {
                let lookat = float4x4(eye: camera.position, target: .zero, up: [0, 1, 0])
                return [
                    lookat.columns.0.z, lookat.columns.1.z, lookat.columns.2.z,
                ]
            }
            var rightVector: float3 {
                let lookat = float4x4(eye: camera.position, target: .zero, up: [0, 1, 0])
                return [
                    lookat.columns.0.x, lookat.columns.1.x, lookat.columns.2.x,
                ]
            }
//             gizmo.position = (forwardVector - rightVector) * 10
        }
    }
}

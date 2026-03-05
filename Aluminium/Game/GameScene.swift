import GameController
import MetalKit

struct GameScene {
    static var objectId: UInt32 = 1
    lazy var train: Model = {
      createModel(name: "train.usdz")
    }()
    lazy var treefir1: Model = {
      createModel(name: "treefir.usdz")
    }()
    lazy var treefir2: Model = {
      createModel(name: "treefir.usdz")
    }()
    lazy var treefir3: Model = {
      createModel(name: "treefir.usdz")
    }()

    lazy var ground: Model = {
        var ground = Model(name: "ground", primitiveType: .plane)
        ground.objectId = 0
        ground.scale = 40
        ground.rotation.z = Float(270).degreesToRadians
        ground.meshes[0].submeshes[0].material.baseColor = [0.6, 0.6, 0.6]
        return ground
    }()
    
    lazy var sun: Model = {
        var sun = Model(name: "sun", primitiveType: .sphere)
        sun.scale = 0.2
        sun.rotation.z = Float(270).degreesToRadians
        sun.meshes[0].submeshes[0].material.baseColor = float3(repeating: 0.9)
        return sun
    }()

    var models: [Model] = []
    var camera = ArcballCamera()

    var defaultView: Transform {
        Transform(
        position: [2.2, 2.4, -3],
        rotation: [-0.36, 12.0, 0.0])
    }

    var lighting = SceneLighting()
    
    var debugMainCamera: ArcballCamera?
    var debugShadowCamera: OrthographicCamera?
    
    var shouldDrawMainCamera = false
    var shouldDrawLightCamera = false
    var shouldDrawBoundingSphere = false
    
    var isPaused = false                    // Used to pause the game scene

    init() {
        camera.transform = defaultView
        camera.target = [0, 1, 0]
        camera.distance = 4
        treefir1.position = [0.5, 0, 2.5]
        treefir2.position = [-0.8, 0, -1.8]
        treefir3.position = [2, 0, -0.5]
        models = [treefir1, treefir2, treefir3, train, ground]
    }

    mutating func update(size: CGSize) {
        camera.update(size: size)
    }

    mutating func update(dT: Float) {
        updateInput()
        camera.update(dT: dT)
        if isPaused { return }          // Skips drawing this frame
        // Rotate light around scene
        let rotationMatrix = float4x4(rotation: [0, dT * 0.4, 0.0])
        let position = lighting.lights[0].position
        lighting.lights[0].position = (rotationMatrix * float4(position.x, position.y, position.z, 0)).xyz
        sun.position = lighting.lights[0].position
    }
    
    mutating func updateInput(){
        let input = InputController.shared
        // keys 1 or 2 reset
        if input.keysPressed.contains(.one) ||
            input.keysPressed.contains(.two){
            camera.distance = 4
            if let mainCamera = debugMainCamera{
                camera = mainCamera
                debugMainCamera = nil
                debugShadowCamera = nil
            }
            shouldDrawMainCamera = false
            shouldDrawLightCamera = false
            shouldDrawBoundingSphere = false
            isPaused = false
        }
        // If key 1 is press
        if input.keysPressed.contains(.one){
            camera.transform = Transform()
        }
        // If key 2 is pressed
        if input.keysPressed.contains(.two){
            camera.transform = defaultView
        }
        // Toggles
        if input.keysPressed.contains(.three){
            shouldDrawMainCamera.toggle()
        }
        if input.keysPressed.contains(.four){
            shouldDrawLightCamera.toggle()
        }
        if input.keysPressed.contains(.five){
            shouldDrawBoundingSphere.toggle()
        }
        
        if !isPaused {
            if shouldDrawMainCamera || shouldDrawLightCamera || shouldDrawBoundingSphere {
                isPaused = true
                debugMainCamera = camera
                debugShadowCamera = OrthographicCamera()
                debugShadowCamera?.viewSize = 16
                debugShadowCamera?.far = 16
                let sun = lighting.lights[0]
                debugShadowCamera?.position = sun.position
                camera.distance = 40
                camera.far = 50
                camera.fov = 120
            }
        }
        input.keysPressed.removeAll()

    }

    func createModel(name: String) -> Model {
        let model = Model(name: name, objectId: Self.objectId)
        Self.objectId += 1 // Increment obj id
        return model
    }

}

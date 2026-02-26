// swiftlint:disable implicitly_unwrapped_optional
import MetalKit

/// Renderer sets up Metal pipeline/state and drives per-frame rendering.
///
/// Responsibilities:
/// - Create and hold shared Metal objects (device, command queue, library)
/// - Build the render pipeline and depth/stencil state
/// - Configure the MTKView
/// - Maintain scene state and per-frame uniforms
///
/// See the MTKViewDelegate extension below for draw/resize callbacks.
class Renderer: NSObject {
    /**
     Renderer Construction
     */
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    static var viewColorPixelFormat = MTLPixelFormat.bgra8Unorm
    static var scaleFactor: CGFloat = 1

    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?

    var uniforms = Uniforms()
    var params = Params()

    init(metalView: MTKView) {
        // Acquire Metal device and create command queue
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device

        // Configure MTKView color/depth formats
        metalView.colorPixelFormat = Self.viewColorPixelFormat // Make sure this is the same as renderers
        #if os(macOS)
            Self.scaleFactor = NSScreen.main?.backingScaleFactor ?? 1
        #elseif os(iOS)
            Self.scaleFactor = metalView.traitCollection.displayScale
        #endif

        // Create shader library and look up shader entry points
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
            library?.makeFunction(name: "fragment_main")

        // Build render pipeline state (vertex layout, shaders, pixel formats)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat =
            metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor =
            MTLVertexDescriptor.defaultLayout
        do {
            pipelineState =
                try device.makeRenderPipelineState(
                    descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        // Build depth/stencil state
        depthStencilState = Renderer.buildDepthStencilState()
        super.init()
        // Final MTKView configuration and delegate hookup
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.0,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float

        // Create mtkView
        mtkView(
            metalView,
            drawableSizeWillChange: metalView.drawableSize)
        /*
         END
         */
    }

    /// Creates a depth/stencil state for depth testing (less, writes enabled).
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(
            descriptor: descriptor)
    }
}

/// MTKViewDelegate methods: handle view resizing and per-frame drawing.
///
/// - drawableSizeWillChange: Update camera/projection when the view size changes.
/// - draw(in:): Encode per-frame rendering commands and present. This is
///              called per-fram by the gamescene

extension Renderer {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        // Called on window resize
    }

    /**
        These uniforms go to both the vertex and fragment shaders.
     */
    func updateUniforms(scene: GameScene) {
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position
    }

    func draw(scene: GameScene, in view: MTKView) {
        
        // Create an auto release pool scope
        autoreleasepool {
            
            updateUniforms(scene: scene)
            
            guard
                let commandBuffer = Self.commandQueue.makeCommandBuffer(),
                let descriptor = view.currentRenderPassDescriptor,              // Render pass descriptor for render encoder
                let drawable = view.currentDrawable,
                let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
                return
            }


            renderEncoder.setDepthStencilState(depthStencilState)
            renderEncoder.setRenderPipelineState(pipelineState)

            // Add lights to fragment
            var lights = scene.lighting.lights // Grab the lights from the scene
            renderEncoder.setFragmentBytes( // Bind to fragment function in the LightBuffer idx
                &lights,
                length: MemoryLayout<Light>.stride * lights.count,
                index: LightBuffer.index
            )

            for model in scene.models {
                model.render(
                    encoder: renderEncoder,
                    uniforms: uniforms,
                    params: params)
            }


            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

// swiftlint:enable implicitly_unwrapped_optional

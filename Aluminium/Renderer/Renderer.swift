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
    static var viewColorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
    static var viewDepthPixelFormat = MTLPixelFormat.depth32Float
    static var scaleFactor: CGFloat = 1


    var uniforms = Uniforms()
    var params = Params()

    // 2 Passes
    var forwardRenderPass: ForwardRenderPass
    var objectIdRenderPass: ObjectIdRenderPass

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

        // Initialize render passes
        objectIdRenderPass = ObjectIdRenderPass()
        forwardRenderPass = ForwardRenderPass(view: metalView)

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
        objectIdRenderPass.resize(view: view, size: size)
        forwardRenderPass.resize(view: view, size: size)
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
        params.scaleFactor = Float(Self.scaleFactor)
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
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
        else {
            return
        }

        updateUniforms(scene: scene)

        // Draw
        objectIdRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)

        forwardRenderPass.descriptor = descriptor //
        forwardRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)

        // Hold onto drawable as short as possible
        guard let drawable = view.currentDrawable else {
            return // skips frame
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// swiftlint:enable implicitly_unwrapped_optional

//
//  ForwardRenderPass.swift
//  Aluminium
//
//  Created by Hayden Chalin on 2/26/26.
//

import MetalKit

struct ForwardRenderPass : RenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?

    var pipelineState: MTLRenderPipelineState
    var depthStencilState: MTLDepthStencilState?

    init(view: MTKView) {
        pipelineState = PipelineStates.createForwardPSO()
        // This render pass will have a depth state applied to the encoder
        depthStencilState = Self.buildDepthStencilState()
    }

    mutating func resize(view: MTKView, size: CGSize) {
    }

    func draw(commandBuffer: MTLCommandBuffer,
              scene: GameScene,
              uniforms: Uniforms,
              params: Params) {
        
            guard let descriptor = descriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else{
                return
            }
            
            renderEncoder.label = label
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setDepthStencilState(depthStencilState)
            
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
        }
}

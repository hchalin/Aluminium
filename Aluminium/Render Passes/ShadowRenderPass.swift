//
//  ShadowPass.swift
//  Aluminium
//
//  Created by Hayden Chalin on 3/6/26.
//

import MetalKit

struct ShadowRenderPass: RenderPass {
    let label = "Shadow Pass"
    var descriptor: MTLRenderPassDescriptor?
    var pipelineState: MTLRenderPipelineState
    var depthStencilState: MTLDepthStencilState?
    var shadowTexture: MTLTexture?
    
    init(){
        descriptor = MTLRenderPassDescriptor()
        depthStencilState = Self.buildDepthStencilState()
        pipelineState = PipelineStates.createShadowPSO()
        shadowTexture = Self.makeTexture(size: CGSize(width: 2048,height: 2048), pixelFormat: .depth32Float, label: "Shadow Depth Texture")
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
        /*
         Unlike other render passes, where you match the view’s size, shadow maps are usually square to match the light’s cuboid orthographic camera, so you don’t need to resize the texture when the window resizes. The resolution should be as much as your game resources budget allows to produce sharper shadows.
         */
    }
    
    func draw(commandBuffer: any MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params) {
        guard let descriptor = descriptor else {return}
        descriptor.depthAttachment.texture = shadowTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = "Shadow Encoder"
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        for model in scene.models {
            renderEncoder.pushDebugGroup(model.name)
            model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
            renderEncoder.popDebugGroup()
        }
        renderEncoder.endEncoding()
    }
}

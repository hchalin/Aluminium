//
//  DifferedRenderPass.swift
//  Aluminum
//
//  Created by Hayden Chalin on 11/14/26.
//

import Foundation
import MetalKit

struct GBufferRenderPass : RenderPass {
	let label = "G-Buffer Render Pass"
	
	// Textures
	var albedoTexture: MTLTexture?
	var normalTexture: MTLTexture?
	var positionTexture: MTLTexture?
	var depthTexture: MTLTexture?
	weak var shadowTexture: MTLTexture?
	
	
	var descriptor: MTLRenderPassDescriptor?
	var pipelineState: MTLRenderPipelineState
	let depthStencilState: MTLDepthStencilState?
	
	
	init(view: MTKView){
		depthStencilState = Self.buildDepthStencilState()
		// TODO: update this to "createGBufferPSO()" after creation
		pipelineState = PipelineStates.createForwardPSO()
		descriptor = MTLRenderPassDescriptor()
	}
	
	mutating func resize(view: MTKView, size: CGSize) {
		albedoTexture = Self.makeTexture(size: size, pixelFormat: .bgra8Unorm, label: "Albedo Texture")
		normalTexture = Self.makeTexture(size: size, pixelFormat: .rgba16Float, label: "Normal Texture")
		positionTexture = Self.makeTexture(size: size, pixelFormat: .rgba16Float, label: "Position Texture")
		depthTexture = Self.makeTexture(size: size, pixelFormat: .depth32Float, label: "Depth Texture")
	}
	
	func draw(commandBuffer: any MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params) {
		let textures = [albedoTexture, normalTexture, positionTexture]
		
		for (index, texture) in textures.enumerated() {
			let attatchment = descriptor?.colorAttachments[RenderTargetAlbedo.index + index]
			attatchment?.texture = texture
			attatchment?.loadAction = .clear
			attatchment?.storeAction = .store
			attatchment?.clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
		}
		descriptor?.depthAttachment.texture = depthTexture
		descriptor?.depthAttachment.storeAction = .dontCare
		
		// Assign the descriptor only if the command buffer can create a command encoder
		guard let descriptor = descriptor,
					let renderEncoder =
						commandBuffer.makeRenderCommandEncoder(
								descriptor: descriptor) else {
				return
		}
		renderEncoder.label = label
		renderEncoder.setDepthStencilState(depthStencilState)
		renderEncoder.setRenderPipelineState(pipelineState)
		
		renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
		
		for model in scene.models {
				renderEncoder.pushDebugGroup(model.name)
				model.render(
						encoder: renderEncoder,
						uniforms: uniforms,
						params: params)
				renderEncoder.popDebugGroup()
		}
		
		renderEncoder.endEncoding()
		
	}
	
	
}

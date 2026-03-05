//
//  Pipelines.swift
//  Aluminium
//
//  Created by Hayden Chalin on 2/26/26.
//

import MetalKit

/**
    enumeration that holds static functions to create the differene PSO's in the engine
 */
enum PipelineStates {
    static func createPSO(descriptor: MTLRenderPipelineDescriptor)
        -> MTLRenderPipelineState {
        let pipelineState: MTLRenderPipelineState
        do {
            try pipelineState = Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }

    static func createForwardPSO() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
        let fragementFunction = Renderer.library?.makeFunction(name: "fragment_main")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragementFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.viewColorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = Renderer.viewDepthPixelFormat
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        return Self.createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createObjectIdPSO() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_objectId")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .r32Uint
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        return Self.createPSO(descriptor: pipelineDescriptor)
    }
}

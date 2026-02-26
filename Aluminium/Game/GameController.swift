//
//  GameController.swift
//  Aluminium
//
//  Created by Hayden Chalin on 2/10/26.
//

import MetalKit

class GameController: NSObject {
    var scene: GameScene
    var renderer: Renderer
    var fps: Double = 0
    var dT: Double = 0
    var lastTime: Double = CFAbsoluteTimeGetCurrent()

    init(metalView: MTKView) {
        renderer = Renderer(metalView: metalView)
        scene = GameScene()
        super.init()
        metalView.delegate = self
        fps = Double(metalView.preferredFramesPerSecond)
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
}

extension GameController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
        renderer.mtkView(view, drawableSizeWillChange: size)
    }

    // Override 
    func draw(in view: MTKView) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let dT = (currentTime - lastTime)
        lastTime = currentTime
        scene.update(dT: Float(dT)) // Update the GameScene per frame
        renderer.draw(scene: scene, in: view)
    }
}

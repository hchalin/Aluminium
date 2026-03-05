//
//  OrthographicCamera.swift
//  Aluminium
//
//  Created by Hayden Chalin on 3/5/26.
//

import CoreGraphics

struct OrthographicCamera: Camera, Movement {
    var transform = Transform()
    var aspect: CGFloat = 1
    var viewSize: CGFloat = 10
    var near: Float = 0.1
    var far: Float = 100
    var center = float3.zero

    var viewMatrix: float4x4 {
        (float4x4(translation: position) *
            float4x4(rotation: rotation)).inverse
    }

    var projectionMatrix: float4x4 {
        let rect = CGRect(
            x: -viewSize * aspect * 0.5,
            y: viewSize * 0.5,
            width: viewSize * aspect,
            height: viewSize)
        return float4x4(orthographic: rect, near: near, far: far)
    }

    mutating func update(size: CGSize) {
        aspect = size.width / size.height
    }

    mutating func update(dT: Float) {
        let transform = updateInput(dT: dT)
        position += transform.position
        let input = InputController.shared
        let scrollSensitivity = Settings.mouseScrollSensitivity
        let zoom = input.mouseScroll.x * scrollSensitivity
            + input.mouseScroll.y * scrollSensitivity
        viewSize -= CGFloat(zoom)
        input.mouseScroll = .zero
    }
}

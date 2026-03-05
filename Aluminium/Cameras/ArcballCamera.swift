//
//  ArcballCamera.swift
//  Aluminium
//
//  Created by Hayden Chalin on 3/5/26.
//

import Foundation

struct ArcballCamera: Camera {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }
  let minDistance: Float = 0.01
  let maxDistance: Float = 20
  var target: float3 = [0, 0, 0]
  var distance: Float = 2.5

  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  var viewMatrix: float4x4 {
    float4x4(eye: position, target: target, up: [0, 1, 0])
  }

  mutating func update(dT: Float) {
    let input = InputController.shared
    let scrollSensitivity = Settings.mouseScrollSensitivity
    distance -= (input.mouseScroll.x + input.mouseScroll.y)
      * scrollSensitivity
    distance = min(maxDistance, distance)
    distance = max(minDistance, distance)
    input.mouseScroll = .zero
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
      input.mouseDelta = .zero
    }
    let rotateMatrix = float4x4(
      rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotateMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}

//
//  SceneLighting.swift
//  Aluminium
//
//  Created by Hayden Chalin on 2/16/26.
//

struct SceneLighting {
    
    /**
     Creates a default light
     - Returns: A defualt `Light`
     */
    static func buildDefaultLight()-> Light {
        var light = Light()
        light.position = [0,0,0]
        light.color = [1, 1, 1] // White
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Sun
        return light
    }
    
    let sunLight: Light = {
        var light = Self.buildDefaultLight()
        light.position = [3, 3, -2]
        light.intensity = 0.9
        return light
    }()
    let ambientLight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Ambient
        light.color = float3(repeating: 1.0)
        light.intensity = 0.3
        return light
    }()
    let redPointLight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Point
        light.position = [-0.8, 0.76, -0.18]
        light.color = [1, 0, 0]
        light.attenuation = [0.5, 2, 1]
        return light
    }()
    lazy var spotlight: Light = {
      var light = Self.buildDefaultLight()
      light.type = Spot
      light.position = [-0.64, 0.64, -1.07]
      light.color = [1, 0, 1]
      light.attenuation = [1, 0.5, 0]
      light.coneAngle = Float(30).degreesToRadians
      light.coneDirection = [0.5, -0.7, 1]
      light.coneAttenuation = 8
      return light
    }()
    
    var lights: [Light] = []
    
    init() {
        lights.append(sunLight)
        lights.append(ambientLight)
    }
}

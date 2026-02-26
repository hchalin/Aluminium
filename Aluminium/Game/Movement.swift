import GameController // for .leftArrow...

enum Settings {
    static var rotationSpeed: Float { 2.0 }
    static var translationSpeed: Float { 3.0 }
    static var mouseScrollSensitivity: Float { 0.1 }
    static var mousePanSensitivity: Float { 0.008 }
    static var touchZoomSensitivity: Float { 10 }
}

protocol Movement where Self: Transformable {
    /*
     Your game might move a player object instead of a camera, so make the movement code as flexible as possible.
     Now you can give any Transformable object Movement.
     */
}

extension Movement {
    // Forward Vector - computed variable
    var forwardVector: float3 {
        normalize([sin(rotation.y), 0, cos(rotation.y)]) // This forward vector is based off curr rotation
    }

    // Right Vector - computed variable off of forward vector
    var rightVector: float3 {
        normalize([forwardVector.z, forwardVector.y, -forwardVector.x])
    }

    /**
     Update function called by `Camera's` update function.
     This function updates the cameras `Transform` and returns it.
      */
    func updateInput(dT: Float) -> Transform {
        var transform = Transform() // This will be the new transform returned
        let rotationAmount = dT * Settings.rotationSpeed
        let input = InputController.shared // Access shared input controller singleton
        if input.keysPressed.contains(.leftArrow) {
            transform.rotation.y -= rotationAmount
        }
        if input.keysPressed.contains(.rightArrow) {
            transform.rotation.y += rotationAmount
        }
        /*
         Create abstract direction vector (will be normalized)
         -> update direction components
         */
        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {
            direction.z += 1
        }
        if input.keysPressed.contains(.keyS) {
            direction.z -= 1
        }
        if input.keysPressed.contains(.keyD) {
            direction.x += 1
        }
        if input.keysPressed.contains(.keyA) {
            direction.x -= 1
        }
        // Movement speed
        let translationAmount = dT * Settings.translationSpeed
        // Check to see if its actually updated
        if direction != .zero {
            direction = normalize(direction) // Normalize the vector
            /*
             The position transform is calc'd as follows:
             1: vector mul of z comp of direction vec w/ forward vec
             2: vector mul of x comp of direction vec w/ right vec
             3: combine those to vectors with addition
             4: multiply the matrix by translation amount
             */
            transform.position +=
                (
                    (direction.z * forwardVector) +
                        (direction.x * rightVector)
                )
                * translationAmount
        }
        return transform
    }
}

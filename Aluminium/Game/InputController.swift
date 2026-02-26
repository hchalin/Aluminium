import GameController

class InputController {
    struct Point {
        var x: Float
        var y: Float
        static var zero = Point(x: 0, y: 0) // Singleton?
    }

    static let shared = InputController() // Create a singleton of input controller
    var keysPressed: Set<GCKeyCode> = [] // A set is O(1) (hash based)
    var leftMouseDown = false
    var mouseDelta: Point = Point.zero
    var mouseScroll: Point = Point.zero
    var touchLocation: CGPoint?
    var touchDelta: CGSize? {
      didSet {
        touchDelta?.height *= -1
        if let delta = touchDelta {
          mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
        }
        leftMouseDown = touchDelta != nil
      }
    }


    // Note the private initializer - You cannot create another instance from outside the class.
    private init() {
        // 1) Get the shared NotificationCenter instance.
        //    This is the central hub for posting and observing notifications.
        let center = NotificationCenter.default

        // 2) Register an observer for the "controller connected" notification.
        //    - forName: The specific notification you care about (.GCControllerDidConnect)
        //    - object: Limit to notifications from a specific sender (nil = accept from any)
        //    - queue: Which OperationQueue the closure runs on (nil = post on the same queue as the sender)
        //    - using: The closure called when the notification is received. It gets a Notification object.
        center.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil,
            queue: nil
        ) { notification in // Trailing closure: receives the Notification when .GCControllerDidConnect is posted
            // 3) Extract the object that posted the notification.
            //    In this case, we expect it to be a GCKeyboard (if a keyboard connected).
            let keyboard = notification.object as? GCKeyboard

            // 4) Access the keyboard's input interface to receive per-key events.
            //    keyChangedHandler is a closure that gets called whenever a key changes state.
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                // Parameters of keyChangedHandler:
                // - the first two underscores are unused parameters (device/input), so we ignore them
                // - keyCode: which key changed (a GCKeyCode)
                // - pressed: true if the key is now down, false if it’s up

                if pressed {
                    // 5) On key down, insert the key code into our set.
                    //    Set ensures uniqueness and fast membership checks.
                    self.keysPressed.insert(keyCode)
                } else {
                    // 6) On key up, remove the key code from our set.
                    self.keysPressed.remove(keyCode)
                }
            }
        }

        // Get rid of beeps when typing on keyboard
        #if os(macOS)
            NSEvent.addLocalMonitorForEvents(
                matching: [.keyUp, .keyDown]
            ) { _ in nil }
        #endif

        center.addObserver(
            forName: .GCMouseDidConnect,
            object: nil,
            queue: nil
        ) { notification in
            let mouse = notification.object as? GCMouse

            // 1
            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.leftMouseDown = pressed
            }

            // 2
            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                self.mouseDelta = Point(x: deltaX, y: deltaY)
            }

            // 3
            mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in
                self.mouseScroll.x = xValue
                self.mouseScroll.y = yValue
            }
        }
    }
}

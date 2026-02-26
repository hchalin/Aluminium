import SwiftUI

struct ContentView: View {
  @State private var previousTranslation = CGSize.zero
  @State private var previousScroll: CGFloat = 1

  var body: some View {
    VStack {
      MetalView()
        .border(Color.black, width: 2)
        .gesture(DragGesture(minimumDistance: 0)
          .onChanged { value in
            InputController.shared.touchLocation = value.location
            InputController.shared.touchDelta = CGSize(
              width: value.translation.width - previousTranslation.width,
              height: value.translation.height - previousTranslation.height)
            previousTranslation = value.translation
            // if the user drags, cancel the tap touch
            if abs(value.translation.width) > 1 ||
              abs(value.translation.height) > 1 {
              InputController.shared.touchLocation = nil
            }
          }
          .onEnded {_ in
            previousTranslation = .zero
          })
        .gesture(MagnificationGesture()
          .onChanged { value in
            let scroll = value - previousScroll
            InputController.shared.mouseScroll.x = Float(scroll)
              * Settings.touchZoomSensitivity
            previousScroll = value
          }
          .onEnded {_ in
            previousScroll = 1
          })
        .onAppear {
        #if os(macOS)
          NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let scrollX = Float(event.scrollingDeltaX)
            InputController.shared.mouseScroll.x = scrollX
            let scrollY = Float(event.scrollingDeltaY)
            InputController.shared.mouseScroll.y = scrollY
            return event
          }
        #endif
        }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}

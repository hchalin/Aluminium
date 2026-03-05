import CoreGraphics

/**
  Camera conforms to a `Transformable`, when you create
  a instance of a camera, you must conform to BOTH `Camera` and
  `Transform`.
 */
protocol Camera: Transformable {
  var projectionMatrix: float4x4 { get }
  var viewMatrix: float4x4 { get }
  mutating func update(size: CGSize)
  mutating func update(dT: Float)
}








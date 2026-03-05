import MetalKit

enum TextureController {
  static var textures: [String: MTLTexture] = [:]

  /// Loads an `MDLTexture` into a Metal `MTLTexture`, caching the result by name.
  ///
  /// If a texture with the provided `name` has already been loaded, this method
  /// returns the cached `MTLTexture` instead of creating a new one. Otherwise, it
  /// uses `MTKTextureLoader` to create a new texture from the given `MDLTexture`.
  /// The loader is configured with a bottom-left origin to match typical graphics
  /// coordinate systems.
  ///
  /// - Parameters:
  ///   - texture: The source `MDLTexture` to convert into a `MTLTexture`.
  ///   - name: A unique key used to cache and retrieve the resulting texture.
  /// - Returns: The loaded `MTLTexture` if creation succeeds; otherwise, `nil`.
  /// - Note: On success, the texture is stored in `TextureController.textures`
  ///   under the provided `name` for reuse.
  static func loadTexture(texture: MDLTexture, name: String) -> MTLTexture? {
    // 1 If the texture has already been loaded into textures, return it.
    if let texture = textures[name] {
      return texture
    }
    // 2 Create a texture loader using MetalKit’s MTKTextureLoader.
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    // 3 Change the texture’s origin option to ensure that the texture loads with its origin at the bottom-left.
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
      [.origin: MTKTextureLoader.Origin.bottomLeft,
       .generateMipmaps: true]
    // 4 Create a new MTLTexture using the provided texture and loader options. For debugging purposes, print a message
    let texture = try? textureLoader.newTexture(
      texture: texture,
      options: textureLoaderOptions)
    print("loaded texture from USD file")
    // 5 Add the texture to textures and return it
    textures[name] = texture
    return texture
  }
  
  ///    Loads a texture from the asset catalog
  ///   - Parameters
  ///     - name: A unique key to retrieve resulting texture
  ///   - Returns  The loaded  `MTLTexture`
  static func loadTexture(name: String) -> MTLTexture? {
    // Return the texture if it alread exists
    if let texture = textures[name] {
        return texture
    }
    // Create the texture
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    let texture: MTLTexture?
    texture = try? textureLoader.newTexture(
      name: name,
      scaleFactor: 1.0,
      bundle: Bundle.main,
      options: nil
      )
    if texture != nil {
      print("Loaded texture: \(name)")
      textures[name] = texture
    }
    return texture
  }
}


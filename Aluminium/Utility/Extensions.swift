//
//  Extensions.swift
//  Aluminum
//
//  Created by Hayden Chalin on 11/14/26.
//

/// Index helpers for enums defined in `common.h`.
/// See `Attributes`, `BufferIndices`, `TextureIndices`, `RenderTargetTextureIndices`.

extension Attributes {
		var index: Int {
				return Int(rawValue)
		}
}

extension BufferIndices {
		var index: Int {
				return Int(rawValue)
		}
}

extension TextureIndices {
		var index: Int {
				return Int(rawValue)
		}
}

extension RenderTargetTextureIndices {
	var index: Int {
		return Int(rawValue)
	}
}

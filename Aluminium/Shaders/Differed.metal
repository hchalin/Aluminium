//
//  Differed.metal
//  Aluminum
//
//  Created by Hayden Chalin on 11/14/26.
//

#include "ShaderDefs.h"


constant float3 topLeft = {-1.0, 1.0, 0.0};
constant float3 topRight = {1.0, 1.0, 0.0};
constant float3 bottomLeft = {-1.0, -1.0, 0.0};
constant float3 bottomRight = {-1.0, -1.0, 0.0};

constant float3 vertices[6] = {
	// First Triangle
	topLeft, bottomRight, bottomLeft,
	// Second Triangle
	topLeft, topRight, bottomRight
};

vertex VertexOut vertx_quad(uint vertexId [[vertex_id]]){
	VertexOut out {
		.position = float4(vertices[vertexId], 1)
	};
	return out;
}

// TODO: Set fragment bytes and read textures at coords location for lighting calcs
// TODO: Reference difuse lighting / PBR project for ref material
fragment float4 fragment_gbuff(VertexOut in [[stage_in]]){
	
	// Get the coords from the staged vertex
	uint2 coords = uint2(in.position.xy);
	
}

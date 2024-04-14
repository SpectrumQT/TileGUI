// Draws all tiles on screen

#include "instance_model.hlsl"
#include "tile_model.hlsl"

struct vs2gs {
	uint vertex_id : TEXCOORD0;
};

struct gs2ps {
	float4 pos : SV_Position0;
	float2 uv : TEXCOORD1;
	float texture_index : PSIZE0;
	float tex_arr_id : PSIZE1;
};


#ifdef VERTEX_SHADER
void main(uint vertex_id : SV_VertexID, out vs2gs output)
{
	output.vertex_id = vertex_id;
}
#endif


#ifdef GEOMETRY_SHADER

StructuredBuffer<Instance> InstanceContainer : register(t121);
#define CurrentInstance InstanceContainer[0]

StructuredBuffer<Tile> Tiles : register(t122);

// Here we devide MaxTilesCount (128, 256, 512 or 1024) by the number of geometry shader instances (32)
#define OutputTilesPerInstance (CurrentInstance.max_tiles_count / 32)

// Packs unsigned float with max integer part of 999 into another unsigned integer
float Pack(uint integer_var, float float_var)
{
	return integer_var * 1000 + abs(float_var) % 1000;
}

// Our aim is to draw the whole GUI layer of 1024 tiles per vertex on input
// Each tile consists of 4 vertices (2 triangles)
// Each geometry shader invocation will output up to 128 vertices (32 tiles)
// So we'll use 32 instances, making total of 32 * 32 = 1024 tiles
[instance(32)]
// Our gs2ps has size of 8, and maxvertexcount * sizeof(gs2ps) cannot exceed 1024, thus 1024 / 8 = 128
// Note: While UV and tex ids could be packed to unused pos floats, marginal performance gain doesn't worth the precision loss
[maxvertexcount(128)]
void main(uint instance_id : SV_GSInstanceID, point vs2gs input[1], inout TriangleStream<gs2ps> triangle_stream)
{
	int layer_id = input[0].vertex_id;

	gs2ps output;

	for (int i = 0; i < OutputTilesPerInstance; i++) {
		int tile_id = instance_id * OutputTilesPerInstance + i;

		Tile tile = Tiles[tile_id];

		if (tile.sys_state_id == 0 || tile.show != 1 || tile.texture_id == -1) {
			continue;
		}

		if (tile.layer_id != layer_id) {
			continue;
		}
		
		output.texture_index = Pack(tile.texture_id - 64, tile.opacity); // Pack opacity as floating point value
		output.tex_arr_id = Pack(tile.tex_arr_id, tile.saturation); // Pack saturation as floating point value

		output.pos = float4(tile.rel_pos.x, tile.rel_pos.w, 1, 1); // X, Y, Z coord and View Space Depth
		output.uv = float2(tile.tex_uv.x, tile.tex_uv.y); // X, Y
		triangle_stream.Append(output);

		output.pos = float4(tile.rel_pos.x, tile.rel_pos.y, 1, 1); // X, Y, Z coord and View Space Depth
		output.uv = float2(tile.tex_uv.x, tile.tex_uv.w); // X, Y
		triangle_stream.Append(output);

		output.pos = float4(tile.rel_pos.z, tile.rel_pos.w, 1, 1); // X, Y, Z coord and View Space Depth
		output.uv = float2(tile.tex_uv.z, tile.tex_uv.y); // X, Y
		triangle_stream.Append(output);

		output.pos = float4(tile.rel_pos.z, tile.rel_pos.y, 1, 1); // X, Y, Z coord and View Space Depth
		output.uv = float2(tile.tex_uv.z, tile.tex_uv.w); // X, Y
		triangle_stream.Append(output);

		triangle_stream.RestartStrip();
	}
}

#endif


#ifdef PIXEL_SHADER

Texture2DArray<float4> ImageTextures[64] : register(t64);

SamplerState LinearSampler : register(s0);

float4 Saturate(float4 color, float saturation)
{
    float3 luminance_weights = float3(0.299, 0.587, 0.114);
    float luminance = dot(color.rgb, luminance_weights);
    return float4(lerp(luminance, color.rgb, saturation), color.a);
}

void main(gs2ps input, out float4 result : SV_Target0)
{
	result.xyzw = 0;
	uint texture_index = uint(input.texture_index / 1000);

	[unroll]
	for (uint i = 0; i < 64; i++) {
		if (texture_index == i) {
			// Unpack opacity and saturation
			uint tex_arr_id = uint(input.tex_arr_id / 1000);
			float opacity = input.texture_index % 1000;
			float saturation = input.tex_arr_id % 1000;
			
			// Get pixel float4 RGBA color from texture
			result = ImageTextures[i].Sample(LinearSampler, float3(input.uv, tex_arr_id));

			// Blend opacity setting
			if (opacity != 1) {
				result.a *= opacity;
			}
			// Blend saturation setting
			if (saturation != 1) {
				result = Saturate(result, saturation);
			}

			return;
		}
	}
}

#endif

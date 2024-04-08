Buffer<float4> IniParams : register(t120);

#define RequestType IniParams[1].x
#define TileId IniParams[1].y
#define VarId IniParams[1].z

struct Instance {
	float max_tiles_count;
	float max_layers_count;
	float2 unused1;

    float drag_tile_id;
	float2 drag_pos;
	float unused2;
    
	float4 unused3;
};
StructuredBuffer<Instance> InstanceContainer : register(t121);
#define Instance InstanceContainer[0]

struct Tile {
    // Base config
	float sys_state_id;
	float layer_id;
	float parent_tile_id;
	float template_id;
    // Features config
	float show;
	float select;
	float clamp;
	float track_mouse;
    // Advanced features config
    float loop_start;
    float loop_method;
    float hover_overlay_tile_id;
    float select_overlay_tile_id;
    // Display config
	float2 size;
	float texture_id;
	float tex_arr_id;
    // Texture config
    float4 tex_uv;
	// Texture config 2
	float opacity;
	float saturation;
	float2 reserved_1;
    // Layout config
	float2 offset;
	float2 anchor;
    // Current state
    float loop_stage;
	float is_hovered_over;
	float2 reserved_2;
    // Absolute coords of current position
	float4 abs_pos;
    // Relative coords of current position
	float4 rel_pos;
};
StructuredBuffer<Tile> Tiles : register(t122);
RWBuffer<float> OutputRW : register(u0);
//RWBuffer<float4> DebugRW : register(u7);

float GetTileVar()
{
    if (TileId == 100000) {
        return 100000;
    }
    Tile tile = Tiles[TileId];
    if (VarId == 0) {
        return tile.sys_state_id;
    } else if (VarId == 1) {
        return tile.layer_id;
    } else if (VarId == 2) {
        return tile.parent_tile_id;
    } else if (VarId == 3) {
        return tile.template_id;
    } else if (VarId == 4) {
        return tile.show;
    } else if (VarId == 5) {
        return tile.select;
    } else if (VarId == 6) {
        return tile.clamp;
    } else if (VarId == 7) {
        return tile.track_mouse;
    } else if (VarId == 8) {
        return tile.loop_start;
    } else if (VarId == 9) {
        return tile.loop_method;
    } else if (VarId == 10) {
        return tile.hover_overlay_tile_id;
    } else if (VarId == 11) {
        return tile.select_overlay_tile_id;
    } else if (VarId == 12) {
        return tile.size.x;
    } else if (VarId == 13) {
        return tile.size.y;
    } else if (VarId == 14) {
        return tile.texture_id;
    } else if (VarId == 15) {
        return tile.tex_arr_id;
    } else if (VarId == 16) {
        return tile.tex_uv.x;
    } else if (VarId == 17) {
        return tile.tex_uv.y;
    } else if (VarId == 18) {
        return tile.tex_uv.z;
    } else if (VarId == 19) {
        return tile.tex_uv.w;
    } else if (VarId == 20) {
        return tile.opacity;
    } else if (VarId == 21) {
        return tile.saturation;
    // } else if (VarId == 22) {
    //     return tile.reserved_1.x;
    // } else if (VarId == 23) {
    //     return tile.reserved_1.y;
    } else if (VarId == 24) {
        return tile.offset.x;
    } else if (VarId == 25) {
        return tile.offset.y;
    } else if (VarId == 26) {
        return tile.anchor.x;
    } else if (VarId == 27) {
        return tile.anchor.y;
    } else if (VarId == 28) {
        return tile.loop_stage;
    } else if (VarId == 29) {
        return tile.is_hovered_over;
    // } else if (VarId == 30) {
    //     return tile.reserved_2;
    // } else if (VarId == 31) {
    //     return tile.reserved_2;
    } else if (VarId == 32) {
        return tile.abs_pos.x;
    } else if (VarId == 33) {
        return tile.abs_pos.y;
    } else if (VarId == 34) {
        return tile.abs_pos.z;
    } else if (VarId == 35) {
        return tile.abs_pos.w;
    } else {
        return 100000;
    }
}

float GetHoveredOverTileId()
{
	float hovered_tile_id = -1;
	float layer_id = -1;
	for (int tile_id = Instance.max_tiles_count; tile_id > -1; tile_id--) {
		Tile tile = Tiles[tile_id];
		if (tile.is_hovered_over == 1) {
			if (tile.layer_id > layer_id) {
				layer_id = tile.layer_id;
				hovered_tile_id = tile_id;
			}
		};
	}
	return hovered_tile_id;
}

float GetSliderValue()
{
    if (TileId == 100000) {
        return 100000;
    }
    Tile tile = Tiles[TileId];
    if (tile.parent_tile_id == -1) {
        return 100000;
    }
    Tile parent_tile = Tiles[tile.parent_tile_id];
    if (parent_tile.size.x > parent_tile.size.y) {
        return (tile.abs_pos.x - parent_tile.abs_pos.x) / (parent_tile.size.x - tile.size.x);
    } else {
        return (tile.abs_pos.y - parent_tile.abs_pos.y) / (parent_tile.size.y - tile.size.y);
    }
}

// #ifdef COMPUTE_SHADER

[numthreads(1,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
	switch(RequestType) {
		// GetTileVar
		case 1:
            OutputRW[33] = GetTileVar();
			break;
		// GetHoveredOverTileId
		case 2:
            OutputRW[33] = GetHoveredOverTileId();
			break;
        // GetSliderValue
		case 3:
            OutputRW[33] = GetSliderValue();
			break;
		// Unknown
		default:
            OutputRW[33] = 100000;
			break;
	};
}

// #endif

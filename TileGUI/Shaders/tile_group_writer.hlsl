// Streamlines multiple tiles declaration and property updates both for initialization and runtime

Buffer<float4> IniParams : register(t120);

#define RequestType (IniParams[0].x != 100000 ? IniParams[0].x : -1)
#define TemplateId (IniParams[0].y != 100000 ? IniParams[0].y : -1)
#define ParentTileId (IniParams[0].z != 100000 ? IniParams[0].z : -1000)

#define FirstTileId (IniParams[1].x != 100000 ? IniParams[1].x : -1)
#define LastTileId (IniParams[1].y != 100000 ? IniParams[1].y : FirstTileId)

#define CreateTiles (IniParams[2].x != 100000 ? IniParams[2].x : 0)
#define SkipExistingTiles (IniParams[2].y != 100000 ? IniParams[2].y : 0)

#define ColsCount (IniParams[3].x != 100000 ? IniParams[3].x : -1)
#define RowsCount (IniParams[3].y != 100000 ? IniParams[3].y : -1)
#define ColsPadding (IniParams[3].z != 100000 ? IniParams[3].z : 0)
#define RowsPadding (IniParams[3].w != 100000 ? IniParams[3].w : 0)

#define AnchorX (IniParams[4].x != 100000 ? IniParams[4].x : 0)
#define AnchorY (IniParams[4].y != 100000 ? IniParams[4].y : 0)

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
RWStructuredBuffer<Tile> TileTemplateDataRW : register(u0);
RWStructuredBuffer<Tile> TilesRW : register(u1);
//RWBuffer<float4> DebugRW : register(u7);

void InitializeTile(inout Tile tile)
{
    // Base config
    tile.sys_state_id = 1;
    tile.layer_id = 0;
    tile.parent_tile_id = -1;
    tile.template_id = -1;
    // Features config
    tile.show = 1;
    tile.select = 0;
    tile.clamp = 1;
    tile.track_mouse = 1;
    // Advanced features config
    tile.loop_start = -1;
    tile.loop_method = -1;
    tile.hover_overlay_tile_id = -1;
    tile.select_overlay_tile_id = -1;
    // Display config
    tile.size = 0;
    tile.texture_id = -1;
    tile.tex_arr_id = 0;
    // Texture config
    tile.tex_uv = float4(0, 0, 1, 1);
    // Texture config 2
    tile.opacity = 1;
    tile.saturation = 1;
    tile.reserved_1 = 0;
    // Layout config
    tile.offset = 0;
    tile.anchor = 0;
    // Current state
    tile.loop_stage = 0;
    tile.is_hovered_over = 0;
    tile.reserved_2 = 0;
    // Absolute coords of current position
    tile.abs_pos = 0;
    // Relative coords of current position
    tile.rel_pos = 0;
}

void LoadDataUpdate(Tile tile_data, inout Tile tile)
{
    // Base config
	if (tile_data.sys_state_id != 100000) {
		tile.sys_state_id = tile_data.sys_state_id;
	}
    if (tile_data.layer_id != 100000) {
        tile.layer_id = tile_data.layer_id;
    }
    if (tile_data.parent_tile_id != 100000) {
        tile.parent_tile_id = tile_data.parent_tile_id;
    }
    if (tile_data.template_id != 100000) {
        tile.template_id = tile_data.template_id;
    }
    // Features config
    if (tile_data.show != 100000) {
        tile.show = tile_data.show;
    }
    if (tile_data.select != 100000) {
        tile.select = tile_data.select;
    }
    if (tile_data.clamp != 100000) {
        tile.clamp = tile_data.clamp;
    }
    if (tile_data.track_mouse != 100000) {
        tile.track_mouse = tile_data.track_mouse;
    }
    // Advanced features config
	if (tile_data.loop_start != 100000) {
		tile.loop_start = tile_data.loop_start;
	}
    if (tile_data.loop_method != 100000) {
        tile.loop_method = tile_data.loop_method;
    }
    if (tile_data.hover_overlay_tile_id != 100000) {
        tile.hover_overlay_tile_id = tile_data.hover_overlay_tile_id;
    }
    if (tile_data.select_overlay_tile_id != 100000) {
        tile.select_overlay_tile_id = tile_data.select_overlay_tile_id;
    }
    // Display config
    if (tile_data.size.x != 100000) {
        tile.size.x = tile_data.size.x;
    }
    if (tile_data.size.y != 100000) {
        tile.size.y = tile_data.size.y;
    }
    if (tile_data.texture_id != 100000) {
        tile.texture_id = tile_data.texture_id;
    }
    if (tile_data.tex_arr_id != 100000) {
        tile.tex_arr_id = tile_data.tex_arr_id;
    }
    // Texture config
    if (tile_data.tex_uv.x != 100000) {
        tile.tex_uv.x = tile_data.tex_uv.x;
    }
    if (tile_data.tex_uv.y != 100000) {
        tile.tex_uv.y = tile_data.tex_uv.y;
    }
    if (tile_data.tex_uv.z != 100000) {
        tile.tex_uv.z = tile_data.tex_uv.z;
    }
    if (tile_data.tex_uv.w != 100000) {
        tile.tex_uv.w = tile_data.tex_uv.w;
    }
    // Texture config 2
    if (tile_data.opacity != 100000) {
        tile.opacity = tile_data.opacity;
    }
    if (tile_data.saturation != 100000) {
        tile.saturation = tile_data.saturation;
    }
    // tile_data.reserved_1 = 0;
    // Layout config
    if (tile_data.offset.x != 100000) {
        tile.offset.x = tile_data.offset.x;
    }
    if (tile_data.offset.y != 100000) {
        tile.offset.y = tile_data.offset.y;
    }
    if (tile_data.anchor.x != 100000) {
        tile.anchor.x = tile_data.anchor.x;
    }
    if (tile_data.anchor.y != 100000) {
        tile.anchor.y = tile_data.anchor.y;
    }
    // Current state
    if (tile_data.loop_stage != 100000) {
        tile.loop_stage = tile_data.loop_stage;
    }
    // if (tile_data.is_hovered_over != 100000) {
    //     tile.is_hovered_over = tile_data.is_hovered_over;
    // }
    // tile_data.reserved_2 = 0;
}

void ApplyTemplate(int tile_id) {
    // Skip tile if template isn't specified
    if (TemplateId == -1) {
        return;
    }

    Tile tile = TilesRW[tile_id];

    // Check if tile doesn't have requested template
    if (tile.template_id != TemplateId) {
        // Check if parent isn't specified or if tile doesn't have requested parent
        if ((ParentTileId == -1000) || (tile.parent_tile_id != ParentTileId)) {
            // Check if tile isn't in requested range
            if (FirstTileId > tile_id || tile_id > LastTileId) {
                // Skip tile if all checks passed
                return;
            }
        }
    }

    // Get requested template
    Tile tile_template = TileTemplateDataRW[TemplateId];
    // Skip non-existing template
    if (tile_template.sys_state_id == 0) {
        return;
    }
    
    if (tile.sys_state_id != 1) {
        // Handle non-existing tile
        if (CreateTiles == 1) {
            // Create new tile if requested
            InitializeTile(tile);
        } else {
            // Skip non-existing tile
            return;
        }
    } else {
        // Skip existing tile if requested
        if (SkipExistingTiles == 1) {
            return;
        }
    }
    
    LoadDataUpdate(tile_template, tile);
    TilesRW[tile_id] = tile;
}

void ApplyLayout(int tile_id)
{
    // Skip if layout is not specified
    if (ColsCount < 1 || RowsCount < 1) {
        return;
    }
    // Skip out-of-requested-range tile
	if (FirstTileId > tile_id || tile_id > LastTileId) {
        return;
    }

    Tile tile = TilesRW[tile_id];
    
    // Skip non-existing tile
    if (tile.sys_state_id != 1) {
        return;
    }
   
    int total_tiles = LastTileId - FirstTileId + 1;
    int tile_number = tile_id - LastTileId + total_tiles - 1;
    int tile_row = tile_number / ColsCount;
    int tile_col = tile_number % ColsCount;

    tile.offset.x += (tile.size.x + ColsPadding) * tile_col;
    tile.offset.y += (tile.size.y + RowsPadding) * tile_row;

    tile.anchor.x = AnchorX;
    tile.anchor.y = AnchorY;

    // Quick, dirty but efficient approach to anchor entire layout
    // Relies heavily on current position_service implementation and trusts it blindly, leaving the rest of the work to it
    if (AnchorX == 0) {
        tile.offset.x -= ((tile.size.x + ColsPadding) * ColsCount - ColsPadding) / 2 - tile.size.x / 2;
    } else if (abs(AnchorX == 2)) {
        tile.offset.x -= ((tile.size.x + ColsPadding) * (ColsCount - 1));
    }
    if (AnchorY == 0) {
        tile.offset.y -= ((tile.size.y + RowsPadding) * RowsCount - RowsPadding) / 2 - tile.size.y / 2;
    } else if (abs(AnchorY == 2)) {
        tile.offset.y -= ((tile.size.y + RowsPadding) * (RowsCount - 1));
    }

    // DebugRW[tile_id] = float4(tile_col, tile_row, tile.offset.x, tile.offset.y);
    // DebugRW[tile_id] = float4(AnchorX, AnchorY, tile.offset.x, tile.offset.y);
    TilesRW[tile_id] = tile;
}

// #ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
	int tile_id = ThreadId.x;

    if (RequestType == 1) {
        ApplyTemplate(tile_id);
    } else if (RequestType == 2) {
        ApplyLayout(tile_id);
    }
}

// #endif

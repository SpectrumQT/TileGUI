// Updates client's tile storage with given ini variables

Texture1D<float4> IniParams : register(t120);

#define TileType IniParams[1].x
#define TemplateId IniParams[1].y
#define TileId IniParams[1].z

// Base config
#define SysStateId IniParams[2].x
#define LayerId IniParams[2].y
#define ParentTileId IniParams[2].z
#define DynamicTemplateId IniParams[2].w
// Features config
#define Show IniParams[3].x
#define Select IniParams[3].y
#define Clamp IniParams[3].z
#define TrackMouse IniParams[3].w
// Advanced features config
#define LoopStartTexArrId IniParams[4].x
#define LoopEndTexArrId IniParams[4].y
#define HoverOverlayTileId IniParams[4].z
#define SelectOverlayTileId IniParams[4].w
// Display config
#define Size IniParams[5].xy
#define TextureId IniParams[5].z
#define TexArrId IniParams[5].w
// Texture config
#define TexUV IniParams[6].xyzw
// Texture config 2
#define Opacity IniParams[7].x
#define Saturation IniParams[7].y
// Layout config
#define Offset IniParams[8].xy
#define Anchor IniParams[8].zw
// Current state
#define LoopStage IniParams[9].x

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


void InitializeTemplate(inout Tile tile)
{
    // Base config
    tile.sys_state_id = 100000;
    tile.layer_id = 100000;
    tile.parent_tile_id = 100000;
    tile.template_id = 100000;
    // Features config
    tile.show = 100000;
    tile.select = 100000;
    tile.clamp = 100000;
    tile.track_mouse = 100000;
    // Advanced features config
    tile.loop_start = 100000;
    tile.loop_method = 100000;
    tile.hover_overlay_tile_id = 100000;
    tile.select_overlay_tile_id = 100000;
    // Display config
    tile.size = 100000;
    tile.texture_id = 100000;
    tile.tex_arr_id = 100000;
    // Texture config
    tile.tex_uv = 100000;
    // Texture config 2
    tile.opacity = 100000;
    tile.saturation = 100000;
    tile.reserved_1 = 100000;
    // Layout config
    tile.offset = 100000;
    tile.anchor = 100000;
    // Current state
    tile.loop_stage = 100000;
    tile.is_hovered_over = 100000;
    tile.reserved_2 = 100000;
}

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

Tile GetDataFromIni()
{
    Tile tile_data;
    // Base config
    tile_data.sys_state_id = SysStateId;
    tile_data.layer_id = LayerId;
    tile_data.parent_tile_id = ParentTileId;
    tile_data.template_id = DynamicTemplateId;
    // Features config
    tile_data.show = Show;
    tile_data.select = Select;
    tile_data.clamp = Clamp;
    tile_data.track_mouse = TrackMouse;
    // Advanced features config
    tile_data.loop_start = LoopStartTexArrId;
    tile_data.loop_method = LoopEndTexArrId;
    tile_data.hover_overlay_tile_id = HoverOverlayTileId;
    tile_data.select_overlay_tile_id = SelectOverlayTileId;
    // Display config
    tile_data.size = Size;
    tile_data.texture_id = TextureId;
    tile_data.tex_arr_id = TexArrId;
    // Texture config
    tile_data.tex_uv = TexUV;
    // Texture config 2
    tile_data.opacity = Opacity;
    tile_data.saturation = Saturation;
    // Layout config
    tile_data.offset = Offset;
    tile_data.anchor = Anchor;
    // Current state
    tile_data.loop_stage = LoopStage;
    // tile_data.is_hovered_over = IsHoveredOver;
    // tile_data.not_used_2 = 0;
    return tile_data;
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
    // tile_data.not_used_2 = 0;
}

void UpdateTileTemplate(int template_id)
{
    // Get template from storage
    Tile tile_template = TileTemplateDataRW[TemplateId];
    // Initialize template if empty
    if (tile_template.sys_state_id == 0) {
        InitializeTemplate(tile_template);
    }
    // Read update data from ini variables to cache
    Tile update_data = GetDataFromIni();
    // Write cached update data to template
    LoadDataUpdate(update_data, tile_template);
    // Save updated template to storage
    TileTemplateDataRW[TemplateId] = tile_template;
}

void UpdateTile(int tile_id, int template_id)
{
    // Get tile from storage
    Tile tile = TilesRW[tile_id];
    // Initialize tile if empty
    if (tile.sys_state_id == 0) {
        InitializeTile(tile);
    }
    // Load data from provided template
    if (template_id != 100000) {
        LoadDataUpdate(TileTemplateDataRW[template_id], tile);
    }
    // Read update data from ini variables to cache
    Tile update_data = GetDataFromIni();
    // Write cached update data to tile
    LoadDataUpdate(update_data, tile);
    // Save updated tile to storage
    TilesRW[tile_id] = tile;
}

// #ifdef COMPUTE_SHADER

[numthreads(1,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    if (TileType == 1) {
        UpdateTileTemplate(TemplateId);
    } else if (TileType == 2) {
        UpdateTile(TileId, TemplateId);
        // DebugRW[TileId] = float4(TilesRW[TileId].anchor, 0, 0);
    }
}

// #endif

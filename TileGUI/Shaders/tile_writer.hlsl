// Updates client's tile storage with given ini variables

#include "tile_model.hlsl"

Texture1D<float4> IniParams : register(t120);

#define TileType IniParams[1].x
#define TemplateId IniParams[1].y
#define TileId IniParams[1].z
#define SetValue IniParams[1].w

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

RWStructuredBuffer<Tile> TileTemplateDataRW : register(u0);
RWStructuredBuffer<Tile> TilesRW : register(u1);
// RWBuffer<float4> DebugRW : register(u7);

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

void SetSliderValue()
{
    if (TileId == 100000) {
        return;
    }
    Tile tile = TilesRW[TileId];
    if (tile.parent_tile_id == -1) {
        return;
    }
    Tile parent_tile = TilesRW[tile.parent_tile_id];
    if (parent_tile.size.x > parent_tile.size.y) {
        tile.offset.x = parent_tile.abs_pos.x + (parent_tile.size.x - tile.size.x) * SetValue - tile.abs_pos.x;
    } else {
        tile.offset.y = parent_tile.abs_pos.y + (parent_tile.size.y - tile.size.y) * SetValue - tile.abs_pos.y;
    }
    TilesRW[TileId] = tile;
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
    } else if (TileType == 3) {
        SetSliderValue();
    }
}

// #endif

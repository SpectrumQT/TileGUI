// Streamlines multiple tiles declaration and property updates both for initialization and runtime

#include "tile_model.hlsl"

Texture1D<float4> IniParams : register(t120);

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

RWStructuredBuffer<Tile> TileTemplateDataRW : register(u0);
RWStructuredBuffer<Tile> TilesRW : register(u1);
//RWBuffer<float4> DebugRW : register(u7);


void ApplyTemplate(int tile_id)
{
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
   
    uint total_tiles = LastTileId - FirstTileId + 1;
    uint tile_number = tile_id - LastTileId + total_tiles - 1;
    uint tile_row = tile_number / uint(ColsCount);
    uint tile_col = tile_number % uint(ColsCount);

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

// Updates positions of all tiles based on sizes, offsets, anchors and parents

#include "tile_model.hlsl"

Texture1D<float4> IniParams : register(t120);

#define WindowWidth IniParams[0].x
#define WindowHeight IniParams[0].y

#define MaxParentRecursion (IniParams[1].x <= 8 ? IniParams[1].x : 0)

#define RootParentCoords float4(0, 0, IniParams[0].x, IniParams[0].y)

RWStructuredBuffer<Tile> TilesRW : register(u1);
//RWBuffer<float4> DebugRW : register(u7);

float2 GetAnchoredAxisCoords(float anchor, float child_size, float2 parent_coords) {
	float2 axis_coords;
	if (anchor == 1) {
		// Min Inside (align child's Min edge to Min edge of the parent)
		// [[ C ]P    ] ----axis---->
		axis_coords.x = parent_coords.x;
		axis_coords.y = axis_coords.x + child_size;
	} else if (anchor == 2) {
		// Max Inside (align child's Max edge to Max edge of the parent)
		// [    P[ C ]] ----axis---->
		axis_coords.y = parent_coords.y;
		axis_coords.x = axis_coords.y - child_size;
	} else if (anchor == -1) {
		// Min Outside (align child's Max edge to Min edge of the parent)
		// [ C ][  P  ] ----axis---->
		axis_coords.y = parent_coords.x;
		axis_coords.x = axis_coords.y - child_size;
	} else if (anchor == -2) {
		// Max Outside (align child's Min edge to Max edge of the parent)
		// [  P  ][ C ] ----axis---->
		axis_coords.x = parent_coords.y;
		axis_coords.y = axis_coords.x + child_size;
	} else {
		// Center (align child's Center to Center of the parent)
		// [ P [ C ] P ] ----axis---->
		float parent_width = parent_coords.y - parent_coords.x;
		float parent_anchor_x = parent_coords.y - parent_width / 2;
		axis_coords.x = parent_anchor_x - child_size / 2;
		axis_coords.y = parent_anchor_x + child_size / 2;
	}
	return axis_coords;
}

float4 GetAnchoredAbsolutePosition(float2 anchor, float2 child_size, float4 parent_coords) {
	// Absolute screen space coords:
	// x1 (Left) = 0
	// y1 (Bottom) = 0
	// x2 (Right) = window_max_x - 1
	// y2 (Top) = window_max_y - 1
	
	// Image position is described by two points:
	// 1. Bottom-Left aka (x1, y1), where x1 is absolute_coords.x and y1 is absolute_coords.y
	// 1. Top-Right aka (x2, y2), where x2 is absolute_coords.z and y2 is absolute_coords.w
	// Calculate x1 and x2 coords based on anchor point
	float2 absolute_coords_x = GetAnchoredAxisCoords(anchor.x, child_size.x, parent_coords.xz);
	// Calculate y1 and y2 coords based on anchor point
	float2 absolute_coords_y = GetAnchoredAxisCoords(anchor.y, child_size.y, parent_coords.yw);

	return float4(absolute_coords_x.x, absolute_coords_y.x, absolute_coords_x.y, absolute_coords_y.y);
}

float GetClampedAxisOffset(float offset, float child_size, float2 parent_coords, float2 child_coords) {
	// Keeps tile a1 and a2 coords within the parent's axis range
	float parent_size = parent_coords.y - parent_coords.x;
	if (child_size <= parent_size) {
		float excess_min = child_coords.x + offset - parent_coords.x;
		if (excess_min < 0) {
			offset -= excess_min;
		}
		float excess_max = child_coords.y + offset - parent_coords.y;
		if (excess_max > 0) {
			offset -= excess_max;
		}
	} else if (parent_size != 0) {
		offset = 0;
	}
	return offset;
}

float2 GetClampedOffset(float2 offset, float2 anchor, float2 child_size, float4 parent_coords, float4 child_coords) {
	if (anchor.x >= 0 && anchor.y >= 0) {
		offset.x = GetClampedAxisOffset(offset.x, child_size.x, parent_coords.xz, child_coords.xz);
		offset.y = GetClampedAxisOffset(offset.y, child_size.y, parent_coords.yw, child_coords.yw);
	}
	return offset;
}

Tile UpdateAbsolutePosition(Tile tile, float4 parent_coords)
{
	float4 absolute_coords = GetAnchoredAbsolutePosition(tile.anchor, tile.size, parent_coords);
	
	if (tile.clamp == 1) {
		tile.offset = GetClampedOffset(tile.offset, tile.anchor, tile.size, parent_coords, absolute_coords);
	}

	absolute_coords.xz += tile.offset.x;
	absolute_coords.yw += tile.offset.y;

	tile.abs_pos = absolute_coords;

	return tile;
}

// 
// Supports recursive 
float4 GetParentAbsolutePosition(Tile tile)
{
	int parent_tile_id = tile.parent_tile_id;
	
	if (parent_tile_id == -1) {
		// Return app window absolute coords if parent chain is empty
		return RootParentCoords;
	} else if (MaxParentRecursion == 0) {
		// Return parent tile absolute coords without updating them
		return TilesRW[parent_tile_id].abs_pos;
	} else {
		// Recursively calculate up-to-date position of up to 8 parents in the chain
		// Makes child tiles to move after parent without lagging but puts a bit more stress on GPU
		Tile parent_tiles[8];
		// Index chain of parents
		for (int i = 0; i < MaxParentRecursion; i++) {
			// Cache current parent
			parent_tiles[i] = TilesRW[parent_tile_id];
			// Remember id of the next parent
			parent_tile_id = parent_tiles[i].parent_tile_id;
			// Stop if no more parents in the chain
			if (parent_tile_id == -1) {
				break;
			}
		}
		// Calculate absolute coords of last parent in the chain
		Tile updated_parent_tile = UpdateAbsolutePosition(parent_tiles[i], RootParentCoords);
		// Calculate absolute coords of previous parents in reversed order
		for (int r = i - 1; r >= 0; r--) {
			updated_parent_tile = UpdateAbsolutePosition(parent_tiles[r], updated_parent_tile.abs_pos);
		}
		// Return absolute coords of first parent in the chain
		return updated_parent_tile.abs_pos;
	}
}

void UpdateRelativePosition(inout Tile tile)
{
	if (tile.abs_pos.x == 0 && tile.abs_pos.z == 0) {
		return;
	}

	// Relative screen space coords:
	// x1 (Left) = -1.0
	// y1 (Bottom) = -1.0
	// x2 (Right) = 1
	// y2 (Top) = 1
	// Screen center point coords (x, y) are (0.0, 0.0)

	// Relative position is relative to the center of the screen
	// For example we'll use common 1920x1080 screen:
	//	 window_max_x=1920
	//	 window_max_y=1080

	// 1. At first, we need to calculate absolute coords for central point of the screen
	// 	Current coordinate range: x = [1, 1920] and y = [1, 1080]
	float center_x = WindowWidth / 2; // 1920 / 2 = 960
	float center_y = WindowHeight / 2; // 1080 / 2 = 540

	// 2. Then we need to make said central point a new reference point of the absolute coordinate system
	// 	New coordinate range: x = [-960,960] and y = [-540,540]
	// 3. Finally, we need to transform coordinate range from absolute to relative
	// 	New coordinate range: x = [-1,1] and y = [-1,1]
	
	// Both 2. and 3. steps can be done by simply deducting central point coords and then dividing by the same value
	tile.rel_pos.xz = (tile.abs_pos.xz - center_x) / center_x;
	tile.rel_pos.yw = (tile.abs_pos.yw - center_y) / center_y;
}


// #ifdef COMPUTE_SHADER

// Runs 1 thread per tile, 64 threads per group, and expects up to 16 thread groups 
// Processes up to 1 * 64 * 16 = 1024 tiles total per dispatch
[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
	int tile_id = ThreadId.x;
    Tile tile = TilesRW[tile_id];

    if (tile.sys_state_id == 0 || tile.show != 1) {
        return;
    }

    tile = UpdateAbsolutePosition(tile, GetParentAbsolutePosition(tile));

	UpdateRelativePosition(tile);

	TilesRW[tile_id] = tile;
}

// #endif


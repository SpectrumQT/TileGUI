// Handles special (re)actions for all tiles, like hover over, overlays, dragging and so on
// Simplifies and accelerates common GUI logic that would require tons of STORE calls otherwise

Texture1D<float4> IniParams : register(t120);

#define WindowWidth IniParams[0].x
#define WindowHeight IniParams[0].y
#define CursorX IniParams[0].z
#define CursorY IniParams[0].w

#define RootParentCoords float4(0, 0, IniParams[0].x, IniParams[0].y)

struct Instance {
	float max_tiles_count;
	float max_layers_count;
	float2 unused1;

    float drag_tile_id;
	float2 drag_pos;
	float1 unused2;
    
	float4 unused3;
};

RWStructuredBuffer<Instance> InstanceContainerRW : register(u0);
#define Instance InstanceContainerRW[0]

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

RWStructuredBuffer<Tile> TilesRW : register(u1);
//RWBuffer<float4> DebugRW : register(u7);

void HandleDrag(int tile_id, inout Tile tile)
{
	if (Instance.drag_tile_id != tile_id) {
		return;
	}
	float cursor_abs_x = abs(CursorX + 1) / 2 * WindowWidth;
	float cursor_abs_y = abs(CursorY + 1) / 2 * WindowHeight;

	if (Instance.drag_pos.x == 0) {
		Instance.drag_pos.x = cursor_abs_x;
	}
	if (Instance.drag_pos.y == 0) {
		Instance.drag_pos.y = cursor_abs_y;
	}
	
	float drag_abs_x = cursor_abs_x - Instance.drag_pos.x;
	float drag_abs_y = cursor_abs_y - Instance.drag_pos.y;

	// Tile tile = TilesRW[Instance.drag_tile_id];

	// Ignore cursor movement outside of parent's range (conventional slider behavior)
	// Requires more checks to be less wanky, so lets comment it for now
	// float4 parent_coords = (tile.parent_tile_id == -1 ? RootParentCoords : TilesRW[tile.parent_tile_id].abs_pos);
	// float parent_right_edge = parent_coords.z;
	// float parent_left_edge = parent_coords.x;
	// if (cursor_abs_x > parent_right_edge || cursor_abs_x < parent_left_edge) {
	// 	drag_abs_x = 0;
	// }
	// float parent_top_edge = parent_coords.w;
	// float parent_bot_edge = parent_coords.y;
	// if (cursor_abs_y > parent_top_edge || cursor_abs_y < parent_bot_edge) {
	// 	drag_abs_y = 0;
	// }

	if (drag_abs_x != 0 || drag_abs_y != 0) {
		Instance.drag_pos.x = cursor_abs_x;
		Instance.drag_pos.y = cursor_abs_y;

		tile.offset.x += drag_abs_x;
		tile.offset.y += drag_abs_y;
	}

	// DebugRW[Instance.drag_tile_id] = float4(drag_abs_x, CursorX, drag_abs_y, CursorY);
}

void AddOverlay(int target_tile_id, int overlay_tile_id)
{
	Tile overlay_tile = TilesRW[overlay_tile_id];
	overlay_tile.parent_tile_id = target_tile_id;
	overlay_tile.show = 1;
	TilesRW[overlay_tile_id] = overlay_tile;
}

void RemoveOverlay(int target_tile_id, int overlay_tile_id)
{
	Tile overlay_tile = TilesRW[overlay_tile_id];
	if (overlay_tile.parent_tile_id != target_tile_id) {
		return;
	}
	overlay_tile.parent_tile_id = -1;
	overlay_tile.show = 0;
	TilesRW[overlay_tile_id] = overlay_tile;
}

void HandleHoverOver(int tile_id, inout Tile tile)
{
	if (tile.show == 0) {
		return;
	}
	if (CursorX > tile.rel_pos.x && CursorY > tile.rel_pos.y && CursorX < tile.rel_pos.z && CursorY < tile.rel_pos.w) {
		if (tile.is_hovered_over == 1) {
			return;
		}
		if (tile.hover_overlay_tile_id != -1) {
			AddOverlay(tile_id, tile.hover_overlay_tile_id);
		}
		tile.is_hovered_over = 1;
	} else {
		if (tile.is_hovered_over == 0) {
			return;
		}
		if (tile.hover_overlay_tile_id != -1) {
			RemoveOverlay(tile_id, tile.hover_overlay_tile_id);
		}
		tile.is_hovered_over = 0;
	};
}

void HandleSelect(int tile_id, inout Tile tile)
{
	if (tile.show == 0) {
		return;
	}
	if (tile.select_overlay_tile_id == -1) {
		return;
	}
	if (tile.select == 1) {
		AddOverlay(tile_id, tile.select_overlay_tile_id);
	} else {
		RemoveOverlay(tile_id, tile.select_overlay_tile_id);
	}
}

void HandleLoopStage(int tile_id, inout Tile tile)
{
	if (tile.loop_method < 1) {
		return;
	}
	if (tile.loop_method == 1) {
		// Loop via tex_arr_id
		tile.tex_arr_id = tile.loop_start + tile.loop_stage;
	} else if (tile.loop_method == 2) {
		// Set current UV coords as loop start
		if (tile.loop_start == -1) {
			tile.loop_start = tile.tex_uv.x;
		}
		// Loop via UV
		float uv_width = tile.tex_uv.z - tile.tex_uv.x;
		tile.tex_uv.x = tile.loop_start + uv_width * tile.loop_stage;
		tile.tex_uv.z = tile.tex_uv.x + uv_width;
	}
}

// #ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
	int tile_id = ThreadId.x;
    Tile tile = TilesRW[tile_id];

	if (tile.sys_state_id != 1) {
		return;
	}

	if (tile.track_mouse == 1) {
		HandleDrag(tile_id, tile);
		HandleHoverOver(tile_id, tile);
	};

	HandleSelect(tile_id, tile);
	HandleLoopStage(tile_id, tile);

	TilesRW[tile_id] = tile;
}

// #endif


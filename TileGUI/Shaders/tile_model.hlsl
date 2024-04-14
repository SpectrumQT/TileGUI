
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



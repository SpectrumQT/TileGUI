// Updates client's instance storage with given ini variables

Texture1D<float4> IniParams : register(t120);

// #define WindowWidth IniParams[0].x
// #define WindowHeight IniParams[0].y
#define CursorX IniParams[0].z
#define CursorY IniParams[0].w

#define MaxTilesCount IniParams[10].x
#define MaxLayersCount IniParams[10].y

#define DragTileId IniParams[15].x

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
#define CurrentInstance InstanceContainerRW[0]

//RWBuffer<float4> DebugRW : register(u7);


void UpdateInstanceFromIni(inout Instance instance_data)
{
    if (MaxTilesCount != 100000) {
        instance_data.max_tiles_count = MaxTilesCount;
    }
    if (MaxLayersCount != 100000) {
        instance_data.max_layers_count = MaxLayersCount;
    }
    if (DragTileId != 100000) {
        instance_data.drag_tile_id = DragTileId;
        instance_data.drag_pos = float2(0, 0);
    } else {
        instance_data.drag_tile_id = -1;
    }
}


// #ifdef COMPUTE_SHADER

[numthreads(1,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
	UpdateInstanceFromIni(CurrentInstance);
    
    InstanceContainerRW[0] = CurrentInstance;

    // DebugRW[0] = float4(0, 0, 0, 0);
}

// #endif


// Updates client's instance storage with given ini variables

#include "instance_model.hlsl"

Texture1D<float4> IniParams : register(t120);

#define CursorX IniParams[0].z
#define CursorY IniParams[0].w

#define MaxTilesCount IniParams[10].x
#define MaxLayersCount IniParams[10].y

#define DragTileId IniParams[15].x

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


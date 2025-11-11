#ifndef MetalTypes_h
#define MetalTypes_h

#include <metal_stdlib>
using namespace metal;

// 常量定义
constant const int kMaxViewCount = 2;
constant static const half kBoundsRadius = 2;
constant static const half kBoundsRadiusSquared = kBoundsRadius*kBoundsRadius;
constant static const int kSRTextureCount = 4;

// 缓冲区索引枚举
enum BufferIndex: int32_t
{
    BufferIndexUniforms = 0,
    BufferIndexSplat    = 1,
    BufferIndexSplatFilterMode = 2,
};

// 统一变量结构体
typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    uint2 screenSize;
} Uniforms;

typedef struct
{
    Uniforms uniforms[kMaxViewCount];
} UniformsArray;

// Splat 结构体定义
typedef struct
{
    packed_float3 position;
    packed_half4 color;
    packed_half3 covA;
    packed_half3 covB;
    packed_half3 sr0;
    packed_half3 sr1;
    packed_half2 sr2;
    half alpha;
} Splat;

#endif /* MetalTypes_h */
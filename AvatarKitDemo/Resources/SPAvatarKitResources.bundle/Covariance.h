#ifndef Covariance_h
#define Covariance_h

#include <metal_stdlib>
using namespace metal;

// 计算2D协方差矩阵
float3 calcCovariance2D(float3 viewPos,
                       packed_half3 cov3Da,
                       packed_half3 cov3Db,
                       float4x4 viewMatrix,
                       float4x4 projectionMatrix,
                       uint2 screenSize);

// 分解协方差矩阵
// cov2D是一个展平的2D协方差矩阵，格式为：
// covariance = | a b |
//              | c d |
// 其中 b == c（因为高斯协方差矩阵是对称的）
// cov2D = ( a, b, d )
void decomposeCovariance(float3 cov2D, thread float2 &v1, thread float2 &v2);

#endif /* Covariance_h */

#include <metal_stdlib>
#include "ColorFunctions.metal"
#include "LightingFunctions.metal"

using namespace metal;

/**
 * @struct VertexOut
 * @brief 頂點著色器的輸出結構
 */
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

/**
 * @brief 簡單的頂點著色器，建立三角形
 *
 * @param vertexID 頂點編號 (內建變數)
 * @return VertexOut 輸出頂點資料
 */
vertex VertexOut vertex_main(uint vertexID [[vertex_id]]) {
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2( 0.0,  1.0)
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.texCoord = (positions[vertexID] + 1.0) * 0.5;
    return out;
}

/**
 * @brief 片段著色器，將三角形上色
 *
 * @param in 從頂點著色器輸入的資料
 * @return float4 RGBA 顏色值
 */
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    float3 baseColor = float3(in.texCoord, 1.0);
    float3 gray = applyGrayscale(baseColor);
    float3 lit = applyLighting(gray, float3(1.0, 1.0, 1.0));
    return float4(lit, 1.0);
}

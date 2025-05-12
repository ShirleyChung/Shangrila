#include <metal_stdlib>
using namespace metal;

/**
 * @brief 套用簡單的光照效果
 *
 * @param color 原始顏色
 * @param lightColor 光源顏色
 * @return float3 加乘光照後的顏色
 */
float3 applyLighting(float3 color, float3 lightColor) {
    return color * lightColor;
}

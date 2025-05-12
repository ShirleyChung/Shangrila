#include <metal_stdlib>
using namespace metal;

/**
 * @brief 將輸入顏色轉換為灰階
 *
 * @param color 原始 RGB 顏色
 * @return float3 灰階處理後的顏色
 */
float3 applyGrayscale(float3 color) {
    float gray = dot(color, float3(0.299, 0.587, 0.114));
    return float3(gray);
}

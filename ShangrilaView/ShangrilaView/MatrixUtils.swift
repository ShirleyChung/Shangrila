import simd
import Foundation

/// 建立繞任意軸的旋轉矩陣
func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let normalizedAxis = normalize(axis)
    let x = normalizedAxis.x
    let y = normalizedAxis.y
    let z = normalizedAxis.z

    let c = cosf(radians)
    let s = sinf(radians)
    let ci = 1 - c

    return matrix_float4x4(columns: (
        SIMD4<Float>(c + x * x * ci, x * y * ci - z * s, x * z * ci + y * s, 0),
        SIMD4<Float>(y * x * ci + z * s, c + y * y * ci, y * z * ci - x * s, 0),
        SIMD4<Float>(z * x * ci - y * s, z * y * ci + x * s, c + z * z * ci, 0),
        SIMD4<Float>(0, 0, 0, 1)
    ))
}

/// 建立位移矩陣
func matrix4x4_translation(_ x: Float, _ y: Float, _ z: Float) -> matrix_float4x4 {
    return matrix_float4x4(columns: (
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(0, 0, 1, 0),
        SIMD4<Float>(x, y, z, 1)
    ))
}

/// 建立左手座標系透視投影矩陣（與 Metal 配合）
func matrix_perspective_left_hand(fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let yScale = 1 / tanf(fovyRadians * 0.5)
    let xScale = yScale / aspect
    let zRange = farZ - nearZ
    let zScale = farZ / zRange
    let wz = -nearZ * zScale

    return matrix_float4x4(columns: (
        SIMD4<Float>(xScale, 0, 0, 0),
        SIMD4<Float>(0, yScale, 0, 0),
        SIMD4<Float>(0, 0, zScale, 1),
        SIMD4<Float>(0, 0, wz, 0)
    ))
}

func matrix4x4_scale(_ sx: Float, _ sy: Float, _ sz: Float) -> matrix_float4x4 {
    return matrix_float4x4(columns: (
        simd_float4(sx,  0,  0,  0),
        simd_float4( 0, sy,  0,  0),
        simd_float4( 0,  0, sz,  0),
        simd_float4( 0,  0,  0,  1)
    ))
}


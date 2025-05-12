#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
};

//vertex VertexOut vertex_main(VertexIn in [[stage_in]],
//                             constant float4x4& mvp [[buffer(1)]]) {
//    VertexOut out;
//    out.position = mvp * float4(in.position, 1.0);
//    out.normal = in.normal;
//    return out;
//}

struct Vertex {
    float3 position;
    float3 normal;
};

vertex VertexOut vertex_main(uint vertexId [[vertex_id]],
                             const device Vertex* vertices [[buffer(0)]],
                             constant float4x4& mvp [[buffer(1)]]) {
    VertexOut out;
    float3 pos = vertices[vertexId].position;
    float3 normal = vertices[vertexId].normal;
    out.position = mvp * float4(pos, 1.0);
    out.normal = normal;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    float3 lightDir = normalize(float3(0.5, 1, 1));
    float lighting = max(dot(normalize(in.normal), lightDir), 0.0);
    return float4(float3(1.0, 0.5, 0.3) * lighting, 1.0);
}

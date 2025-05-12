import MetalKit
import simd
import ModelIO

/// 渲染器：負責載入模型、處理動畫、執行 draw loop
class Renderer: NSObject, MTKViewDelegate {
    var depthStencilState: MTLDepthStencilState?

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let mesh: MTKMesh
    

    var time: Float = 0

    init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = device.makeCommandQueue()!

        // 載入 3D 模型（例如燈泡.obj）
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let assetURL = Bundle.main.url(forResource: "teapot", withExtension: "obj")  else { // ✅ 換成你要的模型
            fatalError("找不到teapot.obj")
        }
        let asset = MDLAsset(url: assetURL, vertexDescriptor: nil, bufferAllocator: allocator)
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        print("Vertex count: \(mesh.vertexCount)\n")
        
        // 編譯 Shader
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "vertex_main")!
        let fragmentFunc = library.makeFunction(name: "fragment_main")!
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        pipelineDesc.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Renderer.buildVertexDescriptor())
        pipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)

        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = .less
        depthStencilDesc.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)

        super.init()
    }

    static func buildVertexDescriptor() -> MDLVertexDescriptor {
        let desc = MDLVertexDescriptor()
        desc.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        desc.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        desc.layouts[0] = MDLVertexBufferLayout(stride: 24)
        return desc
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }

        time += 1 / Float(view.preferredFramesPerSecond)

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
                encoder.setRenderPipelineState(pipelineState)
                encoder.setDepthStencilState(depthStencilState)
                                
                // 矩陣：旋轉 + 投影
                let aspect = Float(view.drawableSize.width / view.drawableSize.height)
                let proj = matrix_perspective_left_hand(fovyRadians: .pi/4, aspect: aspect, nearZ: 0.1, farZ: 100)
                let viewMatrix = matrix4x4_translation(0, 0, -3)
                let modelMatrix = matrix4x4_rotation(radians: time, axis: [0, 1, 0])
                var mvp = proj * viewMatrix * modelMatrix
                
                encoder.setVertexBytes(&mvp, length: MemoryLayout<matrix_float4x4>.size, index: 1)
                
                for (i, meshBuffer) in mesh.vertexBuffers.enumerated() {
                    encoder.setVertexBuffer(meshBuffer.buffer, offset: meshBuffer.offset, index: i)
                }
                
                for submesh in mesh.submeshes {
                    encoder.drawIndexedPrimitives(type: .triangle,
                                                  indexCount: submesh.indexCount,
                                                  indexType: submesh.indexType,
                                                  indexBuffer: submesh.indexBuffer.buffer,
                                                  indexBufferOffset: submesh.indexBuffer.offset)
                }
                
                encoder.endEncoding()
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

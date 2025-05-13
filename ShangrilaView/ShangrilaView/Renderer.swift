import MetalKit
import simd
import ModelIO

/// 渲染器：負責載入模型、設定 pipeline、處理動畫、執行 draw loop
class Renderer: NSObject, MTKViewDelegate {
    /// 深度測試狀態，用於 Z-buffer
    var depthStencilState: MTLDepthStencilState?

    /// Metal 裝置（代表 GPU）
    let device: MTLDevice

    /// 指令佇列：負責提交渲染命令
    let commandQueue: MTLCommandQueue

    /// 編譯後的渲染管線狀態物件（封裝 shader 組合）
    let pipelineState: MTLRenderPipelineState

    /// 由 .obj 模型轉換而來的 Mesh 資料
    let mesh: MTKMesh

    /// 用來控制動畫的時間變數
    var time: Float = 0

    /**
     初始化渲染器
     - Parameter mtkView: MetalKit View，用來顯示渲染內容
     */
    init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = device.makeCommandQueue()!

        // 載入 3D 模型（這裡使用 teapot.obj，可替換為其他模型）
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let assetURL = Bundle.main.url(forResource: "teapot", withExtension: "obj") else {
            fatalError("找不到 teapot.obj")
        }
        let asset = MDLAsset(url: assetURL, vertexDescriptor: nil, bufferAllocator: allocator)
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        // 補上法線資料
        //mdlMesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 0.1)
        
        self.mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        print("Vertex count: \(mesh.vertexCount)\n")

        // 編譯 Shader（從預設 Metal Library 中取得）
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "vertex_main")!
        let fragmentFunc = library.makeFunction(name: "fragment_main")!

        // 建立渲染管線描述器
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        pipelineDesc.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(Renderer.buildVertexDescriptor())
        pipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineDesc.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat

        // 編譯渲染管線
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)

        // 建立 Z-buffer 渲染設定（深度測試）
        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = .less
        depthStencilDesc.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDesc)

        super.init()
    }

    /// 建立 ModelIO 的頂點描述（對應位置與法線）
    static func buildVertexDescriptor() -> MDLVertexDescriptor {
        let desc = MDLVertexDescriptor()
        desc.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        desc.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: 12, bufferIndex: 0)
        desc.layouts[0] = MDLVertexBufferLayout(stride: 24)
        return desc
    }

    /// MTKView 畫面大小改變時觸發（目前未使用）
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    /**
     每一幀的渲染處理流程
     - Parameter view: 呼叫的 MTKView 實體
     */
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }

        // 時間前進：用於動畫旋轉
        time += 1 / Float(view.preferredFramesPerSecond)

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
                encoder.setRenderPipelineState(pipelineState)
                encoder.setDepthStencilState(depthStencilState)

                // 建立 MVP（Model-View-Projection）矩陣
                let aspect = Float(view.drawableSize.width / view.drawableSize.height)
                let proj = matrix_perspective_left_hand(fovyRadians: .pi / 4, aspect: aspect, nearZ: 0.1, farZ: 100)
                let viewMatrix = matrix4x4_translation(0, 0, -3)
                let modelMatrix = matrix4x4_rotation(radians: time, axis: [0, 1, 0])
                //let scale = matrix4x4_scale(0.1, 0.1, 0.1)
                var mvp = proj * viewMatrix * modelMatrix

                // 傳送 MVP 給 vertex shader
                encoder.setVertexBytes(&mvp, length: MemoryLayout<matrix_float4x4>.size, index: 1)

                // 設定頂點資料（來源於 mesh）
                for (i, meshBuffer) in mesh.vertexBuffers.enumerated() {
                    encoder.setVertexBuffer(meshBuffer.buffer, offset: meshBuffer.offset, index: i)
                }

                // 繪製所有 submesh（indexed drawing）
                for submesh in mesh.submeshes {
                    encoder.drawIndexedPrimitives(type: .triangle,
                                                  indexCount: submesh.indexCount,
                                                  indexType: submesh.indexType,
                                                  indexBuffer: submesh.indexBuffer.buffer,
                                                  indexBufferOffset: submesh.indexBuffer.offset)
                }

                encoder.endEncoding()
            }

            // 呈現結果
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

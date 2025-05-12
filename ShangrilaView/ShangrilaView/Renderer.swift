import MetalKit

/**
 * @class Renderer
 * @brief 負責處理 Metal 畫面渲染的類別
 */
class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    
    /// 記錄當前關聯的 view（可選用）
    weak var view: MTKView?

    /**
     * @brief 初始化渲染器，建立 pipeline
     * @param mtkView MetalKit 的 view 元件
     */
    init(mtkView: MTKView) {
        super.init()
        self.device = mtkView.device
        self.view = mtkView
        
        let library = device!.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: "vertex_main")!
        let fragmentFunc = library.makeFunction(name: "fragment_main")!

        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        pipelineDesc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        commandQueue = device.makeCommandQueue()
    }

    /**
     * @brief 視圖尺寸改變時的處理
     */
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    /**
     * @brief 每幀繪製內容的主邏輯
     */
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

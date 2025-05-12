import SwiftUI
import MetalKit

/**
 * @struct MetalView
 * @brief 封裝 MetalKit MTKView 的 SwiftUI 介面元件（macOS）
 */
struct MetalView: NSViewRepresentable {
    
    /// 協調器負責保存 Renderer，避免它被提早釋放
    class Coordinator {
        var renderer: Renderer?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /**
     * @brief 建立並設定 MTKView
     */
    func makeNSView(context: Context) -> MTKView {
        let device = MTLCreateSystemDefaultDevice()!
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.clearColor = MTLClearColorMake(0.1, 0.1, 0.1, 1.0)

        let renderer = Renderer(mtkView: mtkView)
        context.coordinator.renderer = renderer
        mtkView.delegate = renderer

        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}
}

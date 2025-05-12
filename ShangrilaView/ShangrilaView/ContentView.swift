//
//  ContentView.swift
//  ShangrilaView
//
//  Created by shirleychung on 2025/5/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // 主畫面進入點.建立一個MetalView
        MetalView()
            .frame(minWidth: 400, minHeight: 300)        
    }
}

#Preview {
    ContentView()
}

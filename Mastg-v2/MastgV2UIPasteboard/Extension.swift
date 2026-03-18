//
//  Extension.swift
//  MastgV2UIPasteboard
//
//  Created by 褚宣德 on 2026/3/17.
//

import Foundation
import SwiftUI



extension View {
    @ViewBuilder
    func onScenePhaseChange(phase: ScenePhase, action: @escaping (ScenePhase) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            // iOS 17+ 使用新語法
            self.onChange(of: phase) { _, newPhase in
                action(newPhase)
            }
        } else {
            // iOS 17 以下使用舊語法
            self.onChange(of: phase, perform: action)
        }
    }
    
    // 收起鍵盤的通用方法
    func hideKeyboardAction() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}

//
//  CustomSecureTextField.swift
//  MastgV2UIPasteboard
//
//  Created by 褚宣德 on 2026/3/17.
//
import SwiftUI

// MARK: - 繼承 UITextField 以封鎖原生選單
//class NonCopyableTextField: UITextField {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        // 封鎖 複製(copy)、剪下(cut)、貼上(paste)、分享(share) 等動作
//        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
//           action == #selector(UIResponderStandardEditActions.cut(_:)) ||
//           action == #selector(UIResponderStandardEditActions.paste(_:)) {
//            return false // 回傳 false 代表禁用該選項
//        }
//        // 其他系統預設行為則正常放行 (例如全選 selectAll)
//        return super.canPerformAction(action, withSender: sender)
//    }
//}

// MARK: - 繼承 UITextField 以「動態」封鎖原生選單
class DynamicSecureTextField: UITextField {
    // 用來判斷現在是否為安全模式
    var isSecureMode: Bool = true
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 只有在「安全模式 (isSecureMode == true)」時，才封鎖複製、剪下、貼上
        if isSecureMode {
            if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
                action == #selector(UIResponderStandardEditActions.cut(_:)) ||
                action == #selector(UIResponderStandardEditActions.paste(_:)) {
                return false
            }
        }
        // 如果 isSecureMode 為 false，就乖乖按照 iOS 預設行為（允許彈出複製選單）
        return super.canPerformAction(action, withSender: sender)
    }
}

// MARK: - 自訂不掉鍵盤的密碼輸入框 (封裝 UIKit)
struct CustomSecureTextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool // 綁定眼睛狀態
    
    var isSecureMode: Bool
    
    func makeUIView(context: Context) -> DynamicSecureTextField {
        let textField = DynamicSecureTextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = !isVisible // 初始狀態
        // 確保它一生成時，就帶有正確的安全狀態
        textField.isSecureMode = isSecureMode
        textField.delegate = context.coordinator
        
        // 資安與 UX 設定
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        // 加上這三行：解決實機第一次載入時，點擊範圍被壓縮的 Bug
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.backgroundColor = .clear // 確保背景透明但能接收點擊
        
        // 監聽文字改變事件
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: DynamicSecureTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // 當 isVisible 改變時，直接切換 isSecureTextEntry，不銷毀 View
        if uiView.isSecureTextEntry == isVisible {
            uiView.isSecureTextEntry = !isVisible
            
            // 修正 iOS 原生 Bug：切換 Secure 狀態時可能會導致游標位置異常或字體改變
            let tempText = uiView.text
            uiView.text = ""
            uiView.text = tempText
            
            // 同步安全模式狀態 (解決快取 Bug 的關鍵區塊)
            if uiView.isSecureMode != isSecureMode {
                uiView.isSecureMode = isSecureMode
                
                // 使用非同步方式強制放棄焦點 (收起鍵盤)
                // 這樣做能強迫 UIKit 清除選單快取，下次點擊時才會重新讀取 isSecureMode！
                DispatchQueue.main.async {
                    uiView.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomSecureTextField
        
        init(_ parent: CustomSecureTextField) {
            self.parent = parent
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            // 將 UIKit 的文字同步回 SwiftUI 的 @State
            parent.text = textField.text ?? ""
        }
    }
}

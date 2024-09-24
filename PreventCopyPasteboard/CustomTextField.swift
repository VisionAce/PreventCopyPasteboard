//
//  CustomTextField.swift
//  PreventCopyPasteboard
//
//  Created by 褚宣德 on 2024/9/25.
//

import SwiftUI
import UIKit

// 自定義的 UITextField，禁用複製、貼上等功能
class NonCopyPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) ||
           action == #selector(paste(_:)) ||
           action == #selector(select(_:)) ||
           action == #selector(selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

// 將 UITextField 轉換為 SwiftUI 可用的 View
struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> NonCopyPasteTextField {
        let textField = NonCopyPasteTextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        return textField
    }
    
    func updateUIView(_ uiView: NonCopyPasteTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

struct TestView: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            CustomTextField(text: $text)
                .padding()
                .frame(height: 50)

            Text("Entered Text: \(text)")
        }
        .padding()
    }
}

#Preview {
    TestView()
}


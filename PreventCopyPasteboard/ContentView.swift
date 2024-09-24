//
//  ContentView.swift
//  PreventCopyPasteboard
//
//  Created by 褚宣德 on 2024/9/25.
//

import SwiftUI


struct ContentView: View {
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack {
            // 根據 isPasswordVisible 的狀態決定顯示 TextField 或 SecureField
            
            HStack {
                if isPasswordVisible {
                    CustomTextField(text: $password)
                        .padding()
                        .frame(height: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 顯示/隱藏密碼的按鈕（眼睛圖示）
                Button(action: {
                    isPasswordVisible.toggle() // 切換顯示狀態
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash") // 根據狀態顯示不同的圖示
                        .foregroundColor(.gray)
                }
                .padding()
                
            }
            
            // 顯示輸入的密碼（僅用於測試，正式應用不會顯示）
            Text("Password: \(password)")
                .padding()
        }
        .background(.yellow)
        .padding()
        .dismissKeyboard()
    }
}





#Preview {
    ContentView()
}



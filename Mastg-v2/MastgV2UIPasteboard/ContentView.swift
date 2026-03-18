import SwiftUI
import UniformTypeIdentifiers


// MARK: - 主畫面
struct SecurePasteboardView: View {
    @State private var account: String = "0001234567890"
    @State private var sensitiveData: String = ""
    @State private var normalData: String = ""
    @State private var normalData2: String = ""
    @State private var isPasswordVisible: Bool = false
    
    @State private var currentPasteboardData: String = "尚未讀取"
    @State private var expirationSeconds: Double = 60.0
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer? = nil
    // 控制是否啟用過期時間的開關
    @State private var hasExpiration: Bool = true
    // 記錄當前剪貼簿資料是否為永久有效
    @State private var isPermanent: Bool = false
    @State private var targetExpirationDate: Date? = nil
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
            
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    
                    
                    // MARK: - 顯示當前剪貼簿區塊
                    VStack(alignment: .leading, spacing: 10) {
                        Text("當前剪貼簿內容：")
                            .font(.headline)
                        
                        // 顯示讀取到的內容
                        Text(currentPasteboardData)
                            .foregroundColor(currentPasteboardData == "尚未讀取" ? .gray : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        // 判斷要顯示「倒數計時」還是「永久有效」
                        if isPermanent {
                            Text("⏱ 狀態：永久有效 (無過期時間)")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .bold()
                        } else if timeRemaining > 0 {
                            Text("⏱ 倒數：\(timeRemaining) 秒")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .bold()
                        }
                            Toggle("啟用剪貼簿安全模式", isOn: $hasExpiration)
                                .tint(.blue)
                            if hasExpiration {
                                // Slider 動態調整區塊
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("剪貼簿過期時間：\(Int(expirationSeconds)) 秒")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    // 設定 Slider 範圍為 10秒 ~ 120秒，每次滑動單位為 10秒
                                    Slider(value: $expirationSeconds, in: 10...120, step: 10)
                                        .accentColor(.blue)
                                }
                                .padding(.horizontal)
                            }
                            
                        
                        // 讀取按鈕
                        Button(action: {
                            hideKeyboardAction()
                            readFromPasteboard()
                        }) {
                            Text("讀取系統剪貼簿")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    Divider() // 加一條分隔線
                    HStack {
                        Text("銀行帳戶")
                        Text("\(account)")
                        // 安全複製按鈕
                        Button(action: {
                            copyToSecurePasteboard(text: account)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 20)) // 調整圖示大小，像調整字體一樣
                                .foregroundColor(.blue) // 調整圖示顏色
                        }
                        
                    }
                    // MARK: 密碼輸入與眼睛開關區塊
                    HStack {
                        // 使用我們自訂的 TextField
                        CustomSecureTextField(
                            placeholder: "自定義欄位",
                            text: $sensitiveData,
                            isVisible: $isPasswordVisible,
                            isSecureMode: hasExpiration
                        )
                        // 為了確保高度與一般 SwiftUI TextField 一致
                        .frame(height: 24)
                        .id(hasExpiration)
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                            // 加上 .padding(.leading) 增加點擊範圍
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    
                    
                    TextField(
                        "一般欄位",
                        text: $normalData
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    SecureField(
                        "一般敏感欄位",
                        text: $normalData2
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboardAction()
            }
        }
        
        // MASTG-TEST-0278：退到背景時自動清空剪貼簿
        .onScenePhaseChange(phase: scenePhase) { newPhase in
            if newPhase == .background {
                clearPasteboard()
                currentPasteboardData = "App 進入背景，已自動清空"
                timer?.invalidate()
                timeRemaining = 0
            }
        }
    }
    
    // MARK: - 安全複製邏輯
    private func copyToSecurePasteboard(text: String) {
        guard !text.isEmpty else { return }
        
        // 準備選項字典，預設仍限制在本機 (0280規範)
        var options: [UIPasteboard.OptionsKey: Any] = [
            .localOnly: true
        ]
        
        // 💡 依據開關決定是否加入過期時間
        if hasExpiration {
            let expDate = Date().addingTimeInterval(expirationSeconds)
            options[.expirationDate] = expDate
            
            self.targetExpirationDate = expDate
            self.isPermanent = false // 標記為會過期
            
            startRealCountdown(to: expDate)
            print("資料已安全複製：設定為 \(Int(expirationSeconds)) 秒後過期。")
        } else {
            // 沒有加入 .expirationDate，代表永久有效
            self.targetExpirationDate = nil
            self.isPermanent = true // 標記為永久有效
            self.stopTimer() // 停止計時器
            
            print("資料已複製：⚠️ 未設定過期時間 (永久有效)。")
        }
        
        let pasteboardItem: [String: Any] = [
            UTType.utf8PlainText.identifier: text
        ]
        
        UIPasteboard.general.setItems([pasteboardItem], options: options)
        
    }
    
    // MARK: - 清除剪貼簿邏輯
    private func clearPasteboard() {
        UIPasteboard.general.items = []
        print("App 進入背景，剪貼簿已清空。")
    }
    // MARK: - 倒數計時邏輯
    private func startCountdown() {
        // 💡 計時器的起始時間也同步為 Slider 決定的秒數
        timeRemaining = Int(expirationSeconds)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }
    
    // MARK: - 計時器與讀取邏輯
    private func startRealCountdown(to targetDate: Date) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let remaining = targetDate.timeIntervalSinceNow
            if remaining > 0 {
                self.timeRemaining = Int(remaining)
            } else {
                self.stopTimer()
            }
        }
    }
    private func stopTimer() {
        timer?.invalidate()
        timeRemaining = 0
        targetExpirationDate = nil
    }
    // MARK: - 讀取剪貼簿邏輯
    private func readFromPasteboard() {
        // 嘗試讀取剪貼簿中的字串
        if let stringContent = UIPasteboard.general.string {
            currentPasteboardData = stringContent
            print("成功讀取剪貼簿：\(stringContent)")
        } else {
            currentPasteboardData = "剪貼簿目前為空，或是非純文字格式。"
            print("剪貼簿為空。")
        }
    }
    
}


#Preview {
    SecurePasteboardView()
}


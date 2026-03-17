## MASTG-TEST-0073: Testing UIPasteboard
- [OWASP][1]

## MASTG v2
- [MASTG-TEST-0276:][5] Use of the iOS General Pasteboard
- [MASTG-TEST-0277:][6] Sensitive Data in the iOS General Pasteboard at Runtime
- [MASTG-TEST-0278:][7] Pasteboard Contents Not Cleared After Use
- [MASTG-TEST-0279:][8] Pasteboard Contents Not Expiring
- [MASTG-TEST-0280:][9] Pasteboard Contents Not Restricted to Local Device

## 建議解決方案
1. 使用自定義TextField，可將"剪下"、"複製"功能移除。
2. 讓TextField中的text變為不可選取的狀態。
3. 若想維持"複製"功能，又不被駭客監聽欄位的輸入字串，可針對剪貼簿加密。

## 參考範例程式
- [自定義TextField][3]
- [剪貼簿加密][4] 連結做法不算加密而是編碼，請將編碼的部分改成安全的加密方法即可。

## 📸 Screenshots
<img width="300" height="600" src="https://github.com/VisionAce/Screenshoots/blob/main/Simulator%20Screen%20Recording%20-%20iPhone%2015%20Pro%20-%202024-09-25%20at%2001.37.02.gif"/>

[1]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0073/
[2]: https://blog.eidinger.info/prevent-copy-paste-into-other-ios-apps
[3]: https://github.com/VisionAce/PreventCopyPasteboard/blob/main/PreventCopyPasteboard/CustomTextField.swift
[4]: https://blog.stackademic.com/protect-copied-text-ios-77eecba9d5ea
[5]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0276/
[6]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0277/
[7]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0278/
[8]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0279/
[9]: https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0280/

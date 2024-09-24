//
//  Keyboard.swift
//  EnVocabMaster
//
//  Created by 褚宣德 on 2023/10/27.
//

import SwiftUI

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged { _ in
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func dismissKeyboard() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

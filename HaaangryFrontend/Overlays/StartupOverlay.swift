//
//  StartupOverlay.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/26/25.
//

import Foundation
import SwiftUI

struct StartupOverlay: View {
    @Binding var isVisible: Bool
    @State private var breathe = false

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.ignoresSafeArea()

                Text("feelin haaangry?...")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(breathe ? 1.0 : 0.6)
                    .scaleEffect(breathe ? 1.0 : 0.98)
                    .accessibilityIdentifier("StartupSlogan")
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
            .transition(.opacity)
            .zIndex(999)
        }
    }
}

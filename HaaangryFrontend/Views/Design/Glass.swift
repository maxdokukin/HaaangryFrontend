//
//  Glass.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/25/25.
//

import Foundation
// Views/Design/Glass.swift
import SwiftUI

// MARK: - Liquid Glass Design System (iOS 16+ safe)

public struct Glass {
    static func strokeShape<S: InsettableShape>(_ shape: S) -> some View {
        shape
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.55),
                        .white.opacity(0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    static func highlight<S: InsettableShape>(_ shape: S) -> some View {
        shape
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0.18),
                        .white.opacity(0.04),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.screen)
    }
}

// MARK: - Containers

struct GlassContainer: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    var shadowRadius: CGFloat = 10

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.highlight(shape).allowsHitTesting(false))
            .overlay(Glass.strokeShape(shape))
            .shadow(color: .black.opacity(0.35), radius: shadowRadius, x: 0, y: 6)
    }
}

extension View {
    func glassContainer(cornerRadius: CGFloat = 16, padding: CGFloat = 12, shadowRadius: CGFloat = 10) -> some View {
        modifier(GlassContainer(cornerRadius: cornerRadius, padding: padding, shadowRadius: shadowRadius))
    }
}

// MARK: - Buttons

struct GlassButtonStyle: ButtonStyle {
    enum Prominence { case standard, prominent }
    var prominence: Prominence = .standard
    var capsule: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let base: AnyInsettableShape = capsule
            ? AnyInsettableShape(Capsule())
            : AnyInsettableShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        return configuration.label
            .font(prominence == .prominent ? .headline : .subheadline)
            .padding(.horizontal, prominence == .prominent ? 18 : 14)
            .padding(.vertical, prominence == .prominent ? 12 : 9)
            .frame(minHeight: prominence == .prominent ? 44 : 36)
            .background(.ultraThinMaterial, in: base)
            .overlay(Glass.highlight(base).allowsHitTesting(false))
            .overlay(Glass.strokeShape(base))
            .shadow(color: .black.opacity(0.35), radius: prominence == .prominent ? 12 : 8, x: 0, y: prominence == .prominent ? 8 : 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let shape = Circle()
        return configuration.label
            .font(.headline)
            .padding(10)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.highlight(shape).allowsHitTesting(false))
            .overlay(Glass.strokeShape(shape))
            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

extension View {
    func glassButton() -> some View { buttonStyle(GlassButtonStyle()) }
    func glassButtonProminent(capsule: Bool = true) -> some View { buttonStyle(GlassButtonStyle(prominence: .prominent, capsule: capsule)) }
    func glassIconButton() -> some View { buttonStyle(GlassIconButtonStyle()) }
}

// MARK: - Fields

struct GlassField: ViewModifier {
    var cornerRadius: CGFloat = 14
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .padding(12)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.highlight(shape).allowsHitTesting(false))
            .overlay(Glass.strokeShape(shape))
    }
}

extension View {
    func glassField(cornerRadius: CGFloat = 14) -> some View { modifier(GlassField(cornerRadius: cornerRadius)) }
}

// MARK: - Type erasure for InsettableShape

struct AnyInsettableShape: InsettableShape {
    private let _path: (CGRect, CGFloat) -> Path
    private var insetAmount: CGFloat = 0

    init<S: InsettableShape>(_ base: S) {
        _path = { rect, inset in
            base.inset(by: inset).path(in: rect)
        }
    }

    func inset(by amount: CGFloat) -> AnyInsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        _path(rect, insetAmount)
    }
}

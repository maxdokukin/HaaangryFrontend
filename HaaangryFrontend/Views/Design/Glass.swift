//
//  Glass.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/25/25.
//

import Foundation
// Views/Design/Glass.swift
import SwiftUI

// MARK: - Liquid Glass primitives

public struct Glass {
    static func stroke<S: InsettableShape>(_ shape: S) -> some View {
        shape.stroke(
            LinearGradient(
                colors: [.white.opacity(0.55), .white.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1
        )
    }

    static func gloss<S: InsettableShape>(_ shape: S) -> some View {
        shape
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.22), .white.opacity(0.06), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.screen)
    }
}

// MARK: - Containers

struct GlassContainer: ViewModifier {
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 12
    var shadowRadius: CGFloat = 10

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.gloss(shape).allowsHitTesting(false))
            .overlay(Glass.stroke(shape))
            .shadow(color: .black.opacity(0.35), radius: shadowRadius, x: 0, y: 6)
    }
}

extension View {
    func glassContainer(cornerRadius: CGFloat = 18, padding: CGFloat = 12, shadowRadius: CGFloat = 10) -> some View {
        modifier(GlassContainer(cornerRadius: cornerRadius, padding: padding, shadowRadius: shadowRadius))
    }
}

// MARK: - Buttons

struct GlassButtonStyle: ButtonStyle {
    enum Prominence { case standard, prominent }
    var prominence: Prominence = .standard
    var capsule: Bool = true
    var width: CGFloat? = nil
    var height: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        let base: AnyInsettableShape = capsule
            ? AnyInsettableShape(Capsule())
            : AnyInsettableShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

        configuration.label
            .font(prominence == .prominent ? .headline : .subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 12)
            .frame(width: width, height: height)
            .background(.ultraThinMaterial, in: base)
            .overlay(Glass.gloss(base).allowsHitTesting(false))
            .overlay(Glass.stroke(base))
            .shadow(color: .black.opacity(0.35), radius: prominence == .prominent ? 12 : 8, x: 0, y: prominence == .prominent ? 8 : 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct GlassIconButtonStyle: ButtonStyle {
    var size: CGFloat = 40
    func makeBody(configuration: Configuration) -> some View {
        let shape = Circle()
        configuration.label
            .font(.headline)
            .frame(width: size, height: size)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.gloss(shape).allowsHitTesting(false))
            .overlay(Glass.stroke(shape))
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 7)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

extension View {
    func glassButton(width: CGFloat? = nil, height: CGFloat = 44) -> some View {
        buttonStyle(GlassButtonStyle(width: width, height: height))
    }
    func glassButtonProminent(width: CGFloat? = nil, height: CGFloat = 48, capsule: Bool = true) -> some View {
        buttonStyle(GlassButtonStyle(prominence: .prominent, capsule: capsule, width: width, height: height))
    }
    func glassIconButton(size: CGFloat = 40) -> some View { buttonStyle(GlassIconButtonStyle(size: size)) }
}

// MARK: - Fields

struct GlassField: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .padding(12)
            .background(.ultraThinMaterial, in: shape)
            .overlay(Glass.gloss(shape).allowsHitTesting(false))
            .overlay(Glass.stroke(shape))
    }
}

extension View {
    func glassField(cornerRadius: CGFloat = 16) -> some View { modifier(GlassField(cornerRadius: cornerRadius)) }
}

// MARK: - Type-erased InsettableShape

struct AnyInsettableShape: InsettableShape {
    private let _path: (CGRect, CGFloat) -> Path
    private var insetAmount: CGFloat = 0

    init<S: InsettableShape>(_ base: S) {
        _path = { rect, inset in base.inset(by: inset).path(in: rect) }
    }

    func inset(by amount: CGFloat) -> AnyInsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path { _path(rect, insetAmount) }
}

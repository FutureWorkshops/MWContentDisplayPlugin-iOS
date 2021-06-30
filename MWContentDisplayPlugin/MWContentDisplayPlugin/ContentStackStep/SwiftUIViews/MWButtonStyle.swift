//
//  MWButtonStyle.swift
//  MWContentDisplayPlugin
//
//  Created by Eric Sans on 29/6/21.
//

import SwiftUI

public enum Style: String, Codable {
    case primary
    case danger
    case outline
    case textOnly
}

struct MWButtonStyle: ButtonStyle {
    let style: Style
    let systemTintColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        MWButtonStyleView(configuration: configuration, style: style, systemTintColor: systemTintColor)
    }
}

private extension MWButtonStyle {
    
    struct MWButtonStyleView: View {
        let configuration: MWButtonStyle.Configuration
        let style: Style
        let systemTintColor: Color
        
        var backgroundColor: Color {
            switch style {
            case .primary:
                return systemTintColor
            case .danger:
                return .red
            case .outline, .textOnly:
                // Trick to have a view that can be tapped. If color is clear, only text is tappable.
                return .white.opacity(0.01)
            }
        }
        
        var borderColor: Color {
            switch style {
            case .primary, .danger, .textOnly:
                return .clear
            case .outline:
                return systemTintColor
            }
        }
        
        var tintColor: Color {
            switch style {
            case .primary, .danger:
                return .white
            case .outline, .textOnly:
                return systemTintColor
            }
        }
        
        let cornerRadius: CGFloat = 16
        
        var body: some View {
            configuration.label
                .foregroundColor(tintColor)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor)
                        )
                )
                .opacity(configuration.isPressed ? 0.8 : 1.0)
        }
    }
}

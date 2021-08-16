//
//  Color+Extensions.swift
//  MWContentDisplayPlugin
//
//  Created by Eric Sans on 16/8/21.
//

import SwiftUI

// MARK: - Convenience for system colors

extension Color {
    
    enum StyleVariant {
        case primary
        case secondary
        case tertiary
        case quaternary
    }
    
    static func label(_ type: StyleVariant) -> Color {
        switch type {
        case .primary:
            return Color(UIColor.label)
        case .secondary:
            return Color(UIColor.secondaryLabel)
        case .tertiary:
            return Color(UIColor.tertiaryLabel)
        case .quaternary:
            return Color(UIColor.quaternaryLabel)
        }
    }
    
    static func systemFill(_ type: StyleVariant) -> Color {
        switch type {
        case .primary:
            return Color(UIColor.systemFill)
        case .secondary:
            return Color(UIColor.secondarySystemFill)
        case .tertiary:
            return Color(UIColor.tertiarySystemFill)
        case .quaternary:
            return Color(UIColor.quaternarySystemFill)
        }
    }
}

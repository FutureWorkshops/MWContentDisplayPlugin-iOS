//
//  MWButtonView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI

struct MWButtonView: View {
    
    let item: MWStackStepItemButton
    var tapped: (_ item: MWStackStepItemButton, _ rect: CGRect) -> Void
    var systemTintColor: Color
    
    var body: some View {
        // Needs GeometryReader to send back the frame of the button for popOver purposes
        GeometryReader { geo in
            Button {
                tapped(self.item, geo.frame(in: .global))
            } label: {
                HStack(spacing: 4) {
                    if let systemName = self.item.sfSymbolName {
                        Image(systemName: systemName)
                    }
                    Text(item.label)
                        .font(Font(UIFont.preferredFont(forTextStyle: .body, weight: .bold)))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
        .buttonStyle(MWButtonStyle(style: self.item.style, systemTintColor: self.systemTintColor))
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

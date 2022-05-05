//
//  MWStackContentScrollView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI

struct MWStackContentScrollView: View {
    var contents: MWStackStepContents
    var buttonTapped: (MWStackStepItemButton, CGRect) -> Void
    var tintColor: UIColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(contents.items) { item in
                switch item {
                case .title(let innerItem): MWTitleView(item: innerItem)
                case .text(let innerItem): MWTextView(item: innerItem).padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
                case .listItem(let innerItem): MWListItemView(item: innerItem)
                case .button(let innerItem): MWButtonView(item: innerItem, tapped: buttonTapped, systemTintColor: Color(tintColor))
                case .space(let spaceItem): MWSpaceView(item: spaceItem)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
    }
}

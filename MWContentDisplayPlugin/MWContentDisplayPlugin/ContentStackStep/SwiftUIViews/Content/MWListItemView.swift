//
//  MWListItemView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI
import Kingfisher
import MobileWorkflowCore

struct MWListItemView: View {
    
    let item: MWStackStepItemListItem
    let theme: Theme
    
    var body: some View {
        HStack {
            if let imageURL = self.item.imageURL {
                KFImage(imageURL)
                    .placeholder {
                        self.makeImagePlaceholder()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48, alignment: .center)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                if let title = self.item.title {
                    Text(title)
                        .font(.body)
                }
                if let detailText = self.item.detailText {
                    Text(detailText)
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
        }
    }
    
    func makeImagePlaceholder() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(self.theme.imagePlaceholderBackgroundColor))
                .frame(width: 48, height: 48, alignment: .center)
            Image(systemName: "photo")
                .foregroundColor(Color(self.theme.secondaryTextColor))
        }
    }
}

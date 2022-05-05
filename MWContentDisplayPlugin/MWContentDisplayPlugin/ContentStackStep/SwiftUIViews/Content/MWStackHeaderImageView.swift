//
//  MWStackHeaderImageView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI
import Kingfisher
import MobileWorkflowCore

struct MWStackHeaderImageView: View {
    let headerImageURL: URL
    let headerHeight: CGFloat
    let safeAreaInsets: EdgeInsets
    let headerStyle: MWStackStepContents.HeaderStyle
    let theme: Theme
    
    var body: some View {
        let kfImage = KFImage(self.headerImageURL)
                        .placeholder {
                            self.makeImagePlaceholder()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
        
        switch self.headerStyle {
        case .fullWidth:
            kfImage
        case .profile:
            let edgeInsets = EdgeInsets(top: self.safeAreaInsets.top, leading: 0, bottom: 70.0, trailing: 0)
            let imageSize = self.headerHeight - edgeInsets.top - edgeInsets.bottom
            kfImage
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .cornerRadius(imageSize/2)
                .padding(edgeInsets)
        }
    }
    
    private func makeImagePlaceholder() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(self.theme.imagePlaceholderBackgroundColor))
            Image(systemName: "photo")
                .foregroundColor(Color(self.theme.secondaryTextColor))
                .font(.largeTitle)
        }
    }
}

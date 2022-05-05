//
//  MWStackView.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import SwiftUI
import Kingfisher
import Foundation
import MobileWorkflowCore

struct MWStackView: View {
    
    let contents: MWStackStepContents
    let backButtonTapped: () -> Void
    let buttonTapped: (MWStackStepItemButton, CGRect) -> Void
    let theme: Theme
    
    let isCloseButtonEnabled: Bool
    let isBackButtonEnabled: Bool
    
    var body: some View {
        let content = MWStackContentScrollView(
            contents: self.contents,
            buttonTapped: self.buttonTapped,
            theme: self.theme
        )
        
        GeometryReader { geometry in
            if let headerImageURL = contents.headerImageURL {
                let headerHeight: CGFloat = 280.0
                FancyScrollView(
                    title: contents.headerTitle ?? "",
                    headerHeight: headerHeight,
                    scrollUpHeaderBehavior: .parallax,
                    scrollDownHeaderBehavior: .sticky,
                    header: {
                        MWStackHeaderImageView(
                            headerImageURL: headerImageURL,
                            headerHeight: headerHeight,
                            safeAreaInsets: geometry.safeAreaInsets,
                            headerStyle: contents.headerStyle,
                            theme: self.theme
                        )
                    },
                    content: { content },
                    isCloseButtonEnabled: self.isCloseButtonEnabled,
                    isBackButtonEnabled: self.isBackButtonEnabled,
                    backButtonTapped: self.backButtonTapped
                )
            } else {
                /// Need to use non-header init to ensure correct scroll offset
                FancyScrollView(
                    content: { content },
                    isCloseButtonEnabled: self.isCloseButtonEnabled,
                    isBackButtonEnabled: self.isBackButtonEnabled,
                    backButtonTapped: self.backButtonTapped
                )
            }
        }
    }
}

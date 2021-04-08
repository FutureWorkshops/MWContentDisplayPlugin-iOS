//
//  MWStackView.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import SwiftUI
import Kingfisher
import Foundation
import FancyScrollView

struct MWStackView: View {
    
    var step: MWStackStep
    
    var body: some View {
        self.makeScrollView()
    }
    
    private func makeScrollView() -> some View {
        // You'd think that setting the `headerHeight` to 0.0 and return nil on the header if there's no `headerImageURL` would
        // work, but it doesn't. If you don't use the correct init (the one that doesn't expect a header), the offset
        // of the ScrollView is completely broken.
        if let headerImageURL = self.step.headerImageURL {
            return FancyScrollView(title: self.step.title ?? "", headerHeight: 350.0, scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky, header: {
                KFImage(headerImageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }, content: {
                self.makeContentScrollView()
            })
        } else {
            return FancyScrollView {
                self.makeContentScrollView()
            }
        }
    }
    
    private func makeContentScrollView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(self.step.items) { item in
                switch item {
                case .title(let innerItem): MWTitleView(item: innerItem)
                case .text(let innerItem): MWTextView(item: innerItem)
                case .listItem(let innerItem): MWListItemView(stepTypeListItem: innerItem)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

fileprivate struct MWTitleView: View {
    
    let item: StepItemTitle
        
    var body: some View {
        Text(item.title).font(.largeTitle)
    }
}

fileprivate struct MWTextView: View {
    
    let item: StepItemText
        
    var body: some View {
        Text(item.text)
    }
}

fileprivate struct MWListItemView: View {
    
    let stepTypeListItem: StepItemListItem
    
    var body: some View {
        HStack {
            if let imageURL = stepTypeListItem.imageURL {
                KFImage(imageURL)
                    .placeholder {
                        makeImagePlaceholder()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44, alignment: .center)
                    .cornerRadius(4.0)
            }
            VStack(alignment: .leading) {
                if let title = stepTypeListItem.title {
                    Text(title)
                        .fontWeight(.semibold)
                }
                if let detailText = stepTypeListItem.detailText {
                    Text(detailText)
                }
            }
        }
    }
    
    func makeImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 4.0)
            .fill(Color.gray)
            .frame(width: 44, height: 44, alignment: .center)
    }
}

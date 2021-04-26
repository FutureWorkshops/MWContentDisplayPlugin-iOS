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
    
    var contents: MWStackStepContents
    
    var body: some View {
        self.makeScrollView()
    }
    
    private func makeScrollView() -> some View {
        // You'd think that setting the `headerHeight` to 0.0 and return nil on the header if there's no `headerImageURL` would
        // work, but it doesn't. If you don't use the correct init (the one that doesn't expect a header), the offset
        // of the ScrollView is completely broken.
        if let headerImageURL = contents.headerImageURL {
            return FancyScrollView(title: contents.headerTitle ?? "", headerHeight: 280, scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky, header: {
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
            ForEach(contents.items) { item in
                switch item {
                case .title(let innerItem): MWTitleView(item: innerItem)
                case .text(let innerItem): MWTextView(item: innerItem).padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
                case .listItem(let innerItem): MWListItemView(stepTypeListItem: innerItem)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
    }
}

fileprivate struct MWTitleView: View {
    
    let item: MWStackStepItemTitle
        
    var body: some View {
        Text(item.title).font(.system(size: 24, weight: .bold))
    }
}

fileprivate struct MWTextView: View {
    
    let item: MWStackStepItemText
        
    var body: some View {
        Text(item.text).font(.system(size: 17, weight: .regular))
    }
}

fileprivate struct MWListItemView: View {
    
    let stepTypeListItem: MWStackStepStepItemListItem
    
    var body: some View {
        HStack {
            if let imageURL = stepTypeListItem.imageURL {
                KFImage(imageURL)
                    .placeholder {
                        makeImagePlaceholder()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48, alignment: .center)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                if let title = stepTypeListItem.title {
                    Text(title)
                        .font(.system(size: 17, weight: .regular))
                }
                if let detailText = stepTypeListItem.detailText {
                    Text(detailText)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(.displayP3, red: 60/255, green: 60/255, blue: 67/255, opacity: 0.6))
                }
            }
        }
    }
    
    func makeImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray)
            .frame(width: 48, height: 48, alignment: .center)
    }
}

//
//  MWStackView.swift
//  MWContentDisplayPlugin
//
//  Created by Xavi Moll on 8/4/21.
//

import SwiftUI
import Kingfisher
import Foundation

struct MWStackView: View {
    
    var contents: MWStackStepContents
    var backButtonTapped: () -> Void
    var buttonTapped: (MWStackStepItemButton, CGRect) -> Void
    var tintColor: UIColor
    
    let isCloseButtonEnabled: Bool
    let isBackButtonEnabled: Bool
    
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
                    .placeholder {
                        makeImagePlaceholder()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }, content: {
                self.makeContentScrollView()
            }, isCloseButtonEnabled: isCloseButtonEnabled,
            isBackButtonEnabled: isBackButtonEnabled,
            backButtonTapped: self.backButtonTapped)
        } else {
            return FancyScrollView(content: {
                self.makeContentScrollView()
            }, isCloseButtonEnabled: isCloseButtonEnabled,
            isBackButtonEnabled: isBackButtonEnabled,
            backButtonTapped: self.backButtonTapped)
        }
    }
    
    private func makeImagePlaceholder() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.systemFill(.secondary))
            Image(systemName: "photo")
                .foregroundColor(Color.label(.tertiary))
                .font(.largeTitle)
        }    }
    
    private func makeContentScrollView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(contents.items) { item in
                switch item {
                case .title(let innerItem): MWTitleView(item: innerItem)
                case .text(let innerItem): MWTextView(item: innerItem).padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
                case .listItem(let innerItem): MWListItemView(stepTypeListItem: innerItem)
                case .button(let innerItem): MWButtonView(item: innerItem, tapped: buttonTapped, systemTintColor: Color(tintColor))
                case .space(let spaceItem): MWSpaceView(item: spaceItem)
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
        Text(item.title).font(Font(UIFont.preferredFont(forTextStyle: .title3, weight: .bold)))
            .fixedSize(horizontal: false, vertical: true)
    }
}

fileprivate struct MWTextView: View {
    
    let item: MWStackStepItemText
        
    var body: some View {
        Text(item.text).font(.body)
            .fixedSize(horizontal: false, vertical: true)
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
                        .font(.body)
                }
                if let detailText = stepTypeListItem.detailText {
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
                .fill(Color.systemFill(.secondary))
                .frame(width: 48, height: 48, alignment: .center)
            Image(systemName: "photo")
                .foregroundColor(Color.label(.tertiary))
        }
    }
}

#warning("Button height is currently set to 44pt to match RK Button. Once we get rid of Research Kit, we'll provide the same height (as per design guidelines 50pt) in both Core and Plugins.")
fileprivate struct MWButtonView: View {
    
    let item: MWStackStepItemButton
    var tapped: (_ item: MWStackStepItemButton, _ rect: CGRect) -> Void
    var systemTintColor: Color
    
    var body: some View {
        // Needs GeometryReader to send back the frame of the button for popOver purposes
        GeometryReader { geo in
            Button {
                tapped(item, geo.frame(in: .global))
            } label: {
                HStack(spacing: 4) {
                    if let systemName = item.sfSymbolName {
                        Image(systemName: systemName)
                    }
                    Text(item.label)
                        .font(Font(UIFont.preferredFont(forTextStyle: .body, weight: .bold)))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, idealHeight: 44, maxHeight: 44, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 44, maxHeight: 44, alignment: .center)
        .buttonStyle(MWButtonStyle(style: item.style, systemTintColor: systemTintColor))
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

fileprivate struct MWSpaceView: View {
    
    let item: MWStackStepItemSpace
    
    var body: some View {
        Spacer(minLength: item.height ?? 44.0)
    }
}

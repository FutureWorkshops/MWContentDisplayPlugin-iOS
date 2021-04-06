//
//  MWContentStackViewController.swift
//  MWVideoGridPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import Kingfisher
import FancyScrollView
import MobileWorkflowCore

final class MWContentStackViewController: ORKStepViewController {
    
    var contentStackStep: MWContentStackStep { self.step as! MWContentStackStep }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(rootView: MWContentView(step: self.contentStackStep)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.alpha = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.alpha = 1.0
    }
    
}

private struct MWContentView: View {
    
    @State var step: MWContentStackStep
    
    var body: some View {
        FancyScrollView(title: self.step.title ?? "", headerHeight: 350.0, scrollUpHeaderBehavior: .parallax, scrollDownHeaderBehavior: .sticky, header: {
            KFImage(self.step.headerImageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }, content: {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(self.step.items) { item in
                    switch item {
                    case .title(let innerItem): MWTitleView(stepTypeTitle: innerItem)
                    case .text(let innerItem): MWTextView(stepTypeText: innerItem)
                    case .listItem(let innerItem): MWListItemView(stepTypeListItem: innerItem)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        })
        // The FancyScrollView sets this to true but that breaks the swipe back gesture
        // To fix it, we just set the alpha of the navBar to 0 or 1
        .navigationBarHidden(false)
    }
}

private struct MWTitleView: View {
    
    let stepTypeTitle: StepItemTitle
        
    var body: some View {
        Text(stepTypeTitle.title ?? "MISSING_TITLE")
            .font(.largeTitle)
    }
}

private struct MWTextView: View {
    
    let stepTypeText: StepItemText
        
    var body: some View {
        Text(stepTypeText.text ?? "MISSING_TEXT")
    }
}

private struct MWListItemView: View {
    
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
            } else {
                makeImagePlaceholder()
            }
            VStack(alignment: .leading) {
                Text(stepTypeListItem.title ?? "MISSING_TITLE")
                    .fontWeight(.semibold)
                Text(stepTypeListItem.detailText ?? "MISSING_DETAIL_TEXT")
            }
        }
    }
    
    func makeImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 4.0)
            .fill(Color.gray)
            .frame(width: 44, height: 44, alignment: .center)
    }
}

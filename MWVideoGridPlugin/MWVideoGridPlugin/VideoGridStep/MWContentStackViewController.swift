//
//  MWContentStackViewController.swift
//  MWVideoGridPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import UIKit
import SwiftUI
import MobileWorkflowCore

final class MWContentStackViewController: ORKStepViewController {
    
    var contentStackStep: MWContentStackStep { self.step as! MWContentStackStep }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(rootView: MWContentView(step: self.contentStackStep)))
    }
    
}

private struct MWContentView: View {
    
    @State var step: MWContentStackStep
    
    var body: some View {
        ScrollView {
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
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
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
            #warning("Ignoring the image until we can load it correctly")
            if let _ = stepTypeListItem.imageURL {
                Image(systemName: "opticaldisc")
                    .resizable()
                    .frame(width: 44, height: 44, alignment: .center)
            }
            VStack(alignment: .leading) {
                Text(stepTypeListItem.title ?? "MISSING_TITLE")
                    .fontWeight(.semibold)
                Text(stepTypeListItem.detailText ?? "MISSING_DETAIL_TEXT")
            }
        }
    }
}

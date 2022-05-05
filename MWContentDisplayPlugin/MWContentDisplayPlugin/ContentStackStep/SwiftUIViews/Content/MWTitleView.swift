//
//  MWTitleView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI

struct MWTitleView: View {
    
    let item: MWStackStepItemTitle
        
    var body: some View {
        Text(self.item.title).font(Font(UIFont.preferredFont(forTextStyle: .title3, weight: .bold)))
            .fixedSize(horizontal: false, vertical: true)
    }
}

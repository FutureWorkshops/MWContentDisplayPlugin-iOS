//
//  MWTextView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI

struct MWTextView: View {
    
    let item: MWStackStepItemText
        
    var body: some View {
        Text(self.item.text).font(.body)
            .fixedSize(horizontal: false, vertical: true)
    }
}

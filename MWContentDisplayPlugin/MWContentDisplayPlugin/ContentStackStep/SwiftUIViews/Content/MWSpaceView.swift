//
//  MWSpaceView.swift
//  MWContentDisplayPlugin
//
//  Created by Jonathan Flintham on 05/05/2022.
//

import Foundation
import SwiftUI

struct MWSpaceView: View {
    
    let item: MWStackStepItemSpace
    
    var body: some View {
        Spacer(minLength: item.height ?? 44.0)
    }
}

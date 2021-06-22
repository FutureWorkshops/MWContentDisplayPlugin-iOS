//
//  CloseButton.swift
//  MWContentDisplayPlugin
//
//  Created by Eric Sans on 22/6/21.
//

import SwiftUI

struct CloseButton: View {
    let color: Color
    
    var closeButtonTapped: () -> Void

    var body: some View {
        Button(action: { self.closeButtonTapped() }) {
            ZStack {
                Rectangle()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color(red: 28/255, green: 28/255, blue: 30/255))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .opacity(0.4)
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20, alignment: .leading)
                    .foregroundColor(color)
                    .padding(.horizontal, 16)
                    .font(Font.body.bold())
            }
        }
    }
}

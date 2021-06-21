import SwiftUI

struct HeaderScrollViewTitle: View {
    let title: String
    let height: CGFloat
    let largeTitle: Double
    var backButtonTapped: () -> Void
    
    let isBackButtonEnabled: Bool

    var body: some View {
        let largeTitleOpacity = (max(largeTitle, 0.5) - 0.5) * 2
        let tinyTitleOpacity = 1 - min(largeTitle, 0.5) * 2
        return ZStack {
            HStack {
                Text(title)
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.bottom, 8)
            .background(
                LinearGradient(gradient: Gradient(colors: [.clear, Color(UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 0.8))]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 80)
                    .offset(y: -18)
            )
            .opacity(sqrt(largeTitleOpacity))
            .minimumScaleFactor(0.5)

            ZStack {
                if isBackButtonEnabled {
                    HStack {
                        BackButton(color: .primary, backButtonTapped: self.backButtonTapped)
                        Spacer()
                    }
                }
                HStack {
                    Text(title)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, (height - 18) / 2)
            .opacity(sqrt(tinyTitleOpacity))
        }.frame(height: height)
    }
}

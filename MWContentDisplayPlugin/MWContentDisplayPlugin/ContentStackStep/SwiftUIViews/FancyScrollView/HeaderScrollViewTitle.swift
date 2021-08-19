import SwiftUI

struct HeaderScrollViewTitle: View {
    let title: String
    let height: CGFloat
    let largeTitle: Double
    var backButtonTapped: () -> Void
    
    let isCloseButtonEnabled: Bool
    let isBackButtonEnabled: Bool
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

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
            .padding(.bottom, 16)
            .background(
                self.makeLinearGradient()
                    .frame(height: 90)
                    .offset(y: -22)
            )
            .opacity(sqrt(largeTitleOpacity))
            .minimumScaleFactor(0.5)

            ZStack {
                if isBackButtonEnabled {
                    HStack {
                        BackButton(color: .primary, backButtonTapped: self.backButtonTapped)
                        Spacer()
                    }
                } else if isCloseButtonEnabled {
                    HStack {
                        Spacer()
                        CloseButton(color: .primary, closeButtonTapped: self.backButtonTapped)
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
    
    private func makeLinearGradient() -> LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top)
    }
}

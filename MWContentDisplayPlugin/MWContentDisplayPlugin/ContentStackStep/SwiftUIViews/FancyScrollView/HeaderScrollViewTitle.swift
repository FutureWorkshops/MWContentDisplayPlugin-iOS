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
        if colorScheme == .dark {
            return LinearGradient(gradient: Gradient(colors: [.clear, Color(UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 0.8))]), startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(gradient: Gradient(colors: [.clear, Color(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))]), startPoint: .top, endPoint: .bottom)
        }
    }
}

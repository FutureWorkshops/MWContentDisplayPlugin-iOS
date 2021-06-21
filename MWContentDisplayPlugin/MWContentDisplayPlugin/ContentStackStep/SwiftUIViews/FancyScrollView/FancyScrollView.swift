import SwiftUI

// Original code: https://github.com/nerdsupremacist/FancyScrollView

public struct FancyScrollView: View {
    let title: String
    let headerHeight: CGFloat
    let scrollUpHeaderBehavior: ScrollUpHeaderBehavior
    let scrollDownHeaderBehavior: ScrollDownHeaderBehavior
    let header: AnyView?
    let content: AnyView
    
    let isBackButtonEnabled: Bool
    var backButtonTapped: () -> Void

    public var body: some View {
        if let header = header {
            return AnyView(
                HeaderScrollView(title: title,
                                 headerHeight: headerHeight,
                                 scrollUpBehavior: scrollUpHeaderBehavior,
                                 scrollDownBehavior: scrollDownHeaderBehavior,
                                 header: header,
                                 content: content,
                                 isBackButtonEnabled: isBackButtonEnabled,
                                 backButtonTapped: self.backButtonTapped)
            )
        } else {
            return AnyView(
                AppleMusicStyleScrollView {
                    VStack {
                        title != "" ? HStack {
                            Text(title)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .fontWeight(.black)
                                .padding(.horizontal, 16)

                            Spacer()
                        } : nil

                        title != "" ? Spacer() : nil

                        content
                    }
                }
            )
        }
    }
}

extension FancyScrollView {

    public init<A: View, B: View>(title: String = "",
                                  headerHeight: CGFloat = 300,
                                  scrollUpHeaderBehavior: ScrollUpHeaderBehavior = .parallax,
                                  scrollDownHeaderBehavior: ScrollDownHeaderBehavior = .offset,
                                  header: () -> A?,
                                  content: () -> B,
                                  isBackButtonEnabled: Bool,
                                  backButtonTapped: @escaping () -> Void) {

        self.init(title: title,
                  headerHeight: headerHeight,
                  scrollUpHeaderBehavior: scrollUpHeaderBehavior,
                  scrollDownHeaderBehavior: scrollDownHeaderBehavior,
                  header: AnyView(header()),
                  content: AnyView(content()),
                  isBackButtonEnabled: isBackButtonEnabled,
                  backButtonTapped: backButtonTapped)
    }

    public init<A: View>(title: String = "",
                         headerHeight: CGFloat = 300,
                         scrollUpHeaderBehavior: ScrollUpHeaderBehavior = .parallax,
                         scrollDownHeaderBehavior: ScrollDownHeaderBehavior = .offset,
                         content: () -> A,
                         isBackButtonEnabled: Bool,
                         backButtonTapped: @escaping () -> Void) {

           self.init(title: title,
                     headerHeight: headerHeight,
                     scrollUpHeaderBehavior: scrollUpHeaderBehavior,
                     scrollDownHeaderBehavior: scrollDownHeaderBehavior,
                     header: nil,
                     content: AnyView(content()),
                     isBackButtonEnabled: isBackButtonEnabled,
                     backButtonTapped: backButtonTapped)
       }

}

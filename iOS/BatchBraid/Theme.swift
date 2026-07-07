import SwiftUI

/// Batch Braid - Rope Craft Log's own palette: distinct from every sibling app in the portfolio.
enum BBTheme {
    static let backdrop = Color(red: 0.965, green: 0.949, blue: 0.914)
    static let card = Color.white

    static let ink = Color(red: 0.153, green: 0.114, blue: 0.078)
    static let inkFaded = Color(red: 0.153, green: 0.114, blue: 0.078).opacity(0.56)

    static let accent = Color(red: 0.443, green: 0.298, blue: 0.161)
    static let accentDeep = Color(red: 0.363, green: 0.21799999999999997, blue: 0.081)
    static let accent2 = Color(red: 0.784, green: 0.573, blue: 0.271)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BBDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BBDismissKeyboardOnTap())
    }
}

enum BBHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

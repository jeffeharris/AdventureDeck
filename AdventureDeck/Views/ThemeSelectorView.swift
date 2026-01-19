import SwiftUI

struct ThemeSelectorView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    let columns = [
        GridItem(.flexible(), spacing: 30),
        GridItem(.flexible(), spacing: 30)
    ]

    var body: some View {
        VStack(spacing: 40) {
            // Title
            VStack(spacing: 8) {
                Text("Adventure")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text("Mission Control")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.3), radius: 4)

            Text("Choose Your Adventure!")
                .font(.title2.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            // Theme buttons
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(Theme.allCases) { theme in
                    ThemeButton(theme: theme) {
                        viewModel.selectTheme(theme)
                    }
                }
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            AnimatedGradientBackground()
        )
    }
}

struct ThemeButton: View {
    let theme: Theme
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: theme.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(theme.accentColor)
                    .shadow(color: theme.accentColor.opacity(0.5), radius: 8)

                // Label
                Text(theme.rawValue)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.primaryColor.opacity(0.5), radius: isPressed ? 5 : 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(theme.accentColor.opacity(0.5), lineWidth: 3)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.rawValue) adventure")
        .accessibilityHint("Double tap to start a \(theme.rawValue.lowercased()) themed adventure")
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "1a1a2e"),
                Color(hex: "16213e"),
                Color(hex: "0f3460"),
                Color(hex: "1a1a2e")
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    ThemeSelectorView()
        .environment(AdventureViewModel())
}

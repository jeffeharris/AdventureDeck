import SwiftUI

struct MainView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                viewModel.currentThemeColors.background
                    .ignoresSafeArea()

                if viewModel.state == .selectingTheme {
                    ThemeSelectorView()
                        .transition(.opacity)
                } else {
                    AdventureView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.state == .selectingTheme)
        }
    }
}

struct AdventureView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button and theme indicator
            TopBarView()

            // Main content area
            HStack(spacing: 0) {
                // Map takes most of the space
                MapView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Sound board on the right
                SoundBoardView()
                    .frame(width: 160)
            }

            // Bottom control bar
            ControlBarView()
        }
    }
}

struct TopBarView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    var body: some View {
        HStack {
            // Back button
            Button {
                viewModel.returnToThemeSelection()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Themes")
                }
                .themedCapsuleStyle(
                    accent: viewModel.currentThemeColors.accent,
                    secondary: viewModel.currentThemeColors.secondary
                )
            }
            .accessibilityLabel("Go back to theme selection")
            .accessibilityHint("Double tap to choose a different adventure theme")

            Spacer()

            // Current theme indicator
            if let theme = viewModel.selectedTheme {
                HStack(spacing: 8) {
                    Image(systemName: theme.icon)
                    Text(theme.rawValue)
                }
                .font(.title2.weight(.bold))
                .foregroundStyle(viewModel.currentThemeColors.accent)
                .accessibilityLabel("Current theme: \(theme.rawValue)")
            }

            Spacer()

            // New map button
            Button {
                viewModel.generateNewMap()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text("New Map")
                }
                .themedCapsuleStyle(
                    accent: viewModel.currentThemeColors.accent,
                    secondary: viewModel.currentThemeColors.secondary
                )
            }
            .accessibilityLabel("Generate new map")
            .accessibilityHint("Double tap to create a new adventure map")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(viewModel.currentThemeColors.primary.opacity(0.8))
    }
}

struct ControlBarView: View {
    @Environment(AdventureViewModel.self) private var viewModel
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 30) {
            // Speed toggle
            Button {
                viewModel.toggleSpeed()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: viewModel.isFastSpeed ? "hare.fill" : "tortoise.fill")
                        .font(.system(size: 32))
                    Text(viewModel.isFastSpeed ? "Fast" : "Slow")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(viewModel.currentThemeColors.accent)
                .frame(width: 80, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.currentThemeColors.secondary.opacity(0.4))
                )
            }
            .accessibilityLabel("Speed: \(viewModel.isFastSpeed ? "Fast" : "Slow")")
            .accessibilityHint("Double tap to change adventure speed")

            Spacer()

            // Main play/pause button - EXTRA LARGE for kids
            Button {
                viewModel.toggleAdventure()
            } label: {
                ZStack {
                    Circle()
                        .fill(viewModel.currentThemeColors.accent)
                        .frame(width: 100, height: 100)
                        .shadow(color: viewModel.currentThemeColors.accent.opacity(0.5), radius: 10)

                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(viewModel.currentThemeColors.primary)
                        .offset(x: viewModel.isPlaying ? 0 : 4) // Visual balance for play icon
                }
            }
            .scaleEffect(isPulsing && !viewModel.isPlaying && viewModel.canStart ? 1.05 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .accessibilityLabel(viewModel.isPlaying ? "Pause adventure" : "Start adventure")
            .accessibilityHint("Double tap to \(viewModel.isPlaying ? "pause" : "start") the adventure")
            .accessibilityAddTraits(.startsMediaSession)

            Spacer()

            // Volume control
            VStack(spacing: 4) {
                Button {
                    viewModel.audioManager.isMuted.toggle()
                } label: {
                    Image(systemName: viewModel.audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(viewModel.currentThemeColors.accent)
                }
                .accessibilityLabel(viewModel.audioManager.isMuted ? "Sound is off" : "Sound is on")
                .accessibilityHint("Double tap to \(viewModel.audioManager.isMuted ? "turn sound on" : "mute")")

                Slider(value: Binding(
                    get: { Double(viewModel.audioManager.volume) },
                    set: { viewModel.audioManager.volume = Float($0) }
                ), in: 0...1)
                .tint(viewModel.currentThemeColors.accent)
                .frame(width: 100)
                .accessibilityLabel("Volume")
                .accessibilityValue("\(Int(viewModel.audioManager.volume * 100)) percent")
            }
            .frame(width: 120, height: 70)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.currentThemeColors.secondary.opacity(0.4))
            )
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 16)
        .background(viewModel.currentThemeColors.primary.opacity(0.8))
    }
}

// MARK: - Reusable Themed Styles

extension View {
    func themedCapsuleStyle(accent: Color, secondary: Color) -> some View {
        self
            .font(.title3.weight(.semibold))
            .foregroundStyle(accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(secondary.opacity(0.3))
            )
    }

    func themedRoundedStyle(accent: Color, secondary: Color, width: CGFloat = 80, height: CGFloat = 70) -> some View {
        self
            .foregroundStyle(accent)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(secondary.opacity(0.4))
            )
    }
}

#Preview {
    MainView()
        .environment(AdventureViewModel())
}

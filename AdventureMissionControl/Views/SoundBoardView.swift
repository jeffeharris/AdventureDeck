import SwiftUI

struct SoundBoardView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 12) {
            // Section title
            Text("Sounds")
                .font(.headline.weight(.bold))
                .foregroundStyle(viewModel.currentThemeColors.accent)
                .padding(.top, 8)

            // Sound effect buttons
            if let theme = viewModel.selectedTheme {
                ForEach(Array(theme.actionSounds.enumerated()), id: \.offset) { index, soundName in
                    SoundButton(
                        soundName: soundName,
                        icon: iconForSound(soundName, theme: theme),
                        color: viewModel.currentThemeColors.accent,
                        secondaryColor: viewModel.currentThemeColors.secondary
                    ) {
                        viewModel.playActionSound(index)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(viewModel.currentThemeColors.primary.opacity(0.6))
    }

    private func iconForSound(_ sound: String, theme: Theme) -> String {
        // Map sound names to appropriate SF Symbols
        switch sound.lowercased() {
        // Space
        case "laser": return "bolt.fill"
        case "whoosh": return "wind"
        case "beep": return "waveform"
        case "powerup": return "sparkles"

        // Ocean
        case "splash": return "drop.fill"
        case "bubble": return "bubbles.and.sparkles"
        case "whale": return "fish.fill"
        case "sonar": return "dot.radiowaves.left.and.right"

        // City
        case "horn": return "car.fill"
        case "siren": return "light.beacon.max.fill"
        case "bell": return "bell.fill"
        case "chime": return "music.note"

        // Western
        case "gallop": return "figure.equestrian.sports"
        case "whistle": return "mouth.fill"
        case "bang": return "flame.fill"
        case "wind": return "wind"

        default: return "speaker.wave.2.fill"
        }
    }
}

struct SoundButton: View {
    let soundName: String
    let icon: String
    let color: Color
    let secondaryColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
            // Visual feedback
            withAnimation(.easeOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)

                Text(soundName.capitalized)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(secondaryColor.opacity(isPressed ? 0.8 : 0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(isPressed ? 1.0 : 0.3), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play \(soundName) sound")
        .accessibilityHint("Double tap to play the \(soundName) sound effect")
    }
}

#Preview {
    HStack {
        Spacer()
        SoundBoardView()
            .frame(width: 160)
    }
    .frame(height: 400)
    .background(Color.black)
    .environment(AdventureViewModel())
}

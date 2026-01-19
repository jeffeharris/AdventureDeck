import SwiftUI

// MARK: - Mission Alert View (Floating "Incoming Transmission")

struct MissionAlertView: View {
    let mission: Mission
    let theme: Theme
    let onAccept: () -> Void

    @State private var isVisible = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 12) {
            // Antenna icon with pulse
            ZStack {
                // Pulse rings
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseScale + CGFloat(index) * 0.3)
                        .opacity(2.0 - pulseScale)
                }

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 28))
                    .foregroundStyle(theme.accentColor)
            }

            Text("INCOMING TRANSMISSION")
                .font(.caption.bold())
                .foregroundStyle(theme.accentColor)
                .tracking(1)

            // Mission info
            HStack(spacing: 8) {
                Image(systemName: mission.type.icon)
                    .font(.title3)
                Text(mission.type.description)
                    .font(.headline)
            }
            .foregroundStyle(.white)

            // Accept button (big for kids)
            Button(action: onAccept) {
                Text("ACCEPT MISSION")
                    .font(.headline.bold())
                    .foregroundStyle(theme.primaryColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(theme.accentColor)
                    )
            }
            .accessibilityLabel("Accept mission: \(mission.type.description)")
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.primaryColor.opacity(0.95))
                .shadow(color: theme.accentColor.opacity(0.4), radius: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.accentColor.opacity(0.5), lineWidth: 2)
        )
        .offset(y: floatOffset)
        .scaleEffect(isVisible ? 1 : 0.5)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
            startAnimations()
        }
    }

    private func startAnimations() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.5
        }

        // Gentle float
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            floatOffset = -8
        }
    }
}

// MARK: - Mission Progress View (Active Mission Indicator)

struct MissionProgressView: View {
    let mission: Mission
    let theme: Theme

    @State private var progressAnimated: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            // Mission icon
            Image(systemName: mission.type.icon)
                .font(.title3)
                .foregroundStyle(theme.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(mission.type.description)
                    .font(.caption.bold())
                    .foregroundStyle(.white)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.accentColor)
                            .frame(width: geo.size.width * progressAnimated)
                    }
                }
                .frame(height: 6)
            }

            // Progress text
            Text(mission.progressText)
                .font(.caption.bold())
                .foregroundStyle(theme.accentColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor.opacity(0.9))
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                progressAnimated = mission.progressPercent
            }
        }
        .onChange(of: mission.progress) { _, _ in
            withAnimation(.easeOut(duration: 0.3)) {
                progressAnimated = mission.progressPercent
            }
        }
    }
}

// MARK: - Mission Celebration View

struct MissionCelebrationView: View {
    let mission: Mission
    let theme: Theme
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var starScale: CGFloat = 0
    @State private var confettiOffset: [CGFloat] = Array(repeating: -200, count: 12)

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti particles
            ForEach(0..<12, id: \.self) { index in
                Image(systemName: ["star.fill", "sparkle", "circle.fill"].randomElement()!)
                    .font(.system(size: CGFloat.random(in: 12...24)))
                    .foregroundStyle([theme.accentColor, .yellow, .white, .orange].randomElement()!)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: confettiOffset[index]
                    )
                    .opacity(confettiOffset[index] < 200 ? 1 : 0)
            }

            // Celebration card
            VStack(spacing: 20) {
                // Big star
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow, radius: 20)
                    .scaleEffect(starScale)

                Text("MISSION COMPLETE!")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text(mission.type.description)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))

                Text("Great job, explorer!")
                    .font(.title3)
                    .foregroundStyle(theme.accentColor)

                // Tap to continue
                Text("Tap to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                isVisible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
                starScale = 1
            }
            startConfetti()
        }
    }

    private func startConfetti() {
        for index in 0..<12 {
            let delay = Double.random(in: 0...0.5)
            withAnimation(.easeOut(duration: 2).delay(delay)) {
                confettiOffset[index] = CGFloat.random(in: 200...400)
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            MissionAlertView(
                mission: Mission(type: .scanItems(count: 2)),
                theme: .space,
                onAccept: {}
            )

            MissionProgressView(
                mission: Mission(type: .scanItems(count: 3)),
                theme: .space
            )
        }
    }
}

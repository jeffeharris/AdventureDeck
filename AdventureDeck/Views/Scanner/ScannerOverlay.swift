import SwiftUI

struct ScannerOverlay: View {
    let position: CGPoint
    let theme: Theme
    let onComplete: () -> Void

    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Scanning rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(theme.accentColor.opacity(0.6 - Double(index) * 0.15), lineWidth: 3)
                    .frame(width: 60 + CGFloat(index) * 30, height: 60 + CGFloat(index) * 30)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
            }

            // Rotating scanner line
            RoundedRectangle(cornerRadius: 2)
                .fill(theme.accentColor)
                .frame(width: 80, height: 4)
                .rotationEffect(.degrees(rotation))

            // Center dot
            Circle()
                .fill(theme.accentColor)
                .frame(width: 12, height: 12)
                .shadow(color: theme.accentColor, radius: 8)

            // "SCANNING" text
            Text("SCANNING...")
                .font(.caption.bold())
                .foregroundStyle(theme.accentColor)
                .offset(y: 60)
        }
        .position(position)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Expand rings
        withAnimation(.easeOut(duration: 1.5)) {
            ringScale = 1.5
            ringOpacity = 0
        }

        // Rotate scanner line
        withAnimation(.linear(duration: 1.5).repeatCount(3, autoreverses: false)) {
            rotation = 360
        }

        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}

// MARK: - Discovery Card View

struct DiscoveryCardView: View {
    let discovery: Discovery
    let theme: Theme
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var showDetails = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Card
            VStack(spacing: 16) {
                // Header with rarity stars
                HStack {
                    ForEach(0..<discovery.rarity.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundStyle(discovery.rarity.color)
                    }
                    ForEach(0..<(4 - discovery.rarity.stars), id: \.self) { _ in
                        Image(systemName: "star")
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .font(.title2)

                // Icon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.accentColor.opacity(0.4), theme.accentColor.opacity(0)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: discovery.icon)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(theme.accentColor)
                        .shadow(color: theme.accentColor, radius: 10)
                }

                // Name
                Text(discovery.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)

                // Species
                Text(discovery.species)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .italic()

                // Energy bar
                VStack(spacing: 4) {
                    Text("Energy Level")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    HStack {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.2))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(energyColor)
                                    .frame(width: geo.size.width * CGFloat(discovery.energyLevel) / 100)
                            }
                        }
                        .frame(height: 12)

                        Text("\(discovery.energyLevel)%")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 40)
                    }
                }
                .padding(.horizontal)

                // Description
                Text(discovery.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Fun fact
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(discovery.funFact)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                )

                // Dismiss hint
                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.accentColor.opacity(0.3), radius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(theme.accentColor.opacity(0.5), lineWidth: 2)
            )
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }

    private var energyColor: Color {
        switch discovery.energyLevel {
        case 0..<30: return .red
        case 30..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
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

        DiscoveryCardView(
            discovery: Discovery(
                id: UUID(),
                name: "Glimmer Star",
                species: "Crystallus Cosmicus",
                description: "Sparkles with ancient starlight from distant galaxies.",
                funFact: "Astronauts use these for good luck!",
                icon: "star.fill",
                rarity: .rare,
                theme: "Space",
                scannableType: .node,
                energyLevel: 87,
                discoveredAt: Date()
            ),
            theme: .space,
            onDismiss: {}
        )
    }
}

import SwiftUI
import AVFoundation

// MARK: - AR Scanner View (Simple Camera Mode for Kids)

struct ARScannerView: View {
    let theme: Theme
    let onDismiss: () -> Void

    @State private var scanState: ARScanState = .ready
    @State private var analysisResult: ARAnalysisResult?
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView()
                .ignoresSafeArea()

            // Scan overlay
            VStack {
                // Top bar with back button
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.5))
                        )
                    }
                    .accessibilityLabel("Go back to map")

                    Spacer()

                    // Theme indicator
                    HStack(spacing: 6) {
                        Image(systemName: theme.icon)
                        Text(theme.rawValue)
                    }
                    .font(.headline)
                    .foregroundStyle(theme.accentColor)
                    .padding(12)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.5))
                    )
                }
                .padding()

                Spacer()

                // Center viewfinder
                ZStack {
                    // Animated targeting rings
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.accentColor.opacity(0.5 - Double(index) * 0.15), lineWidth: 3)
                            .frame(width: 200 + CGFloat(index) * 40, height: 200 + CGFloat(index) * 40)
                            .scaleEffect(pulseScale + CGFloat(index) * 0.05)
                    }

                    // Corner brackets
                    ViewfinderBrackets(color: theme.accentColor)
                        .frame(width: 200, height: 200)

                    // Scanning animation
                    if scanState == .scanning {
                        ScanningLine(color: theme.accentColor)
                            .frame(width: 180)
                    }

                    // Status text
                    VStack {
                        Spacer()
                        Text(scanState.statusText)
                            .font(.caption.bold())
                            .foregroundStyle(theme.accentColor)
                            .padding(.bottom, -30)
                    }
                    .frame(height: 200)
                }

                Spacer()

                // Big analyze button (easy for kids to tap)
                Button(action: performScan) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                        Text("ANALYZE")
                            .font(.title2.bold())
                    }
                    .foregroundStyle(theme.primaryColor)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        Capsule()
                            .fill(theme.accentColor)
                            .shadow(color: theme.accentColor.opacity(0.5), radius: 10)
                    )
                }
                .disabled(scanState != .ready)
                .opacity(scanState == .ready ? 1 : 0.5)
                .accessibilityLabel("Analyze what you see")
                .accessibilityHint("Point at something and tap to analyze it")
                .padding(.bottom, 40)
            }

            // Analysis result overlay
            if let result = analysisResult {
                ARAnalysisResultView(result: result, theme: theme) {
                    withAnimation {
                        analysisResult = nil
                        scanState = .ready
                    }
                }
            }
        }
        .onAppear {
            startPulseAnimation()
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }

    private func performScan() {
        guard scanState == .ready else { return }

        scanState = .scanning

        // Simulate scanning delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let result = ARAnalysisGenerator.generate(for: theme)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                analysisResult = result
                scanState = .complete
            }
        }
    }
}

// MARK: - Scan State

enum ARScanState {
    case ready
    case scanning
    case complete

    var statusText: String {
        switch self {
        case .ready: return "POINT & TAP ANALYZE"
        case .scanning: return "SCANNING..."
        case .complete: return "ANALYSIS COMPLETE"
        }
    }
}

// MARK: - Viewfinder Brackets

struct ViewfinderBrackets: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let bracketLength = size * 0.25
            let lineWidth: CGFloat = 4

            ZStack {
                // Top-left
                Path { path in
                    path.move(to: CGPoint(x: 0, y: bracketLength))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: bracketLength, y: 0))
                }
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                // Top-right
                Path { path in
                    path.move(to: CGPoint(x: size - bracketLength, y: 0))
                    path.addLine(to: CGPoint(x: size, y: 0))
                    path.addLine(to: CGPoint(x: size, y: bracketLength))
                }
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                // Bottom-left
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size - bracketLength))
                    path.addLine(to: CGPoint(x: 0, y: size))
                    path.addLine(to: CGPoint(x: bracketLength, y: size))
                }
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                // Bottom-right
                Path { path in
                    path.move(to: CGPoint(x: size - bracketLength, y: size))
                    path.addLine(to: CGPoint(x: size, y: size))
                    path.addLine(to: CGPoint(x: size, y: size - bracketLength))
                }
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            }
        }
    }
}

// MARK: - Scanning Line Animation

struct ScanningLine: View {
    let color: Color

    @State private var offset: CGFloat = -100

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [color.opacity(0), color, color.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 4)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                    offset = 100
                }
            }
    }
}

// MARK: - Camera Preview (Simple AVFoundation wrapper)

struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraPreviewUIView {
        CameraPreviewUIView()
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

class CameraPreviewUIView: UIView {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCamera()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    private func setupCamera() {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.startCamera()
                    }
                }
            }
        default:
            // Show placeholder if no permission
            showPlaceholder()
        }
    }

    private func startCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            showPlaceholder()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
        layer.addSublayer(previewLayer)

        self.captureSession = session
        self.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func showPlaceholder() {
        backgroundColor = .darkGray
    }

    deinit {
        let session = captureSession
        DispatchQueue.global(qos: .userInitiated).async {
            session?.stopRunning()
        }
    }
}

// MARK: - AR Analysis Result

struct ARAnalysisResult: Identifiable {
    let id = UUID()
    let objectName: String
    let classification: String
    let funDescription: String
    let energyLevel: Int
    let icon: String
    let specialAbility: String
}

// MARK: - AR Analysis Result View

struct ARAnalysisResultView: View {
    let result: ARAnalysisResult
    let theme: Theme
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var iconScale: CGFloat = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Result card
            VStack(spacing: 16) {
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.accentColor.opacity(0.4), theme.accentColor.opacity(0)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)

                    Image(systemName: result.icon)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(theme.accentColor)
                        .shadow(color: theme.accentColor, radius: 10)
                        .scaleEffect(iconScale)
                }

                // Object name
                Text(result.objectName)
                    .font(.title.bold())
                    .foregroundStyle(.white)

                // Classification
                Text(result.classification)
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
                                    .frame(width: geo.size.width * CGFloat(result.energyLevel) / 100)
                            }
                        }
                        .frame(height: 12)

                        Text("\(result.energyLevel)%")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 40)
                    }
                }
                .padding(.horizontal)

                // Description
                Text(result.funDescription)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Special ability
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                    Text("Special: \(result.specialAbility)")
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
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
                iconScale = 1
            }
        }
    }

    private var energyColor: Color {
        switch result.energyLevel {
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

// MARK: - AR Analysis Generator

struct ARAnalysisGenerator {
    static func generate(for theme: Theme) -> ARAnalysisResult {
        let (names, classifications) = content(for: theme)
        let descriptions = funDescriptions(for: theme)
        let abilities = specialAbilities(for: theme)
        let icons = analysisIcons(for: theme)

        return ARAnalysisResult(
            objectName: names.randomElement() ?? "Unknown Object",
            classification: classifications.randomElement() ?? "Unidentified",
            funDescription: descriptions.randomElement() ?? "Very mysterious!",
            energyLevel: Int.random(in: 20...100),
            icon: icons.randomElement() ?? "questionmark.circle",
            specialAbility: abilities.randomElement() ?? "Being awesome"
        )
    }

    private static func content(for theme: Theme) -> (names: [String], classifications: [String]) {
        switch theme {
        case .space:
            return (
                names: [
                    "Alien Fruit", "Space Potato", "Cosmic Cookie", "Meteor Muffin",
                    "Star Snack", "Galaxy Grape", "Nebula Nut", "Rocket Raisin",
                    "Planet Pretzel", "Asteroid Apple", "Comet Candy", "Lunar Lemon"
                ],
                classifications: [
                    "Extraterrestrial Organic", "Cosmic Food Source", "Alien Specimen",
                    "Space Nutrition Unit", "Intergalactic Snack", "Stellar Sustenance"
                ]
            )
        case .ocean:
            return (
                names: [
                    "Sea Sponge Surprise", "Coral Cracker", "Kelp Cake", "Whale Waffle",
                    "Dolphin Donut", "Shark Sandwich", "Jellyfish Jelly", "Octopus Oreo",
                    "Turtle Toast", "Crab Crunch", "Seahorse Snack", "Mermaid Munchie"
                ],
                classifications: [
                    "Deep Sea Delicacy", "Marine Morsel", "Ocean Organism",
                    "Underwater Treat", "Aquatic Artifact", "Tidal Treasure"
                ]
            )
        case .city:
            return (
                names: [
                    "Skyscraper Snack", "Taxi Treat", "Subway Surprise", "Park Pretzel",
                    "Traffic Tart", "Sidewalk Sweet", "Neon Noodle", "Metro Muffin",
                    "Rooftop Roll", "Street Star", "Urban Unicorn", "City Critter"
                ],
                classifications: [
                    "Urban Discovery", "Metropolitan Marvel", "City Specimen",
                    "Downtown Delight", "Street-Level Find", "Building Block"
                ]
            )
        case .western:
            return (
                names: [
                    "Cowboy Cookie", "Cactus Candy", "Desert Donut", "Tumbleweed Treat",
                    "Sheriff's Snack", "Canyon Cake", "Sunset Surprise", "Rodeo Roll",
                    "Prairie Pretzel", "Outlaw Orange", "Frontier Fruit", "Ranch Raisin"
                ],
                classifications: [
                    "Wild West Wonder", "Desert Discovery", "Frontier Find",
                    "Prairie Specimen", "Canyon Curiosity", "Dusty Delicacy"
                ]
            )
        }
    }

    private static func funDescriptions(for theme: Theme) -> [String] {
        switch theme {
        case .space:
            return [
                "Astronauts love to share these during spacewalks!",
                "Contains stardust from 3 different galaxies!",
                "Aliens use these to power their spaceships!",
                "Tastes like moonbeams and rocket fuel!",
                "Found on the dark side of the moon!",
                "Makes a tiny 'boop' sound in zero gravity!"
            ]
        case .ocean:
            return [
                "Dolphins do backflips when they find one!",
                "Mermaids use these as party decorations!",
                "Glows brighter than a anglerfish!",
                "Can hold its breath for 1000 years!",
                "Whales sing songs about this treasure!",
                "Makes bubbles when it's happy!"
            ]
        case .city:
            return [
                "Pigeons consider this extremely valuable!",
                "Taxi drivers honk when they see one!",
                "Street performers dance around these!",
                "Appears after thunderstorms in the city!",
                "Loved by all the city's friendly cats!",
                "Makes elevator music wherever it goes!"
            ]
        case .western:
            return [
                "Cowboys put these in their lucky hats!",
                "Horses neigh with joy when nearby!",
                "Tumbleweeds follow it across the desert!",
                "Coyotes howl at the moon about these!",
                "Makes a tiny 'yeehaw' when discovered!",
                "Glows like a campfire under the stars!"
            ]
        }
    }

    private static func specialAbilities(for theme: Theme) -> [String] {
        switch theme {
        case .space:
            return [
                "Floats in zero gravity", "Glows in the dark", "Speaks alien language",
                "Attracts shooting stars", "Powers rocket engines", "Time travel (maybe)"
            ]
        case .ocean:
            return [
                "Breathes underwater", "Talks to fish", "Creates rainbows",
                "Summons dolphins", "Makes perfect bubbles", "Finds sunken treasure"
            ]
        case .city:
            return [
                "Hails taxis instantly", "Makes traffic lights green", "Finds best pizza",
                "Street music talent", "Rooftop access", "Pigeon communication"
            ]
        case .western:
            return [
                "Lasso skills", "Horse whispering", "Gold detection",
                "Perfect campfire making", "Tumbleweed riding", "Sunset summoning"
            ]
        }
    }

    private static func analysisIcons(for theme: Theme) -> [String] {
        switch theme {
        case .space:
            return ["star.fill", "moon.fill", "sparkles", "globe.americas.fill", "airplane"]
        case .ocean:
            return ["fish.fill", "drop.fill", "tortoise.fill", "leaf.fill", "wind"]
        case .city:
            return ["building.2.fill", "car.fill", "tram.fill", "cup.and.saucer.fill", "lightbulb.fill"]
        case .western:
            return ["sun.max.fill", "flame.fill", "mountain.2.fill", "hare.fill", "leaf.fill"]
        }
    }
}

#Preview {
    ARScannerView(theme: .space) {}
}

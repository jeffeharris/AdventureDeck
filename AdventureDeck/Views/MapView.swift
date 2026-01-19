import SwiftUI

struct MapView: View {
    @Environment(AdventureViewModel.self) private var viewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                viewModel.currentThemeColors.background
                    .onAppear {
                        viewModel.setMapSize(geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        viewModel.setMapSize(newSize)
                    }

                if let map = viewModel.map, let theme = viewModel.selectedTheme {
                    // Draw terrain zones (background) - tappable for scanning
                    TerrainZonesLayer(zones: map.terrainZones, onTapZone: { zone, position in
                        viewModel.scanItem(at: position, type: .zone, icon: zone.terrainType.icon, zoneName: zone.terrainType.name)
                    })

                    // Draw paths
                    PathsLayer(map: map)

                    // Draw decorations (on top of zones, under paths) - tappable for scanning
                    TerrainDecorationsLayer(zones: map.terrainZones, onTapDecoration: { decoration, position in
                        viewModel.scanItem(at: position, type: .decoration, icon: decoration.icon)
                    })

                    // Draw nodes - tappable for scanning
                    NodesLayer(map: map, onTapNode: { node in
                        viewModel.scanItem(at: node.position, type: .node, icon: node.icon)
                    })

                    // Draw events
                    EventsLayer(events: viewModel.activeEvents)

                    // Draw sprite on top
                    SpriteView(
                        position: viewModel.spritePosition,
                        icon: theme.spriteIcon,
                        color: viewModel.currentThemeColors.accent,
                        isMoving: viewModel.isPlaying
                    )

                    // Scanner overlay
                    if case .scanning(let position) = viewModel.scannerState {
                        ScannerOverlay(position: position, theme: theme) {
                            // Animation complete - handled in ViewModel
                        }
                    }

                    // Discovery result card
                    if case .showingResult(let discovery) = viewModel.scannerState {
                        DiscoveryCardView(discovery: discovery, theme: theme) {
                            viewModel.dismissDiscovery()
                        }
                    }

                    // Mission alert (floating, passive)
                    if case .available(let mission) = viewModel.missionState {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                MissionAlertView(mission: mission, theme: theme) {
                                    viewModel.acceptMission()
                                }
                                .padding(20)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    // Active mission progress
                    if case .active(let mission) = viewModel.missionState {
                        VStack {
                            HStack {
                                MissionProgressView(mission: mission, theme: theme)
                                    .padding(16)
                                Spacer()
                            }
                            Spacer()
                        }
                    }

                    // Mission celebration
                    if case .celebrating(let mission) = viewModel.missionState {
                        MissionCelebrationView(mission: mission, theme: theme) {
                            viewModel.dismissMissionCelebration()
                        }
                    }
                } else {
                    // Loading state
                    ProgressView()
                        .tint(viewModel.currentThemeColors.accent)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(12)
    }
}

// MARK: - Terrain Zones Layer

struct TerrainZonesLayer: View {
    let zones: [TerrainZone]
    var onTapZone: ((TerrainZone, CGPoint) -> Void)?

    var body: some View {
        ZStack {
            // Canvas for zone backgrounds
            Canvas { context, size in
                for zone in zones {
                    // Draw zone background with gradient
                    let rect = zone.bounds

                    // Create a subtle gradient for each zone
                    let gradient = Gradient(colors: [
                        zone.terrainType.primaryColor,
                        zone.terrainType.secondaryColor
                    ])

                    // Draw the zone rectangle with gradient fill
                    let path = Path(roundedRect: rect, cornerRadius: 0)
                    context.fill(path, with: .linearGradient(
                        gradient,
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    ))

                    // Add soft border between zones
                    context.stroke(
                        Path(rect),
                        with: .color(.black.opacity(0.1)),
                        lineWidth: 1
                    )
                }
            }

            // Invisible tap areas for each zone
            ForEach(zones) { zone in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .frame(width: zone.bounds.width, height: zone.bounds.height)
                    .position(
                        x: zone.bounds.midX,
                        y: zone.bounds.midY
                    )
                    .onTapGesture { location in
                        // Convert local tap coordinates to absolute position in the zone
                        let tapPoint = CGPoint(
                            x: zone.bounds.minX + (location.x / zone.bounds.width) * zone.bounds.width,
                            y: zone.bounds.minY + (location.y / zone.bounds.height) * zone.bounds.height
                        )
                        onTapZone?(zone, tapPoint)
                    }
                    .accessibilityLabel("Scan \(zone.terrainType.name) zone")
                    .accessibilityHint("Double tap to scan this area")
            }
        }
    }
}

struct TerrainDecorationsLayer: View {
    let zones: [TerrainZone]
    var onTapDecoration: ((TerrainDecoration, CGPoint) -> Void)?

    var body: some View {
        ForEach(zones) { zone in
            ForEach(zone.decorations) { decoration in
                Image(systemName: decoration.icon)
                    .font(.system(size: decoration.size))
                    .foregroundStyle(zone.terrainType.secondaryColor)
                    .opacity(decoration.opacity)
                    .rotationEffect(.degrees(decoration.rotation))
                    .position(decoration.position)
                    .frame(width: decoration.size + 20, height: decoration.size + 20)
                    .contentShape(Circle())
                    .onTapGesture {
                        onTapDecoration?(decoration, decoration.position)
                    }
                    .accessibilityLabel("Scan decoration")
                    .accessibilityHint("Double tap to scan this object")
            }
        }
    }
}

// MARK: - Paths Layer

struct PathsLayer: View {
    let map: AdventureMap

    var body: some View {
        Canvas { context, size in
            // Draw all connection paths (thin, faded)
            for path in map.paths {
                guard let startNode = map.node(withId: path.startNodeId),
                      let endNode = map.node(withId: path.endNodeId) else { continue }

                var linePath = Path()
                linePath.move(to: startNode.position)
                linePath.addLine(to: endNode.position)

                context.stroke(
                    linePath,
                    with: .color(map.theme.pathColor.opacity(0.3)),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
            }

            // Draw the traversal path (thicker, brighter)
            if map.traversalPath.count > 1 {
                var traversalLine = Path()
                let positions = map.traversalPositions()

                if let first = positions.first {
                    traversalLine.move(to: first)
                    for position in positions.dropFirst() {
                        traversalLine.addLine(to: position)
                    }
                }

                context.stroke(
                    traversalLine,
                    with: .color(map.theme.pathColor),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [12, 6])
                )
            }
        }
    }
}

struct NodesLayer: View {
    let map: AdventureMap
    var onTapNode: ((MapNode) -> Void)?

    var body: some View {
        ForEach(map.nodes) { node in
            NodeView(
                node: node,
                theme: map.theme,
                isOnPath: map.traversalPath.contains(node.id)
            )
            .position(node.position)
            .contentShape(Circle().size(width: 60, height: 60))
            .onTapGesture {
                onTapNode?(node)
            }
            .accessibilityLabel("Scan waypoint")
            .accessibilityHint("Double tap to scan this waypoint")
        }
    }
}

struct NodeView: View {
    let node: MapNode
    let theme: Theme
    let isOnPath: Bool

    var body: some View {
        ZStack {
            // Glow for path nodes
            if isOnPath {
                Circle()
                    .fill(theme.nodeColor.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .blur(radius: 8)
            }

            // Node icon
            Image(systemName: node.icon)
                .font(.system(size: isOnPath ? 28 : 20, weight: .medium))
                .foregroundStyle(node.isVisited ? theme.accentColor : theme.nodeColor)
                .shadow(color: theme.nodeColor.opacity(0.5), radius: 4)
        }
        .scaleEffect(node.isVisited ? 1.2 : 1.0)
        .animation(.easeOut(duration: 0.3), value: node.isVisited)
    }
}

struct EventsLayer: View {
    let events: [AdventureEvent]

    var body: some View {
        ForEach(events) { event in
            EventView(event: event)
                .position(event.position)
        }
    }
}

struct EventView: View {
    let event: AdventureEvent

    @State private var isVisible = false

    var body: some View {
        Image(systemName: event.icon)
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(event.color)
            .opacity(isVisible ? 0.8 : 0)
            .scaleEffect(isVisible ? 1.0 : 0.5)
            .shadow(color: event.color.opacity(0.6), radius: 8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    isVisible = true
                }
            }
    }
}

struct SpriteView: View {
    let position: CGPoint
    let icon: String
    let color: Color
    let isMoving: Bool

    @State private var wobble = false

    var body: some View {
        ZStack {
            // Trail/glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0)],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)

            // Sprite icon
            Image(systemName: icon)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(color)
                .shadow(color: color, radius: 6)
                .rotationEffect(.degrees(wobble && isMoving ? 5 : -5))
        }
        .position(position)
        .animation(.easeInOut(duration: 0.15), value: position)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                wobble = true
            }
        }
    }
}

#Preview {
    MapView()
        .environment(AdventureViewModel())
        .frame(width: 600, height: 400)
}

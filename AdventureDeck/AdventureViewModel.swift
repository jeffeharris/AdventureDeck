import SwiftUI
import Combine

@MainActor
@Observable
class AdventureViewModel {

    // MARK: - State

    enum AdventureState {
        case selectingTheme
        case ready
        case traveling
        case paused
        case arrived
    }

    var state: AdventureState = .selectingTheme
    var selectedTheme: Theme?
    var map: AdventureMap?
    var mapSize: CGSize = .zero

    // Sprite position and movement
    var spritePosition: CGPoint = .zero
    var currentPathIndex: Int = 0
    var travelProgress: CGFloat = 0 // 0-1 progress between current nodes

    // Speed control
    var isFastSpeed: Bool = false
    var baseSpeedPointsPerSecond: CGFloat = 30 // Adjusted for ~5 min journey

    // Events
    var activeEvents: [AdventureEvent] = []

    // Scanner state
    var scannerState: ScannerState = .idle

    // Mission state (passive/ambient - missions drift in and fade away)
    var missionState: MissionState = .none
    var completedMissions: [Mission] = []
    private var missionAppearTime: Date?
    private let missionDisplayDuration: TimeInterval = 30 // Seconds before mission fades away

    // MARK: - Managers

    let audioManager = AudioManager()
    let mapGenerator = MapGenerator()
    let discoveryManager = DiscoveryManager()

    // MARK: - Private

    private var travelTimer: Timer?
    private var eventTimer: Timer?
    private var missionTimer: Timer?
    private var missionFadeTimer: Timer?

    // MARK: - Computed

    var currentSpeed: CGFloat {
        isFastSpeed ? baseSpeedPointsPerSecond * 2 : baseSpeedPointsPerSecond
    }

    var isPlaying: Bool {
        state == .traveling
    }

    var canStart: Bool {
        state == .ready || state == .paused || state == .arrived
    }

    var currentThemeColors: (primary: Color, secondary: Color, accent: Color, background: Color) {
        guard let theme = selectedTheme else {
            return (.blue, .cyan, .yellow, .black)
        }
        return (theme.primaryColor, theme.secondaryColor, theme.accentColor, theme.backgroundColor)
    }

    // MARK: - Theme Selection

    func selectTheme(_ theme: Theme) {
        selectedTheme = theme
        state = .ready
        audioManager.playThemeAudio(for: theme)
        generateNewMap()
    }

    func returnToThemeSelection() {
        stopAdventure()
        audioManager.stopAll()
        selectedTheme = nil
        map = nil
        state = .selectingTheme
    }

    // MARK: - Map Generation

    func generateNewMap() {
        guard let theme = selectedTheme, mapSize != .zero else { return }

        map = mapGenerator.generateMap(for: theme, in: mapSize)
        resetAdventure()
    }

    func setMapSize(_ size: CGSize) {
        guard size != mapSize else { return }
        mapSize = size
        if selectedTheme != nil {
            generateNewMap()
        }
    }

    // MARK: - Adventure Control

    func startAdventure() {
        guard canStart else { return }

        if state == .arrived {
            resetAdventure()
        }

        state = .traveling
        startTravelTimer()
        startEventTimer()
        startMissionSystem()
    }

    func pauseAdventure() {
        guard state == .traveling else { return }
        state = .paused
        stopTimers()
    }

    func toggleAdventure() {
        if state == .traveling {
            pauseAdventure()
        } else {
            startAdventure()
        }
    }

    func stopAdventure() {
        state = .ready
        stopTimers()
        stopMissionSystem()
        resetAdventure()
    }

    private func resetAdventure() {
        currentPathIndex = 0
        travelProgress = 0
        activeEvents.removeAll()

        // Set sprite to first node position
        if let firstNodeId = map?.traversalPath.first,
           let firstNode = map?.node(withId: firstNodeId) {
            spritePosition = firstNode.position
        }

        // Mark all nodes as unvisited
        if var mutableMap = map {
            for i in 0..<mutableMap.nodes.count {
                mutableMap.nodes[i].isVisited = false
            }
            map = mutableMap
        }
    }

    // MARK: - Speed Control

    func toggleSpeed() {
        isFastSpeed.toggle()
    }

    // MARK: - Travel Animation

    private func startTravelTimer() {
        travelTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateTravel()
        }
    }

    private func startEventTimer() {
        // Spawn events every 3-8 seconds
        scheduleNextEvent()
    }

    private func scheduleNextEvent() {
        let delay = Double.random(in: 3...8)
        eventTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.spawnRandomEvent()
            self?.scheduleNextEvent()
        }
    }

    private func stopTimers() {
        travelTimer?.invalidate()
        travelTimer = nil
        eventTimer?.invalidate()
        eventTimer = nil
    }

    private func updateTravel() {
        guard let map = map,
              currentPathIndex < map.traversalPath.count - 1 else {
            arriveAtDestination()
            return
        }

        let currentNodeId = map.traversalPath[currentPathIndex]
        let nextNodeId = map.traversalPath[currentPathIndex + 1]

        guard let currentNode = map.node(withId: currentNodeId),
              let nextNode = map.node(withId: nextNodeId) else { return }

        // Calculate movement (guard against zero distance)
        let distance = currentNode.position.distance(to: nextNode.position)
        guard distance > 1.0 else {
            // Nodes are too close, skip to next immediately
            travelProgress = 1.0
            return
        }
        let progressIncrement = (currentSpeed / 60.0) / distance

        travelProgress += progressIncrement

        if travelProgress >= 1.0 {
            // Arrived at next node
            travelProgress = 0
            currentPathIndex += 1
            spritePosition = nextNode.position

            // Mark node as visited
            self.map?.markNodeVisited(nextNodeId)

            // Update mission progress for travel/node missions
            updateMissionProgress(for: .travel)
            updateMissionProgress(for: .reachNode(currentPathIndex))

            // Check if we entered a new zone
            if let zone = map.terrainZones.first(where: { $0.bounds.contains(nextNode.position) }) {
                updateMissionProgress(for: .visitZone(zone.terrainType.name))
            }

            // Play a subtle sound
            if let theme = selectedTheme {
                audioManager.playEffect(named: theme.actionSounds.randomElement() ?? "beep")
            }
        } else {
            // Interpolate position
            spritePosition = CGPoint(
                x: currentNode.position.x + (nextNode.position.x - currentNode.position.x) * travelProgress,
                y: currentNode.position.y + (nextNode.position.y - currentNode.position.y) * travelProgress
            )
        }
    }

    private func arriveAtDestination() {
        state = .arrived
        stopTimers()
    }

    // MARK: - Events

    private func spawnRandomEvent() {
        guard state == .traveling, let theme = selectedTheme else { return }

        // Random position near the sprite but not on top
        let offsetX = CGFloat.random(in: -100...100)
        let offsetY = CGFloat.random(in: -80...80)
        let position = CGPoint(
            x: max(50, min(mapSize.width - 50, spritePosition.x + offsetX)),
            y: max(50, min(mapSize.height - 50, spritePosition.y + offsetY))
        )

        let icon = theme.eventIcons.randomElement() ?? "sparkle"
        let event = AdventureEvent(icon: icon, position: position, color: theme.accentColor)

        withAnimation(.easeOut(duration: 0.5)) {
            activeEvents.append(event)
        }

        // Fade out and remove after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            withAnimation(.easeIn(duration: 1.0)) {
                self?.activeEvents.removeAll { $0.id == event.id }
            }
        }
    }

    func clearOldEvents() {
        let maxAge: TimeInterval = 6
        activeEvents.removeAll { $0.age > maxAge }
    }

    // MARK: - Sound Board

    func playActionSound(_ index: Int) {
        guard let theme = selectedTheme,
              index < theme.actionSounds.count else { return }
        audioManager.playEffect(named: theme.actionSounds[index])
    }

    // MARK: - Scanner

    func scanItem(at position: CGPoint, type: ScannableType, icon: String, zoneName: String? = nil) {
        guard let theme = selectedTheme else { return }
        guard scannerState == .idle else { return }

        scannerState = .scanning(position: position)

        // After scanning animation completes, generate discovery
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            let discovery = self.discoveryManager.generateDiscovery(
                for: theme,
                scannableType: type,
                icon: icon,
                zoneName: zoneName
            )

            self.discoveryManager.addDiscovery(discovery)
            self.scannerState = .showingResult(discovery: discovery)

            // Update mission progress if scanning mission active
            self.updateMissionProgress(for: .scan)
        }
    }

    func dismissDiscovery() {
        scannerState = .idle
    }

    // MARK: - Missions (Passive/Ambient)

    func startMissionSystem() {
        // Schedule first mission after a delay
        scheduleMissionAppearance(delay: Double.random(in: 15...30))
    }

    func stopMissionSystem() {
        missionTimer?.invalidate()
        missionTimer = nil
        missionFadeTimer?.invalidate()
        missionFadeTimer = nil
        missionState = .none
    }

    private func scheduleMissionAppearance(delay: TimeInterval) {
        missionTimer?.invalidate()
        missionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.showNewMission()
        }
    }

    private func showNewMission() {
        guard let theme = selectedTheme, let map = map else { return }

        // Only show new mission if none is currently showing
        guard case .none = missionState else {
            scheduleMissionAppearance(delay: Double.random(in: 20...40))
            return
        }

        let mission = MissionGenerator.generate(for: theme, map: map, currentNodeIndex: currentPathIndex)
        missionState = .available(mission: mission)
        missionAppearTime = Date()

        // Schedule auto-fade if not accepted
        missionFadeTimer?.invalidate()
        missionFadeTimer = Timer.scheduledTimer(withTimeInterval: missionDisplayDuration, repeats: false) { [weak self] _ in
            self?.fadeMissionAway()
        }
    }

    private func fadeMissionAway() {
        guard case .available = missionState else { return }

        // Mission was not accepted, fade it away silently
        missionState = .none

        // Schedule next mission
        scheduleMissionAppearance(delay: Double.random(in: 30...60))
    }

    func acceptMission() {
        guard case .available(var mission) = missionState else { return }

        missionFadeTimer?.invalidate()
        missionFadeTimer = nil

        mission.isAccepted = true
        missionState = .active(mission: mission)
    }

    func updateMissionProgress(for action: MissionAction) {
        guard case .active(var mission) = missionState else { return }

        switch (mission.type, action) {
        case (.scanItems, .scan):
            mission.progress += 1
        case (.travelDistance, .travel):
            mission.progress += 1
        case (.visitZone(let targetZone), .visitZone(let visitedZone)) where targetZone == visitedZone:
            mission.progress = mission.target
        case (.reachNode(let targetIndex), .reachNode(let reachedIndex)) where targetIndex <= reachedIndex:
            mission.progress = mission.target
        default:
            return
        }

        if mission.isComplete {
            missionState = .celebrating(mission: mission)
            completedMissions.append(mission)
        } else {
            missionState = .active(mission: mission)
        }
    }

    func dismissMissionCelebration() {
        missionState = .none
        // Schedule next mission
        scheduleMissionAppearance(delay: Double.random(in: 20...40))
    }

    enum MissionAction {
        case scan
        case travel
        case visitZone(String)
        case reachNode(Int)
    }
}

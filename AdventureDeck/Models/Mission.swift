import SwiftUI

// MARK: - Mission Types

enum MissionType: Equatable {
    case visitZone(zoneName: String)
    case scanItems(count: Int)
    case reachNode(nodeIndex: Int)
    case travelDistance(nodes: Int)

    var description: String {
        switch self {
        case .visitZone(let name):
            return "Explore the \(name)"
        case .scanItems(let count):
            return "Scan \(count) \(count == 1 ? "discovery" : "discoveries")"
        case .reachNode(let index):
            return "Reach waypoint \(index + 1)"
        case .travelDistance(let nodes):
            return "Travel through \(nodes) waypoints"
        }
    }

    var icon: String {
        switch self {
        case .visitZone: return "map.fill"
        case .scanItems: return "viewfinder"
        case .reachNode: return "star.fill"
        case .travelDistance: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        }
    }
}

// MARK: - Mission

struct Mission: Identifiable, Equatable {
    let id: UUID
    let type: MissionType
    let createdAt: Date
    var isAccepted: Bool = false
    var progress: Int = 0
    var target: Int

    var isComplete: Bool {
        progress >= target
    }

    var progressText: String {
        "\(progress)/\(target)"
    }

    var progressPercent: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(target))
    }

    init(type: MissionType) {
        self.id = UUID()
        self.type = type
        self.createdAt = Date()

        switch type {
        case .visitZone:
            self.target = 1
        case .scanItems(let count):
            self.target = count
        case .reachNode:
            self.target = 1
        case .travelDistance(let nodes):
            self.target = nodes
        }
    }

    static func == (lhs: Mission, rhs: Mission) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mission State

enum MissionState: Equatable {
    case none
    case available(mission: Mission)      // Floating, not yet accepted
    case active(mission: Mission)          // Accepted, tracking progress
    case celebrating(mission: Mission)     // Just completed, showing celebration

    var currentMission: Mission? {
        switch self {
        case .none:
            return nil
        case .available(let mission), .active(let mission), .celebrating(let mission):
            return mission
        }
    }

    static func == (lhs: MissionState, rhs: MissionState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.available(let m1), .available(let m2)),
             (.active(let m1), .active(let m2)),
             (.celebrating(let m1), .celebrating(let m2)):
            return m1.id == m2.id
        default:
            return false
        }
    }
}

// MARK: - Mission Generator

struct MissionGenerator {
    static func generate(for theme: Theme, map: AdventureMap, currentNodeIndex: Int) -> Mission {
        let types: [() -> MissionType] = [
            {
                // Visit a random zone
                let zoneName = map.terrainZones.randomElement()?.terrainType.name ?? "unknown area"
                return .visitZone(zoneName: zoneName)
            },
            {
                // Scan 1-3 items
                let count = Int.random(in: 1...3)
                return .scanItems(count: count)
            },
            {
                // Reach a future node (if possible)
                let remainingNodes = map.traversalPath.count - currentNodeIndex - 1
                if remainingNodes > 2 {
                    let targetOffset = Int.random(in: 2...min(4, remainingNodes))
                    return .reachNode(nodeIndex: currentNodeIndex + targetOffset)
                } else {
                    return .scanItems(count: 1)
                }
            },
            {
                // Travel through N nodes
                let count = Int.random(in: 2...4)
                return .travelDistance(nodes: count)
            }
        ]

        let randomType = types.randomElement()!()
        return Mission(type: randomType)
    }
}

import SwiftUI

// MARK: - Scannable Item Types

enum ScannableType: String, Codable {
    case node
    case zone
    case decoration
}

// MARK: - Discovery (a scanned item)

struct Discovery: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let species: String
    let description: String
    let funFact: String
    let icon: String
    let rarity: Rarity
    let theme: String // Theme raw value for persistence
    let scannableType: ScannableType
    let energyLevel: Int // 1-100
    let discoveredAt: Date

    enum Rarity: String, Codable, CaseIterable {
        case common
        case uncommon
        case rare
        case legendary

        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .legendary: return .purple
            }
        }

        var stars: Int {
            switch self {
            case .common: return 1
            case .uncommon: return 2
            case .rare: return 3
            case .legendary: return 4
            }
        }
    }

    static func == (lhs: Discovery, rhs: Discovery) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Discovery Collection

struct DiscoveryCollection: Codable {
    var discoveries: [Discovery] = []

    var count: Int { discoveries.count }

    var byTheme: [String: [Discovery]] {
        Dictionary(grouping: discoveries, by: { $0.theme })
    }

    var byRarity: [Discovery.Rarity: [Discovery]] {
        Dictionary(grouping: discoveries, by: { $0.rarity })
    }

    mutating func add(_ discovery: Discovery) {
        discoveries.append(discovery)
    }

    func contains(name: String, theme: String) -> Bool {
        discoveries.contains { $0.name == name && $0.theme == theme }
    }
}

// MARK: - Scanner State

enum ScannerState: Equatable {
    case idle
    case scanning(position: CGPoint)
    case showingResult(discovery: Discovery)

    static func == (lhs: ScannerState, rhs: ScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.scanning(let p1), .scanning(let p2)):
            return p1 == p2
        case (.showingResult(let d1), .showingResult(let d2)):
            return d1.id == d2.id
        default:
            return false
        }
    }
}

// MARK: - Scannable Protocol

protocol Scannable {
    var scannableId: UUID { get }
    var scannableType: ScannableType { get }
    var scannableIcon: String { get }
    var scannablePosition: CGPoint { get }
}

extension MapNode: Scannable {
    var scannableId: UUID { id }
    var scannableType: ScannableType { .node }
    var scannableIcon: String { icon }
    var scannablePosition: CGPoint { position }
}

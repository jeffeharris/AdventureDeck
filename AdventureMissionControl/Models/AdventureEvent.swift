import SwiftUI

struct AdventureEvent: Identifiable {
    let id: UUID
    let icon: String
    let position: CGPoint
    let color: Color
    var opacity: Double
    var scale: Double
    let createdAt: Date

    init(icon: String, position: CGPoint, color: Color) {
        self.id = UUID()
        self.icon = icon
        self.position = position
        self.color = color
        self.opacity = 0
        self.scale = 0.5
        self.createdAt = Date()
    }

    var age: TimeInterval {
        Date().timeIntervalSince(createdAt)
    }
}

enum EventType {
    case ambient    // Soft, background decorations
    case discovery  // Found something interesting
    case sparkle    // Brief visual flourish

    var duration: TimeInterval {
        switch self {
        case .ambient: return 8.0
        case .discovery: return 5.0
        case .sparkle: return 2.0
        }
    }

    var maxScale: Double {
        switch self {
        case .ambient: return 1.0
        case .discovery: return 1.3
        case .sparkle: return 0.8
        }
    }
}

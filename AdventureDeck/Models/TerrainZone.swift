import SwiftUI

struct TerrainZone: Identifiable {
    let id = UUID()
    let terrainType: TerrainType
    let bounds: CGRect
    let decorations: [TerrainDecoration]

    /// Returns the center point of this zone
    var center: CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

struct TerrainDecoration: Identifiable {
    let id = UUID()
    let icon: String
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
    let rotation: Double
}

// MARK: - Zone Layout Types

enum ZoneLayoutStyle {
    case voronoi      // Organic, irregular shapes
    case rectangular  // Grid-based rectangles
    case horizontal   // Horizontal stripes
    case radial       // Circular zones from center
}

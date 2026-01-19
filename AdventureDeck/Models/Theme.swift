import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case space = "Space"
    case ocean = "Ocean"
    case city = "City"
    case western = "Western"

    var id: String { rawValue }

    // MARK: - Colors

    var primaryColor: Color {
        switch self {
        case .space: return Color(hex: "1a1a2e")
        case .ocean: return Color(hex: "0077b6")
        case .city: return Color(hex: "2d3436")
        case .western: return Color(hex: "d4a373")
        }
    }

    var secondaryColor: Color {
        switch self {
        case .space: return Color(hex: "16213e")
        case .ocean: return Color(hex: "00b4d8")
        case .city: return Color(hex: "636e72")
        case .western: return Color(hex: "e9c46a")
        }
    }

    var accentColor: Color {
        switch self {
        case .space: return Color(hex: "e94560")
        case .ocean: return Color(hex: "90e0ef")
        case .city: return Color(hex: "fdcb6e")
        case .western: return Color(hex: "e76f51")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .space: return Color(hex: "0f0f23")
        case .ocean: return Color(hex: "023e8a")
        case .city: return Color(hex: "1e272e")
        case .western: return Color(hex: "faedcd")
        }
    }

    var nodeColor: Color {
        switch self {
        case .space: return Color(hex: "a855f7")
        case .ocean: return Color(hex: "48cae4")
        case .city: return Color(hex: "74b9ff")
        case .western: return Color(hex: "bc6c25")
        }
    }

    var pathColor: Color {
        switch self {
        case .space: return Color(hex: "6366f1").opacity(0.6)
        case .ocean: return Color(hex: "0096c7").opacity(0.6)
        case .city: return Color(hex: "a29bfe").opacity(0.6)
        case .western: return Color(hex: "dda15e").opacity(0.6)
        }
    }

    // MARK: - Icons

    var icon: String {
        switch self {
        case .space: return "moon.stars.fill"
        case .ocean: return "water.waves"
        case .city: return "building.2.fill"
        case .western: return "sun.dust.fill"
        }
    }

    var spriteIcon: String {
        switch self {
        case .space: return "airplane"
        case .ocean: return "ferry.fill"
        case .city: return "car.fill"
        case .western: return "figure.equestrian.sports"
        }
    }

    var nodeIcons: [String] {
        switch self {
        case .space: return ["star.fill", "sparkle", "moon.fill", "sun.max.fill", "circle.fill"]
        case .ocean: return ["fish.fill", "tortoise.fill", "leaf.fill", "drop.fill", "circle.fill"]
        case .city: return ["house.fill", "building.fill", "storefront.fill", "tree.fill", "circle.fill"]
        case .western: return ["mountain.2.fill", "leaf.fill", "sun.max.fill", "flame.fill", "circle.fill"]
        }
    }

    // MARK: - Event Icons

    var eventIcons: [String] {
        switch self {
        case .space: return ["sparkles", "star.fill", "moon.stars", "bolt.fill", "wand.and.stars"]
        case .ocean: return ["bubbles.and.sparkles.fill", "fish.fill", "hare.fill", "drop.fill", "wind"]
        case .city: return ["lightbulb.fill", "bird.fill", "heart.fill", "bell.fill", "party.popper.fill"]
        case .western: return ["wind", "flame.fill", "leaf.fill", "hare.fill", "bird.fill"]
        }
    }

    // MARK: - Sound Names (placeholders)

    var ambientSoundName: String {
        switch self {
        case .space: return "space_ambient"
        case .ocean: return "ocean_ambient"
        case .city: return "city_ambient"
        case .western: return "western_ambient"
        }
    }

    var musicSoundName: String {
        switch self {
        case .space: return "space_music"
        case .ocean: return "ocean_music"
        case .city: return "city_music"
        case .western: return "western_music"
        }
    }

    var actionSounds: [String] {
        switch self {
        case .space: return ["laser", "whoosh", "beep", "powerup"]
        case .ocean: return ["splash", "bubble", "whale", "sonar"]
        case .city: return ["horn", "siren", "bell", "chime"]
        case .western: return ["gallop", "whistle", "bang", "wind"]
        }
    }

    // MARK: - Terrain Zones

    var terrainTypes: [TerrainType] {
        switch self {
        case .space:
            return [
                TerrainType(
                    name: "Nebula",
                    primaryColor: Color(hex: "4c1d95"),
                    secondaryColor: Color(hex: "7c3aed"),
                    decorationIcons: ["sparkle", "staroflife.fill"],
                    decorationDensity: 0.4
                ),
                TerrainType(
                    name: "Asteroid Field",
                    primaryColor: Color(hex: "1f2937"),
                    secondaryColor: Color(hex: "374151"),
                    decorationIcons: ["circle.fill", "oval.fill"],
                    decorationDensity: 0.6
                ),
                TerrainType(
                    name: "Star Cluster",
                    primaryColor: Color(hex: "1e1b4b"),
                    secondaryColor: Color(hex: "312e81"),
                    decorationIcons: ["star.fill", "sparkles"],
                    decorationDensity: 0.5
                ),
                TerrainType(
                    name: "Deep Space",
                    primaryColor: Color(hex: "030712"),
                    secondaryColor: Color(hex: "111827"),
                    decorationIcons: ["circle.fill"],
                    decorationDensity: 0.1
                )
            ]
        case .ocean:
            return [
                TerrainType(
                    name: "Coral Reef",
                    primaryColor: Color(hex: "0891b2"),
                    secondaryColor: Color(hex: "06b6d4"),
                    decorationIcons: ["leaf.fill", "circle.hexagongrid.fill"],
                    decorationDensity: 0.5
                ),
                TerrainType(
                    name: "Deep Sea",
                    primaryColor: Color(hex: "0c4a6e"),
                    secondaryColor: Color(hex: "075985"),
                    decorationIcons: ["drop.fill", "water.waves"],
                    decorationDensity: 0.2
                ),
                TerrainType(
                    name: "Kelp Forest",
                    primaryColor: Color(hex: "065f46"),
                    secondaryColor: Color(hex: "047857"),
                    decorationIcons: ["leaf.fill", "arrow.up"],
                    decorationDensity: 0.6
                ),
                TerrainType(
                    name: "Sandy Shallows",
                    primaryColor: Color(hex: "0ea5e9"),
                    secondaryColor: Color(hex: "38bdf8"),
                    decorationIcons: ["circle.fill", "oval.fill"],
                    decorationDensity: 0.3
                )
            ]
        case .city:
            return [
                TerrainType(
                    name: "Downtown",
                    primaryColor: Color(hex: "1f2937"),
                    secondaryColor: Color(hex: "374151"),
                    decorationIcons: ["building.2.fill", "building.fill"],
                    decorationDensity: 0.4
                ),
                TerrainType(
                    name: "Park",
                    primaryColor: Color(hex: "166534"),
                    secondaryColor: Color(hex: "15803d"),
                    decorationIcons: ["tree.fill", "leaf.fill"],
                    decorationDensity: 0.5
                ),
                TerrainType(
                    name: "Industrial",
                    primaryColor: Color(hex: "44403c"),
                    secondaryColor: Color(hex: "57534e"),
                    decorationIcons: ["gearshape.fill", "wrench.fill"],
                    decorationDensity: 0.3
                ),
                TerrainType(
                    name: "Residential",
                    primaryColor: Color(hex: "78716c"),
                    secondaryColor: Color(hex: "a8a29e"),
                    decorationIcons: ["house.fill", "tree.fill"],
                    decorationDensity: 0.4
                )
            ]
        case .western:
            return [
                TerrainType(
                    name: "Desert",
                    primaryColor: Color(hex: "d97706"),
                    secondaryColor: Color(hex: "f59e0b"),
                    decorationIcons: ["sun.max.fill", "circle.fill"],
                    decorationDensity: 0.2
                ),
                TerrainType(
                    name: "Canyon",
                    primaryColor: Color(hex: "9a3412"),
                    secondaryColor: Color(hex: "c2410c"),
                    decorationIcons: ["triangle.fill", "mountain.2.fill"],
                    decorationDensity: 0.3
                ),
                TerrainType(
                    name: "Prairie",
                    primaryColor: Color(hex: "a16207"),
                    secondaryColor: Color(hex: "ca8a04"),
                    decorationIcons: ["leaf.fill", "wind"],
                    decorationDensity: 0.4
                ),
                TerrainType(
                    name: "Mountains",
                    primaryColor: Color(hex: "78350f"),
                    secondaryColor: Color(hex: "92400e"),
                    decorationIcons: ["mountain.2.fill", "triangle.fill"],
                    decorationDensity: 0.3
                )
            ]
        }
    }
}

// MARK: - Terrain Type

struct TerrainType: Identifiable {
    let id = UUID()
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    let decorationIcons: [String]
    let decorationDensity: Double // 0.0 to 1.0, how many decorations to show

    // Primary icon for this terrain type (first decoration icon)
    var icon: String {
        decorationIcons.first ?? "circle.fill"
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

import SwiftUI

@Observable
class DiscoveryManager {
    private static let storageKey = "AdventureDeck.DiscoveryCollection"

    var collection: DiscoveryCollection {
        didSet {
            save()
        }
    }

    init() {
        self.collection = DiscoveryManager.load()
    }

    // MARK: - Persistence

    private static func load() -> DiscoveryCollection {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let collection = try? JSONDecoder().decode(DiscoveryCollection.self, from: data) else {
            return DiscoveryCollection()
        }
        return collection
    }

    private func save() {
        if let data = try? JSONEncoder().encode(collection) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    func addDiscovery(_ discovery: Discovery) {
        collection.add(discovery)
    }

    func clearAll() {
        collection = DiscoveryCollection()
    }

    // MARK: - Discovery Generation

    func generateDiscovery(
        for theme: Theme,
        scannableType: ScannableType,
        icon: String,
        zoneName: String? = nil
    ) -> Discovery {
        let names = scannableNames(for: theme, type: scannableType)
        let species = scannableSpecies(for: theme, type: scannableType)
        let descriptions = scannableDescriptions(for: theme, type: scannableType)
        let funFacts = scannableFunFacts(for: theme, type: scannableType)

        let name = names.randomElement() ?? "Unknown"
        let speciesName = species.randomElement() ?? "Unknown Species"
        let description = descriptions.randomElement() ?? "A mysterious discovery."
        let funFact = funFacts.randomElement() ?? "Scientists are still studying this!"

        let rarity = randomRarity()
        let energyLevel = Int.random(in: 15...100)

        return Discovery(
            id: UUID(),
            name: name,
            species: speciesName,
            description: description,
            funFact: funFact,
            icon: icon,
            rarity: rarity,
            theme: theme.rawValue,
            scannableType: scannableType,
            energyLevel: energyLevel,
            discoveredAt: Date()
        )
    }

    private func randomRarity() -> Discovery.Rarity {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...60: return .common
        case 61...85: return .uncommon
        case 86...97: return .rare
        default: return .legendary
        }
    }

    // MARK: - Theme-Specific Content

    private func scannableNames(for theme: Theme, type: ScannableType) -> [String] {
        switch theme {
        case .space:
            return [
                "Glimmer Star", "Nova Crystal", "Cosmic Pebble", "Star Dust",
                "Moon Rock", "Nebula Wisp", "Asteroid Chunk", "Quantum Sparkle",
                "Stellar Fragment", "Galaxy Gem", "Comet Tail", "Plasma Orb",
                "Void Crystal", "Pulsar Beacon", "Solar Flare Shard"
            ]
        case .ocean:
            return [
                "Bubble Pearl", "Sea Sparkle", "Coral Gem", "Tide Crystal",
                "Ocean Star", "Wave Whisper", "Kelp Jewel", "Sand Dollar",
                "Mermaid Tear", "Nautilus Shell", "Deep Blue", "Foam Flower",
                "Current Stone", "Reef Rainbow", "Abyss Glow"
            ]
        case .city:
            return [
                "Metro Gem", "Street Light", "Urban Crystal", "Neon Spark",
                "Tower Top", "Park Treasure", "City Star", "Bridge Token",
                "Window Glow", "Rooftop Find", "Sidewalk Gem", "Traffic Light",
                "Billboard Bit", "Fountain Coin", "Alley Discovery"
            ]
        case .western:
            return [
                "Desert Gold", "Canyon Crystal", "Prairie Star", "Sunset Gem",
                "Tumbleweed Jewel", "Cactus Crown", "Mesa Stone", "Dust Devil",
                "Frontier Find", "Trail Marker", "Outlaw's Luck", "Sheriff Star",
                "Horseshoe Charm", "Wagon Wheel", "Campfire Ember"
            ]
        }
    }

    private func scannableSpecies(for theme: Theme, type: ScannableType) -> [String] {
        switch theme {
        case .space:
            return [
                "Crystallus Cosmicus", "Stellaris Luminosa", "Nebulae Fragmentum",
                "Astrum Mirabilis", "Voidwalker Particle", "Quantum Floater"
            ]
        case .ocean:
            return [
                "Aquaticus Brilliantus", "Corallus Geminus", "Pelagicus Mysterium",
                "Tidalis Sparklia", "Abyssus Glowfish", "Marinara Crystalli"
            ]
        case .city:
            return [
                "Urbanus Glitterus", "Metropolitus Shineus", "Neonus Brighticus",
                "Civitas Treasurium", "Streetwise Sparklius", "Downtown Gemicus"
            ]
        case .western:
            return [
                "Desertum Goldicus", "Prairius Gemstone", "Canyonus Crystalum",
                "Frontierus Luckius", "Wildwestus Treasurium", "Sunseticus Glow"
            ]
        }
    }

    private func scannableDescriptions(for theme: Theme, type: ScannableType) -> [String] {
        switch theme {
        case .space:
            return [
                "Floats gently through the cosmos.",
                "Sparkles with ancient starlight.",
                "Contains traces of distant galaxies.",
                "Hums with cosmic energy.",
                "Formed in a supernova explosion.",
                "Drifts between dimensions."
            ]
        case .ocean:
            return [
                "Glows softly in deep water.",
                "Carried by gentle currents.",
                "Home to tiny sea creatures.",
                "Reflects beautiful colors.",
                "Smooth from ocean waves.",
                "Whispers secrets of the deep."
            ]
        case .city:
            return [
                "Reflects the city lights.",
                "Found in a hidden corner.",
                "Sparkles after the rain.",
                "Hums with urban energy.",
                "Loved by city explorers.",
                "Glows brightest at night."
            ]
        case .western:
            return [
                "Warmed by the desert sun.",
                "Tumbled smooth by sand.",
                "Glows at sunset.",
                "Treasured by pioneers.",
                "Found on dusty trails.",
                "Sparkles like a campfire."
            ]
        }
    }

    private func scannableFunFacts(for theme: Theme, type: ScannableType) -> [String] {
        switch theme {
        case .space:
            return [
                "Can be seen from 3 galaxies away!",
                "Astronauts use these for good luck.",
                "Makes a tiny 'boop' sound in space.",
                "Aliens think these are very pretty.",
                "Older than most planets!",
                "Tastes like stardust (don't eat it though)."
            ]
        case .ocean:
            return [
                "Fish love to play with these!",
                "Dolphins collect them for fun.",
                "Glows brighter when you're happy.",
                "Mermaids use these as decorations.",
                "Can hold its breath forever!",
                "Makes bubbles when it's excited."
            ]
        case .city:
            return [
                "Pigeons think it's very shiny.",
                "Appears after thunderstorms.",
                "Street cats guard these carefully.",
                "Taxi drivers consider it lucky.",
                "Glows near pizza shops.",
                "Hums along to city music."
            ]
        case .western:
            return [
                "Cowboys put these in their hats!",
                "Horses can smell these from far away.",
                "Coyotes howl when they find one.",
                "Gets shinier in the moonlight.",
                "Tumbleweeds carry these across the desert.",
                "Makes a tiny 'yeehaw' when discovered."
            ]
        }
    }
}

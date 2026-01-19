import SwiftUI

class MapGenerator {

    struct GenerationConfig {
        var gridColumns: Int = 4
        var gridRows: Int = 3
        var nodesPerCell: ClosedRange<Int> = 1...2
        var connectionDistance: CGFloat = 0.35 // Fraction of map width
        var padding: CGFloat = 0.08 // Edge padding as fraction

        // Terrain zone settings
        var zoneColumns: Int = 3
        var zoneRows: Int = 2
        var decorationsPerZone: ClosedRange<Int> = 4...8
    }

    private let config: GenerationConfig

    init(config: GenerationConfig = GenerationConfig()) {
        self.config = config
    }

    // MARK: - Main Generation

    func generateMap(for theme: Theme, in size: CGSize) -> AdventureMap {
        // Step 1: Generate terrain zones (background regions)
        let terrainZones = generateTerrainZones(for: theme, in: size)

        // Step 2: Generate nodes in a grid-distributed pattern
        let nodes = generateNodes(for: theme, in: size)

        // Step 3: Connect nearby nodes
        let paths = generatePaths(for: nodes, in: size)

        // Step 4: Find a traversal path (adventure route)
        let traversalPath = findTraversalPath(nodes: nodes, paths: paths, in: size)

        return AdventureMap(
            theme: theme,
            nodes: nodes,
            paths: paths,
            traversalPath: traversalPath,
            terrainZones: terrainZones
        )
    }

    // MARK: - Terrain Zone Generation

    private func generateTerrainZones(for theme: Theme, in size: CGSize) -> [TerrainZone] {
        var zones: [TerrainZone] = []
        let terrainTypes = theme.terrainTypes

        guard !terrainTypes.isEmpty else { return [] }

        let zoneWidth = size.width / CGFloat(config.zoneColumns)
        let zoneHeight = size.height / CGFloat(config.zoneRows)

        // Track which terrain types we've used to ensure variety
        var usedTerrainIndices: [Int] = []

        for row in 0..<config.zoneRows {
            for col in 0..<config.zoneColumns {
                // Pick a terrain type (try to avoid repeating adjacent)
                let terrainType = pickTerrainType(
                    from: terrainTypes,
                    avoiding: usedTerrainIndices,
                    row: row,
                    col: col
                )

                // Track the index
                if let index = terrainTypes.firstIndex(where: { $0.id == terrainType.id }) {
                    usedTerrainIndices.append(index)
                    // Keep only recent to allow reuse
                    if usedTerrainIndices.count > 2 {
                        usedTerrainIndices.removeFirst()
                    }
                }

                // Calculate bounds
                let bounds = CGRect(
                    x: CGFloat(col) * zoneWidth,
                    y: CGFloat(row) * zoneHeight,
                    width: zoneWidth,
                    height: zoneHeight
                )

                // Generate decorations for this zone
                let decorations = generateDecorations(
                    for: terrainType,
                    in: bounds
                )

                let zone = TerrainZone(
                    terrainType: terrainType,
                    bounds: bounds,
                    decorations: decorations
                )

                zones.append(zone)
            }
        }

        return zones
    }

    private func pickTerrainType(
        from terrainTypes: [TerrainType],
        avoiding recentIndices: [Int],
        row: Int,
        col: Int
    ) -> TerrainType {
        // Filter out recently used types if possible
        let availableIndices = terrainTypes.indices.filter { !recentIndices.contains($0) }

        if availableIndices.isEmpty {
            // Fall back to any random type
            return terrainTypes.randomElement()!
        }

        // Pick from available
        let index = availableIndices.randomElement()!
        return terrainTypes[index]
    }

    private func generateDecorations(for terrainType: TerrainType, in bounds: CGRect) -> [TerrainDecoration] {
        var decorations: [TerrainDecoration] = []

        // Number of decorations based on density
        let baseCount = Int.random(in: config.decorationsPerZone)
        let count = Int(Double(baseCount) * terrainType.decorationDensity)

        guard count > 0 else { return [] }

        for _ in 0..<count {
            let icon = terrainType.decorationIcons.randomElement() ?? "circle.fill"

            // Random position within bounds with some padding
            let padding: CGFloat = 15
            let x = CGFloat.random(in: (bounds.minX + padding)...(bounds.maxX - padding))
            let y = CGFloat.random(in: (bounds.minY + padding)...(bounds.maxY - padding))

            // Vary size and opacity for depth
            let size = CGFloat.random(in: 12...28)
            let opacity = Double.random(in: 0.15...0.4)
            let rotation = Double.random(in: 0...360)

            let decoration = TerrainDecoration(
                icon: icon,
                position: CGPoint(x: x, y: y),
                size: size,
                opacity: opacity,
                rotation: rotation
            )

            decorations.append(decoration)
        }

        return decorations
    }

    // MARK: - Node Generation

    private func generateNodes(for theme: Theme, in size: CGSize) -> [MapNode] {
        var nodes: [MapNode] = []
        let icons = theme.nodeIcons

        let cellWidth = size.width / CGFloat(config.gridColumns)
        let cellHeight = size.height / CGFloat(config.gridRows)
        let paddingX = size.width * config.padding
        let paddingY = size.height * config.padding

        for row in 0..<config.gridRows {
            for col in 0..<config.gridColumns {
                let nodeCount = Int.random(in: config.nodesPerCell)

                for _ in 0..<nodeCount {
                    let cellX = CGFloat(col) * cellWidth + paddingX
                    let cellY = CGFloat(row) * cellHeight + paddingY

                    // Random position within cell (with some internal padding)
                    let internalPadding: CGFloat = 20
                    let x = cellX + CGFloat.random(in: internalPadding...(cellWidth - internalPadding))
                    let y = cellY + CGFloat.random(in: internalPadding...(cellHeight - internalPadding))

                    // Keep within bounds
                    let clampedX = min(max(x, paddingX), size.width - paddingX)
                    let clampedY = min(max(y, paddingY), size.height - paddingY)

                    let icon = icons.randomElement() ?? "circle.fill"
                    let node = MapNode(position: CGPoint(x: clampedX, y: clampedY), icon: icon)
                    nodes.append(node)
                }
            }
        }

        return nodes
    }

    // MARK: - Path Generation

    private func generatePaths(for nodes: [MapNode], in size: CGSize) -> [MapPath] {
        var paths: [MapPath] = []
        let maxDistance = size.width * config.connectionDistance

        // Connect nodes within distance threshold
        for i in 0..<nodes.count {
            for j in (i + 1)..<nodes.count {
                let distance = nodes[i].position.distance(to: nodes[j].position)
                if distance <= maxDistance {
                    paths.append(MapPath(from: nodes[i].id, to: nodes[j].id))
                }
            }
        }

        // Ensure connectivity - add edges if graph is disconnected
        paths = ensureConnectivity(nodes: nodes, paths: paths)

        return paths
    }

    private func ensureConnectivity(nodes: [MapNode], paths: [MapPath]) -> [MapPath] {
        var mutablePaths = paths
        var visited = Set<UUID>()
        var toVisit = [nodes.first?.id].compactMap { $0 }

        // BFS to find connected component
        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()
            if visited.contains(current) { continue }
            visited.insert(current)

            let connectedPaths = mutablePaths.filter { $0.startNodeId == current || $0.endNodeId == current }
            for path in connectedPaths {
                let neighbor = path.startNodeId == current ? path.endNodeId : path.startNodeId
                if !visited.contains(neighbor) {
                    toVisit.append(neighbor)
                }
            }
        }

        // Connect any unvisited nodes to the nearest visited node
        for node in nodes where !visited.contains(node.id) {
            if let nearest = nodes
                .filter({ visited.contains($0.id) })
                .min(by: { node.position.distance(to: $0.position) < node.position.distance(to: $1.position) }) {
                mutablePaths.append(MapPath(from: node.id, to: nearest.id))
                visited.insert(node.id)
            }
        }

        return mutablePaths
    }

    // MARK: - Traversal Path

    private func findTraversalPath(nodes: [MapNode], paths: [MapPath], in size: CGSize) -> [UUID] {
        guard !nodes.isEmpty else { return [] }

        // Find leftmost and rightmost nodes as start/end candidates
        let sortedByX = nodes.sorted { $0.position.x < $1.position.x }
        let startNode = sortedByX.first!
        let endNode = sortedByX.last!

        // Build adjacency list
        let adjacency = buildAdjacencyList(nodes: nodes, paths: paths)

        // Try to find path to specific target first
        var bestPath = findLongestPath(from: startNode.id, to: endNode.id, adjacency: adjacency)

        // If no path to end found, just do a longest walk
        if bestPath.isEmpty {
            bestPath = findLongestPath(from: startNode.id, to: nil, adjacency: adjacency)
        }

        return bestPath
    }

    private func buildAdjacencyList(nodes: [MapNode], paths: [MapPath]) -> [UUID: Set<UUID>] {
        var adjacency: [UUID: Set<UUID>] = [:]
        for node in nodes {
            adjacency[node.id] = []
        }
        for path in paths {
            adjacency[path.startNodeId]?.insert(path.endNodeId)
            adjacency[path.endNodeId]?.insert(path.startNodeId)
        }
        return adjacency
    }

    /// Unified DFS to find the longest path, optionally to a specific target
    private func findLongestPath(from start: UUID, to target: UUID?, adjacency: [UUID: Set<UUID>]) -> [UUID] {
        var bestPath: [UUID] = []
        var visited = Set<UUID>([start])

        func dfs(current: UUID, path: [UUID]) {
            // If we have a target and reached it, check if this is the best path
            if let target = target, current == target {
                if path.count > bestPath.count {
                    bestPath = path
                }
                return
            }

            // If no target, track the longest path we find
            if target == nil && path.count > bestPath.count {
                bestPath = path
            }

            for neighbor in adjacency[current] ?? [] {
                if !visited.contains(neighbor) {
                    visited.insert(neighbor)
                    dfs(current: neighbor, path: path + [neighbor])
                    visited.remove(neighbor)
                }
            }
        }

        dfs(current: start, path: [start])
        return bestPath
    }
}

// MARK: - CGPoint Extension

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
}

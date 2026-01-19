import SwiftUI

struct MapNode: Identifiable, Equatable {
    let id: UUID
    var position: CGPoint
    var icon: String
    var isVisited: Bool = false

    init(position: CGPoint, icon: String) {
        self.id = UUID()
        self.position = position
        self.icon = icon
    }

    static func == (lhs: MapNode, rhs: MapNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct MapPath: Identifiable {
    let id: UUID
    let startNodeId: UUID
    let endNodeId: UUID

    init(from startId: UUID, to endId: UUID) {
        self.id = UUID()
        self.startNodeId = startId
        self.endNodeId = endId
    }
}

struct AdventureMap {
    var nodes: [MapNode]
    var paths: [MapPath]
    var traversalPath: [UUID] // Ordered list of node IDs for the adventure route
    var terrainZones: [TerrainZone] // Background terrain regions
    let theme: Theme

    init(
        theme: Theme,
        nodes: [MapNode] = [],
        paths: [MapPath] = [],
        traversalPath: [UUID] = [],
        terrainZones: [TerrainZone] = []
    ) {
        self.theme = theme
        self.nodes = nodes
        self.paths = paths
        self.traversalPath = traversalPath
        self.terrainZones = terrainZones
    }

    func node(withId id: UUID) -> MapNode? {
        nodes.first { $0.id == id }
    }

    func nodeIndex(withId id: UUID) -> Int? {
        nodes.firstIndex { $0.id == id }
    }

    mutating func markNodeVisited(_ id: UUID) {
        if let index = nodeIndex(withId: id) {
            nodes[index].isVisited = true
        }
    }

    func pathsConnectedTo(nodeId: UUID) -> [MapPath] {
        paths.filter { $0.startNodeId == nodeId || $0.endNodeId == nodeId }
    }

    // Get positions for the traversal path in order
    func traversalPositions() -> [CGPoint] {
        traversalPath.compactMap { nodeId in
            node(withId: nodeId)?.position
        }
    }
}

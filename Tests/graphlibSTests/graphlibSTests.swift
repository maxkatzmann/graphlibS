import XCTest
@testable import graphlibS

class graphlibSTests: XCTestCase {
    
    func testLargestConnectedComponent() {
        
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SGraph(numberOfNodes: 6, directed: false)
        
        /**
         *  One component contains the vertices 0...3
         */
        G.addEdge(from: 0, to: 1)
        G.addEdge(from: 0, to: 2)
        G.addEdge(from: 1, to: 2)
        G.addEdge(from: 2, to: 3)
        
        /**
         *  The second component contains the vertices 4...5
         */
        G.addEdge(from: 4, to: 5)
        
        /**
         *  Get the largest component.
         */
        let verticesInLargestComponent = G.verticesInLargestConnectedComponent()
        
        /**
         *  Check whether the largest component contains 4 vertices.
         */
        XCTAssert(verticesInLargestComponent.count == 4,
                  "The largest component contained \(verticesInLargestComponent.count) vertices instead of 4!")
        
        /**
         *  Check whether the vertices in the largest component are 0...3
         */
        for i in 0...3 {
            XCTAssert(verticesInLargestComponent.contains(i),
                      "The vertex \(i) was not found in the largest component!")
        }
    }
    
    func testConnectedComponents() {
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SGraph(numberOfNodes: 6, directed: false)
        
        /**
         *  One component contains the vertices 0...3
         */
        G.addEdge(from: 0, to: 1)
        G.addEdge(from: 0, to: 2)
        G.addEdge(from: 1, to: 2)
        G.addEdge(from: 2, to: 3)
        
        /**
         *  The second component contains the vertices 4...5
         */
        G.addEdge(from: 4, to: 5)
        
        /**
         *  Get the connected components of the graph
         */
        let connectedComponents = G.connectedComponents()
        
        /**
         *  Check whether we got two components
         */
        XCTAssert(connectedComponents.count == 2,
                  "The graph had \(connectedComponents.count) components instead of 2!")
        
        /**
         *  Check whether the first component is larger than the second one. (Since they should be sorted by size in decreasing order.)
         */
        XCTAssert(connectedComponents[0].0.numberOfVertices > connectedComponents[1].0.numberOfVertices,
                  "The components of the graph were not ordered decreasingly by size!")
        
        /**
         *  Check whether the components contain the correct vertices.
         */
        
        /**
         *  Check whether the vertices in the first component are correct.
         */
        let (firstComponent, firstVertexMap) = connectedComponents[0]
        
        XCTAssert(firstComponent.numberOfVertices == 4,
                  "The number of vertices in the first component was \(firstComponent.numberOfVertices) instead of 4.")
        
        let verticesInFirstComponent = Set<Int>(0..<firstComponent.numberOfVertices)
        for i in 0...3 {
            if let counterpart = firstVertexMap[i] {
                XCTAssert(verticesInFirstComponent.contains(counterpart),
                          "The counterpart of vertex \(i) was not found in the first component!")
            } else {
                XCTAssert(false,
                          "Vertex \(i) did not have a counterpart in the first component!")
            }
        }
        
        /**
         *  Check whether the vertices in the second component are correct.
         */
        let (secondComponent, secondtVertexMap) = connectedComponents[1]
        
        XCTAssert(secondComponent.numberOfVertices == 2,
                  "The number of vertices in the first component was \(secondComponent.numberOfVertices) instead of 2!")
        
        let verticesInSecondComponent = Set<Int>(0..<secondComponent.numberOfVertices)
        for i in 4...5 {
            if let counterpart = secondtVertexMap[i] {
                XCTAssert(verticesInSecondComponent.contains(counterpart),
                          "The counterpart of vertex \(i) was not found in the first component!")
            } else {
                XCTAssert(false,
                          "Vertex \(i) did not have a counterpart in the first component!")
            }
        }
    }
    
    func testSubgraph() {
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SGraph(numberOfNodes: 6, directed: false)
        
        /**
         *  One component contains the vertices 0...3
         */
        G.addEdge(from: 0, to: 1)
        G.addEdge(from: 0, to: 2)
        G.addEdge(from: 1, to: 2)
        G.addEdge(from: 2, to: 3)
        
        /**
         *  The second component contains the vertices 4...5
         */
        G.addEdge(from: 4, to: 5)
        
        /**
         *  We want our subgraph to contain the vertice 0, 1, 2 and 4
         */
        let verticesInSubgraph: Set<Int> = [0, 1, 2, 4]
        
        let (subgraph, vertexMap) = G.subgraph(containing: verticesInSubgraph)
        
        /**
         *  Check whether the subgraph contains 4 verices.
         */
        XCTAssert(subgraph.numberOfVertices == 4,
                  "The subgraph contained \(subgraph.numberOfVertices) vertices instead of 4!")
        
        /**
         *  Check whether the adjacency properties of the subgraph are correct.
         */
        
        // 0 and 1 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[0]!, v: vertexMap[1]!),
                  "The counterparts of 0 and 1 were not adjacent in the subgraph!")
        
        // 1 and 0 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[1]!, v: vertexMap[0]!),
                  "The counterparts of 1 and 0 were not adjacent in the subgraph!")
        
        // 0 and 2 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[0]!, v: vertexMap[2]!),
                  "The counterparts of 0 and 2 were not adjacent in the subgraph!")
        
        // 2 and 0 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[2]!, v: vertexMap[0]!),
                  "The counterparts of 2 and 0 were not adjacent in the subgraph!")
        
        // 1 and 2 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[1]!, v: vertexMap[2]!),
                  "The counterparts of 1 and 2 were not adjacent in the subgraph!")
        
        // 2 and 1 should be adjacent.
        XCTAssert(subgraph.adjacent(u: vertexMap[2]!, v: vertexMap[1]!),
                  "The counterparts of 2 and 1 were not adjacent in the subgraph!")
        
        /**
         *  The counterpart of 4 should not have any neighbors. Therefore, its degree should be 0.
         */
        XCTAssert(subgraph.degree(of: vertexMap[4]!) == 0,
                  "The degree of vertex 4 was \(subgraph.degree(of: vertexMap[4]!)) instead of 0!")
    }

    static var allTests = [
        ("testLargestConnectedComponent", testLargestConnectedComponent),
        ("testConnectedComponents", testConnectedComponents),
        ("testSubgraph", testSubgraph)
    ]
}

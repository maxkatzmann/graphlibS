import XCTest
@testable import graphlibS

class graphlibSTests: XCTestCase {
    
    func testEdges() {
        let G1 = SGraph(numberOfVertices: 6, directed: false)
        /**
         *  One component contains the vertices 0...3
         */
        G1.addEdge(from: 0, to: 1)
        G1.addEdge(from: 0, to: 2)
        G1.addEdge(from: 1, to: 2)
        G1.addEdge(from: 2, to: 3)
        
        let numberOfEdgesInG1 = G1.numberOfEdges
        XCTAssert(numberOfEdgesInG1 == 4, "The number of edges is \(numberOfEdgesInG1), but it should be 4.")
        
        let G2 = SGraph(numberOfVertices: 6, directed: true)
        /**
         *  One component contains the vertices 0...3
         */
        G2.addEdge(from: 0, to: 1)
        G2.addEdge(from: 0, to: 2)
        G2.addEdge(from: 1, to: 2)
        G2.addEdge(from: 2, to: 3)
        
        let numberOfEdgesInG2 = G2.numberOfEdges
        XCTAssert(numberOfEdgesInG2 == 4, "The number of edges is \(numberOfEdgesInG2), but it should be 4.")
    }
    
    func testDiameter() {
        
        // Test unconnected graph.
        
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G1 = SGraph(numberOfVertices: 6, directed: false)
        
        /**
         *  One component contains the vertices 0...3
         */
        G1.addEdge(from: 0, to: 1)
        G1.addEdge(from: 0, to: 2)
        G1.addEdge(from: 1, to: 2)
        G1.addEdge(from: 2, to: 3)
        
        /**
         *  The second component contains the vertices 4...5
         */
        G1.addEdge(from: 4, to: 5)
        
        let diameter1 = G1.diameter()
        XCTAssert(diameter1 == Int.max, "The diameter is \(diameter1), but it should be Int.max.")
        
        // Valid diameter
        
        /**
         *  Create a graph with 4 vertices and 1 components.
         */
        let G2 = SGraph(numberOfVertices: 4, directed: false)
        
        /**
         *  One component contains the vertices 0...3
         */
        G2.addEdge(from: 0, to: 1)
        G2.addEdge(from: 0, to: 2)
        G2.addEdge(from: 1, to: 2)
        G2.addEdge(from: 2, to: 3)
        
        let diameter2 = G2.diameter()
        XCTAssert(diameter2 == 2, "The diameter is \(diameter2), but it should be 2.")
        
        // Directed graph
        let G3 = SGraph(numberOfVertices: 2, directed: true)
        let diameter3 = G3.diameter()
        XCTAssert(diameter3 == -1, "The diameter is \(diameter3), but it should be -1.")
        
        // Empty Graph
        let G4 = SGraph(numberOfVertices: 0, directed: false)
        let diameter4 = G4.diameter()
        XCTAssert(diameter4 == Int.min, "The diameter is \(diameter4), but it should be Int.min.")
    }
    
    func testLargestConnectedComponent() {
        
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SGraph(numberOfVertices: 6, directed: false)
        
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
        let G = SGraph(numberOfVertices: 6, directed: false)
        
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
        let G = SGraph(numberOfVertices: 6, directed: false)
        
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
        let verticesInSubgraph = [0, 1, 2, 4]
        
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
    
    func testAttributedSubgraph() {
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SAttributedGraph(numberOfVertices: 6, directed: false)
        
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
         *  Add attributes
         */
        for vertex in G {
            G.setVertexAttributeValue(forVertex: vertex,
                                      attributeName: SVertexAttribute.label.rawValue, value: "\(vertex)")
        }
        
        G.setVertexAttributeValue(forVertex: 4,
                                  attributeName: SVertexAttribute.weight.rawValue,
                                  value: 5)
        
        G.setEdgeAttributeValue(forEdgeFrom: 0,
                                to: 2,
                                attributeName: SEdgeAttribute.weight.rawValue,
                                value: 7)
        G.setEdgeAttributeValue(forEdgeFrom: 4,
                                to: 5,
                                attributeName: SEdgeAttribute.weight.rawValue,
                                value: 9)
        
        /**
         *  We want our subgraph to contain the vertice 0, 1, 2 and 4
         */
        let verticesInSubgraph = [0, 1, 2, 4]
        
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
        
        /**
         *  Check if the edge attributes were copied correctly.
         */
        for originalVertex in verticesInSubgraph {
            if let vertexInSubgraph = vertexMap[originalVertex] {
                if let label = subgraph.vertexAttributeValue(forVertex: vertexInSubgraph,
                                                             withAttributeName: SVertexAttribute.label.rawValue) as? String {
                    XCTAssert(label == "\(originalVertex)",
                        "The label of vertex \(originalVertex) was not transferred to the subgraph correctly.")
                } else {
                    XCTAssert(false,
                              "Vertex \(originalVertex) did not have the label attribute in the subgraph!")
                }
            } else {
                XCTAssert(false,
                          "Vertex \(originalVertex) did not have a counterpart in the subgraph!")
            }
        }
        
        if let counterpartOf0 = vertexMap[0],
            let counterpartOf2 = vertexMap[2] {
            if let weight = subgraph.edgeAttributeValue(forEdgeFrom: counterpartOf0,
                                                        to: counterpartOf2,
                                                        withAttributeName: SEdgeAttribute.weight.rawValue) as? Int {
                
                XCTAssert(weight == 7,
                          "The weight of the edge between 0 and 2 changed in the subgraph from 7 to \(weight)")
                
            } else {
                XCTAssert(false,
                          "The attribute of the edge between 0 and 2 was not transferred to the subgraph correctly!")
            }
        } else {
            XCTAssert(false,
                      "At least one of the vertices 0, 2 did not have a counterpart in the subgraph!")
        }
        
        if let counterpartOf4 = vertexMap[4] {
            XCTAssert(subgraph.edgeAttributes[counterpartOf4].count == 0,
                      "The counterpart of 4 should not have edge attributes in the subgraph. However, it had \(subgraph.edgeAttributes[counterpartOf4].count)")
        } else {
            XCTAssert(false,
                      "Vertex 4 did not have a counterpart in the subgraph!")
        }
    }
    
    func testDFS() {
        /**
         *  Create a graph with 6 vertices and two components.
         */
        let G = SGraph(numberOfVertices: 6, directed: false)
        
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
         *  Now we perform two DFS. One in one component and one in the other.
         *  Then we check whether in both runs we found the correct vertices.
         */
        
        let component1 = Set<Int>([0, 1, 2, 3])
        let component2 = Set<Int>([4, 5])
        
        var allegedComponent1 = Set<Int>([0])
        SAlgorithms.depthFirstSearch(in: G, startingAt: 0, performingTaskOnSeenVertex: {
            (vertex, _) in
            allegedComponent1.insert(vertex)
            
            return true
        })
        XCTAssert(component1 == allegedComponent1,
                  "The component 1 found by the DFS was not correct.")
        
        var allegedComponent2 = Set<Int>([4])
        SAlgorithms.depthFirstSearch(in: G, startingAt: 4, performingTaskOnSeenVertex: {
            (vertex, _) in
            allegedComponent2.insert(vertex)
            
            return true
        })
        XCTAssert(component2 == allegedComponent2,
                  "The component 2 found by the DFS was not correct.")
    }
    
    func testContraction() {
        
        let graph = SGraph(numberOfVertices: 5,
                           directed: false)
        
        graph.addEdge(from: 0, to: 1)
        graph.addEdge(from: 0, to: 2)
        graph.addEdge(from: 1, to: 2)
        graph.addEdge(from: 2, to: 3)
        graph.addEdge(from: 3, to: 4)
        
        let contractions = [0, 1, 1, 1, 2]
        
        if let contractedGraph = graph.graphByApplyingContractions(contractions) {
            
            /**
             *  Check if the contracted graph is what we wanted.
             */
            assert(contractedGraph.numberOfVertices == 3,
                   "The contracted graph should have 3 vertices. It has \(contractedGraph.numberOfVertices) though.")
            
            assert(contractedGraph.adjacent(u: 0, v: 1), "0 and 1 should be neighbors. They are not.")
            assert(contractedGraph.adjacent(u: 1, v: 2), "1 and 2 should be neighbors. They are not.")
            assert(!contractedGraph.adjacent(u: 0, v: 2), "0 and 2 are neighbors. They should not be.")
            assert(contractedGraph.adjacent(u: 1, v: 1), "There should be a self-loop from 1 to 1. There is not.")
            assert(!contractedGraph.adjacent(u: 2, v: 2), "There should not be a self-loop from 2 to 2. There is.")
            assert(!contractedGraph.adjacent(u: 0, v: 0), "There should not be a self-loop from 0 to 0. There is.")
        } else {
            assertionFailure("The contracted graph was nil. It shouldn't be!")
        }
        
        // Directed Case
        
        let directedGraph = SGraph(numberOfVertices: 5,
                                   directed: true)
        
        directedGraph.addEdge(from: 0, to: 1)
        directedGraph.addEdge(from: 0, to: 2)
        directedGraph.addEdge(from: 1, to: 2)
        directedGraph.addEdge(from: 2, to: 3)
        directedGraph.addEdge(from: 4, to: 3)
        
        if let contractedDirectedGraph = directedGraph.graphByApplyingContractions(contractions) {
            /**
             *  Check if the contracted graph is what we wanted.
             */
            assert(contractedDirectedGraph.numberOfVertices == 3,
                   "The contracted directed graph should have 3 vertices. It has \(contractedDirectedGraph.numberOfVertices) though.")
            
            assert(contractedDirectedGraph.adjacent(u: 0, v: 1), "1 should be neighbor of 0. It is not.")
            assert(!contractedDirectedGraph.adjacent(u: 1, v: 0), "0 should not be neighbor of 1. It is.")
            assert(contractedDirectedGraph.adjacent(u: 1, v: 1), "There should be a self-loop from 1 to 1. There is not.")
            assert(!contractedDirectedGraph.adjacent(u: 1, v: 2), "2 should not be neighbor of 1. It is.")
            assert(contractedDirectedGraph.adjacent(u: 2, v: 1), "1 should be neighbor of 2. It is not.")
            assert(!contractedDirectedGraph.adjacent(u: 0, v: 2), "2 should not be neighbor of 0. It is.")
            assert(!contractedDirectedGraph.adjacent(u: 2, v: 0), "0 should not be neighbor of 2. It is.")
            assert(!contractedDirectedGraph.adjacent(u: 2, v: 2), "There should not be a self-loop from 2 to 2. There is.")
            assert(!contractedDirectedGraph.adjacent(u: 0, v: 0), "There should not be a self-loop from 0 to 0. There is.")
        } else {
            assertionFailure("The contracted directed graph was nil. It shouldn't be!")
        }
        
    }
    
    func testLouvainCommunityDetection() {
        
        let graph = SAttributedGraph(numberOfVertices: 12)
        
        /**
         *  First clique.
         */
        graph.addEdge(from: 0, to: 1)
        graph.addEdge(from: 0, to: 2)
        graph.addEdge(from: 0, to: 3)
        graph.addEdge(from: 1, to: 2)
        graph.addEdge(from: 1, to: 3)
        graph.addEdge(from: 2, to: 3)
        
        /**
         *  Second clique
         */
        graph.addEdge(from: 4, to: 5)
        graph.addEdge(from: 4, to: 6)
        graph.addEdge(from: 4, to: 7)
        graph.addEdge(from: 5, to: 6)
        graph.addEdge(from: 5, to: 7)
        graph.addEdge(from: 6, to: 7)
        
        /**
         *  Third clique
         */
        graph.addEdge(from: 8, to: 9)
        graph.addEdge(from: 8, to: 10)
        graph.addEdge(from: 8, to: 11)
        graph.addEdge(from: 9, to: 10)
        graph.addEdge(from: 9, to: 11)
        graph.addEdge(from: 10, to: 11)
        
        /**
         *  The connections between the cliques.
         */
        graph.addEdge(from: 3, to: 4)
        graph.addEdge(from: 7, to: 8)
        graph.addEdge(from: 11, to: 0)
        
        /**
         *  All edges have weight 1.
         */
        for vertex in graph {
            for neighbor in graph.edges[vertex] {
                graph.setEdgeAttributeValue(forEdgeFrom: vertex,
                                            to: neighbor,
                                            attributeName: SEdgeAttribute.weight.rawValue,
                                            value: 1.0)
            }
        }

        if let (communityOfVertex, _) = SAlgorithms.louvainCommunities(of: graph) {
            /**
             *  All vertices that belong to a 4-clique should be in the same community.
             */
            assert(communityOfVertex[0] == communityOfVertex[1]
                && communityOfVertex[1] == communityOfVertex[2]
                && communityOfVertex[2] == communityOfVertex[3],
                   "The first clique did not end up in the one cluster.")
            
            assert(communityOfVertex[4] == communityOfVertex[5]
                && communityOfVertex[5] == communityOfVertex[6]
                && communityOfVertex[6] == communityOfVertex[7],
                   "The second clique did not end up in the one cluster.")
            assert(communityOfVertex[8] == communityOfVertex[9]
                && communityOfVertex[9] == communityOfVertex[10]
                && communityOfVertex[10] == communityOfVertex[11],
                   "The first clique did not end up in the one cluster.")
        } else {
            assertionFailure("We didn't get a clustering for the connected cliques graph.")
        }
    }
    
    func testClusteringCoefficients() {
        let graph = SGraph(numberOfVertices: 7)
        graph.addEdge(from: 0, to: 1)
        graph.addEdge(from: 0, to: 2)
        graph.addEdge(from: 0, to: 3)
        graph.addEdge(from: 1, to: 2)
        graph.addEdge(from: 2, to: 4)
        graph.addEdge(from: 2, to: 5)
        graph.addEdge(from: 2, to: 6)
        
        let clusteringCoefficientOfVertex = SAlgorithms.localClusteringCoefficientDistribution(of: graph)
        
        assert(clusteringCoefficientOfVertex[1] == 1.0,
               "The clustering coefficient of vertex 1 should be 1.0, it is \(clusteringCoefficientOfVertex[1]) instead.")
    }
    
    func testPringGraph() {
        let graph = SGraph(numberOfVertices: 5, directed: false)
        graph.addEdge(from: 0, to: 1)
        graph.addEdge(from: 1, to: 2)
        graph.addEdge(from: 1, to: 3)
        graph.addEdge(from: 2, to: 4)
        graph.addEdge(from: 4, to: 3)
        
        
        print("Edgelist:")
        print(graph.toString(useLabels: true, withFormat: .edgeList))
        
        print("GML:")
        print(graph.toString(useLabels: true, withFormat: .GML))
        
        print("DL:")
        print(graph.toString(useLabels: true, withFormat: .DL))
    }
    
    static var allTests = [
        ("testEdges", testEdges),
        ("testDiameter", testDiameter),
        ("testLargestConnectedComponent", testLargestConnectedComponent),
        ("testConnectedComponents", testConnectedComponents),
        ("testSubgraph", testSubgraph),
        ("testAttributedSubgraph", testAttributedSubgraph),
        ("testDFS", testDFS),
        ("testContraction", testContraction),
        ("testLouvainCommunityDetection", testLouvainCommunityDetection),
        ("testClusteringCoefficients", testClusteringCoefficients)
    ]
}

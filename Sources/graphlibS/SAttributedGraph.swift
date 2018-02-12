//
//  SAttributedGraph.swift
//  graphlibSPackageDescription
//
//  Created by Maximilian Katzmann on 18.01.18.
//

import Foundation

//MARK: - Common Attributes


/// These enums stores names of commonly used attributes, which simplifies things,
/// resulting in cleaner code.  E.g. if you need a "weight" attribute, you can
/// use SEdgeAttribute.weight.rawValue instead of "weight", and the compiler will complain,
/// if you type it wrong.

public enum SEdgeAttribute: String {
    case weight = "SEdgeAttribute.weight"
}

public enum SVertexAttribute: String {
    case containedVertices = "SVertexAttribute.containedVertices"
    case weight = "SVertexAttribute.weight"
    case community = "SVertexAttribute.community"
}

public class SAttributedGraph: SGraph {
    
    //MARK: - Properties
    
    /// Vertex attributes store values for each vertex.  The dictionary in the
    /// ith position of the array corresponds to the attributes of the ith vertex.
    /// An attribute is identified by a string.
    ///
    /// Use the vertexAttributeValue(forVertex:withAttributeName:) method to access the
    /// value of a vertex. E.g., node 4 could have a value of "4.5" for the attribute "weight".
    ///             let weight = vertexAttributeValue(forVertex: 4, withAttributeName: "weight") as double // weight = 4.5
    var vertexAttributes = [[String: Any]]()
    
    /// Edge attributes store values for each edge.  The array in the ith position of
    /// the edgeAttributes array contains an array of dictionaries; one for each
    /// outgoing edge of the ith vertex.  The jth position of the ith array contains
    /// the dictionary containing the attributes of the edge between the ith vertex
    /// and the jth neighbor of i.  An attribute is identified by a string.
    ///
    /// Use the edgeAttributeValue(forEdgeFrom:to:withAttributeName:) method to access the
    /// value of an edge. E.g., the edge between vertex 4 and neighbor 1 could
    /// have a value of "2.3" for the attribute "weight".
    ///             let weight = graph.edgeAttributeValue(forEdgeFrom: 4, to: 1, withAttributeName: "weight") as double // weight = 2.3
    var edgeAttributes = [[[String: Any]]]()
    
    //MARK: - Initialization
    
    public override init(numberOfVertices: Int, directed: Bool = false) {
        super.init(numberOfVertices: numberOfVertices, directed: directed)
        self.initializeEmptyAttributes()
    }
    
    public override init(edgeList: String, directed: Bool = false) {
        super.init(edgeList: edgeList, directed: directed)
        self.initializeEmptyAttributes()
    }
    
    public override init(filePath: String, directed: Bool = false) {
        super.init(filePath: filePath, directed: directed)
        self.initializeEmptyAttributes()
    }
    
    
    /// Initializes an SAttributedGraph from an SGraph.
    ///
    /// - Parameter graph: The graph that the initialized graph resembles.
    public init(withGraph graph: SGraph) {
        super.init(numberOfVertices: graph.numberOfVertices,
                   directed: graph.directed)
        
        self.edges = graph.edges
        
        for (vertex, label) in graph.vertexLabels {
            self.vertexLabels[vertex] = label
        }
        
        self.initializeEmptyAttributes()
    }
    
    private func initializeEmptyAttributes() {
        /**
         *  Initialize empty vertex attributes.
         */
        self.vertexAttributes = Array(repeating: [String: Any](),
                                      count: self.numberOfVertices)
        
        /**
         *  Initialize empty edge attributes.
         */
        for edges in self.edges {
            let edgeAttributes = Array(repeating: [String: Any](),
                                       count: edges.count)
            self.edgeAttributes.append(edgeAttributes)
        }
    }
    
    //MARK: - Vertices and Edges
    
    /// Add a vertex to the graph.
    ///
    /// - Complexity: O(1)
    /// - Returns: The index of the newly added vertex
    @discardableResult
    override public func addVertex() -> Int {
        let vertex = super.addVertex()
        
        /**
         *  Create an empty attributes dictionary for the newly added vertex.
         */
        self.vertexAttributes.append([String: Any]())
        self.edgeAttributes.append([[String : Any]]())
        
        return vertex
    }
    
    /// Removes the vertex from the graph.
    ///
    /// - Complexity: O(numberOfEdges).
    /// - Parameter v: The index of the vertex to be removed
    override public func removeVertex(_ v: Int) {
        
        super.removeVertex(v)
        
        self.vertexAttributes.remove(at: v)
        self.edgeAttributes.remove(at: v)
    }
    
    /// Adds an edge from source u to target v.
    ///
    /// - Note: If the the graph is undirected both vertices are treated as source and target.
    ///
    /// - Complexity: Same as the adjacency check.
    /// - Parameters:
    ///   - v: The index of the edge's source.
    ///   - u: The index of the edge's target.
    /// - Returns: A Bool indicating whether the addition was successful. The operation may fail if the edge is already present.
    @discardableResult
    override public func addEdge(from v: Int, to u: Int) -> Bool {

        /**
         *  Add the edge to the graph, if necessary.
         */
        let edgeAddedSuccessfully = super.addEdge(from: u, to: v)
        
        /**
         *  If the edge was actually added, we update our attributes arrays.
         */
        if edgeAddedSuccessfully {
            /**
             *  Add an edge attribute for the edge from u to v.
             */
            self.edgeAttributes[u].append([String: Any]())
            
            /**
             *  If the graph is undirected we also added the edge in the other direction,
             *  but only if we're not currently dealing with a self-loop.
             */
            if !self.directed
                && u != v {
                self.edgeAttributes[v].append([String: Any]())
            }
        }
        
        return edgeAddedSuccessfully
    }
    
    
    /// Removes the edge from u to v.
    ///
    /// - Complexity: Same as adjacency check.
    /// - Parameters:
    ///   - u: The source vertex of the edge to be deleted.
    ///   - v: The target vertex of the edge to be deleted.
    /// - Returns: A Boolean value indicating whether the removal was successful. The operation may fail if the edge doesn't exist in the first place.
    @discardableResult
    override public func removeEdge(from u: Int, to v: Int) -> Bool {
        
        /**
         *  Here we don't rely on super, since we have to update our attributes
         *  arrays during the removal process.
         */
        guard self.adjacent(u: u, v: v) else {
            return false
        }
        
        var removedSuccessful = true
        
        /**
         *  Determine the position of neighbor v in the edges array of u.
         */
        if let vIndexInU = self.edges[u].index(of: v) {
            
            /**
             *  Delete the edge and the corresponding attribute.
             */
            self.edges[u].remove(at: vIndexInU)
            self.edgeAttributes[u].remove(at: vIndexInU)
            
        } else {
            SLogging.error(message: "Tried to remove an edge that apparently doesn't exist.")
            removedSuccessful = false
        }
        
        /**
         *  If the graph is undirected, we actually have to delete two edges.
         */
        if !self.directed {
            
            /**
             *  Determine the position of u in the edges array of neighbor v.
             */
            if let uIndexInV = self.edges[v].index(of: u) {
                
                /**
                 *  Delete the edge and the corresponding attribute.
                 */
                self.edges[v].remove(at: uIndexInV)
                self.edgeAttributes[v].remove(at: uIndexInV)
                
            } else {
                SLogging.error(message: "Tried to remove an edge that apparently doesn't exist.")
                removedSuccessful = false
            }
        }
        
        return removedSuccessful
    }
    
    //MARK: - Contraction
    
    /// Contracts a graph using the vertex assignments in the passed contractions
    /// array.  That is, the integers in the contractions array go from 0 to
    /// <number of vertices in contracted graph> and the integer at the ith position
    /// of the contractions array determines the vertex that the ith vertex is
    /// contracted into.  The weights of the vertices in the resulting graph
    /// correspond to the sum of the weights of the vertices (in the original graph)
    /// that were contracted into the vertex.  The weights of the edges correspond
    /// to the sum of the weights of the edges between vertices (in the original graph)
    /// that are now in adjacent contracted vertices.  Edges between vertices that
    /// are now in the same contrated vertex, are summed up to a self-loop.
    ///
    /// - Note: If the numbers in the contractions array are not consecutive, the resulting graph will have isolated nodes.
    ///
    /// - Complexity: O(m * <complexity of adding an edge>)
    /// - Parameters:
    ///   - contractions: An array where the ith entry contains the index of the vertex (in the resulting, contracted graph) that vertex i is contracted into.
    ///   - actionForContractedEdge: A closure that is called when an edge is contracted. Allows the caller to update the attributes of the graph.
    /// - Returns: An SAttributedGraph representing the contracted graph.
    public func graphByApplyingContractions(_ contractions: [Int],
                                            actionForContractedEdge: ((SAttributedGraph, Int, Int) -> ())?) -> SAttributedGraph? {
        
        /**
         *  Determine the number of nodes in the contracted graph.
         */
        if let largestContractedVertexID = contractions.max() {
            
            /**
             *  Construct the graph with the contracted nodes.
             */
            let contractedGraph = SAttributedGraph(numberOfVertices: largestContractedVertexID + 1,
                                                   directed: self.directed)
            
            /**
             *  Now we iterate the edges of the initial graph and construct the
             *  edges in the contracted graph.
             */
            for (vertex, neighbors) in self.edges.enumerated() {
                
                /**
                 *  The contracted vertex that the current vertex was contracted into.
                 */
                let contractedVertex = contractions[vertex]
                
                for neighbor in neighbors {
                    
                    /**
                     *  The contracted vertex that the neighbor was contracted into.
                     */
                    let contractedNeighbor = contractions[neighbor]
                    
                    /**
                     *  Add the edge.
                     */
                    contractedGraph.addEdge(from: contractedVertex,
                                            to: contractedNeighbor)
                    
                    /**
                     *  Notify that we just contracted an edge.
                     */
                    if let action = actionForContractedEdge {
                        action(contractedGraph, vertex, neighbor)
                    }
                }
                
                /**
                 *  Now we update the contained vertices in the contracted graph.
                 */
                
                /**
                 *  Get the vertices that are contained in this vertex.
                 *  The current vertex might already contain other vertices.
                 */
                var containedVerticesToAdd = self.vertexAttributeValue(forVertex: vertex,
                                                                       withAttributeName: SVertexAttribute.containedVertices.rawValue) as? [Int]
                
                /**
                 *  If the vertex did not contain any other vertices,
                 *  it is a vertex in the original graph, which means
                 *  it is itself added as a contained vertex.
                 */
                if containedVerticesToAdd == nil {
                    containedVerticesToAdd = [vertex]
                }
                
                /**
                 *  If the contracted vertex already contains other vertices,
                 *  we add our contained vertices.
                 */
                if let containedVerticesToAdd = containedVerticesToAdd,
                    let containedVerticesInContractedVertex = contractedGraph.vertexAttributeValue(forVertex: contractedVertex,
                                                                                                   withAttributeName: SVertexAttribute.containedVertices.rawValue) as? [Int] {
                    contractedGraph.setVertexAttributeValue(forVertex: contractedVertex,
                                                            attributeName: SVertexAttribute.containedVertices.rawValue,
                                                            value: containedVerticesInContractedVertex + containedVerticesToAdd)
                } else {
                    /**
                     *  If the contracted vertex did not contain other vertices,
                     *  we set our contained vertices to be its contained vertices.
                     */
                    contractedGraph.setVertexAttributeValue(forVertex: contractedVertex,
                                                            attributeName: SVertexAttribute.containedVertices.rawValue,
                                                            value: containedVerticesToAdd)
                }
            }
            
            return contractedGraph
            
        } else {
            return nil
        }
    }
    
    //MARK: - Attributes
    
    
    /// Determines the attribute value for the edge between two vertices, if it exists.
    ///
    /// - Complexity: O(deg(u))
    /// - Parameters:
    ///   - u: The start vertex of the edge
    ///   - v: The end vertex of the edge
    ///   - attributeName: The name of the attribute to be obtained.
    /// - Returns: The value of the attribute for the from u to v, or nil if either the edge or the attribute value does not exist.
    public func edgeAttributeValue(forEdgeFrom u: Int,
                                   to v: Int,
                                   withAttributeName attributeName: String) -> Any? {
        if let indexOfVAmongNeighborsOfU = self.edges[u].index(of: v) {
            return self.edgeAttributes[u][indexOfVAmongNeighborsOfU][attributeName]
        } else {
            return nil
        }
    }
    
    
    /// Getting the attribute value of a vertex.
    ///
    /// - Parameters:
    ///   - v: The vertex whose attribute value is to be obtained.
    ///   - attributeName: The name of the attribute whose value is to be obtained.
    /// - Returns: The value of the attribute for the vertex or nil if it doesn't exist.
    public func vertexAttributeValue(forVertex v: Int,
                                     withAttributeName attributeName: String) -> Any? {
        return self.vertexAttributes[v][attributeName]
    }
    
    /// Setting a vertex attribute value.
    ///
    /// - Parameters:
    ///   - v: The vertex whose attribute is to be set.
    ///   - attributeName: The name of the attribute whose value is to be set.
    ///   - value: The value of the attribute for the vertex.
    public func setVertexAttributeValue(forVertex v: Int,
                                        attributeName: String,
                                        value: Any?) {
        self.vertexAttributes[v][attributeName] = value
    }
    
    /// Sets a value for a given attribute name for the edge between two vertices,
    /// if the edge exists.
    ///
    /// - Complexity: O(max(deg(u), deg(v)))
    /// - Parameters:
    ///   - u: The start vertex of the edge.
    ///   - v: The end vertex of the edge
    ///   - attributeName: The name of the attribute whose value is to be set.
    ///   - value: The value that is to be set for the attribute.
    /// - Returns: A Bool indicating whether setting the attribute was successful. This fails if the edge doesn't exist.
    @discardableResult
    public func setEdgeAttributeValue(forEdgeFrom u: Int,
                                      to v: Int,
                                      attributeName: String,
                                      value: Any?) -> Bool {
        
        if let indexOfVAmongNeighborsOfU = self.edges[u].index(of: v) {
            self.edgeAttributes[u][indexOfVAmongNeighborsOfU][attributeName] = value
        } else {
            return false
        }
        
        /**
         *  If the graph is undirected, we also update the edge weight in the
         *  other direction.
         *
         *  We only do this, if we're not currently dealing with a self-loop,
         *  as else we would be setting the value twice.
         */
        if !self.directed
            && u != v {
            if let indexOfUAmongNeighborsOfV = self.edges[v].index(of: u) {
                self.edgeAttributes[v][indexOfUAmongNeighborsOfV][attributeName] = value
            } else {
                return false
            }
        }
        
        return true
    }
    
    //MARK: - Writing
    
    /// Creates a string containing the adjacency list of the graph. Each line represents one edge, vertices are seperated by tabs (\t).
    ///
    /// - Complexity: O(numberOfEdges)
    /// - Parameter useLabels:  Determines whether the vertex indices or the labels of the vertices should be used when printing the graph. (Default false, printing the indices.)
    /// - Returns: A string containing the adjacency list of the graph.
    override public func toString(useLabels: Bool = true,
                                  withFormat format: SGraphOutputFormat = .edgeList) -> String {
        
        switch format {
        case .GML:
            var gml = "graph [\n"
            
            gml += "\tdirected \(self.directed ? 1 : 0)\n"
            
            for vertex in self {
                gml += "\tnode [\n"
                
                gml += "\t\tid \(vertex)\n"
                
                if useLabels,
                    let vertexLabel = self.vertexLabels[vertex] {
                    gml += "\t\tlabel \"\(vertexLabel)\"\n"
                }
                
                for (attribute, value) in self.vertexAttributes[vertex] {
                    gml += "\t\t\(attribute) \(value)\n"
                }
                
                gml += "\t]\n"
            }
            
            for vertex in self {
                for (neighborIndex, neighbor) in self.edges[vertex].enumerated() {
                    gml += "\tedge [\n"
                    
                    gml += "\t\tsource \(vertex)\n"
                    gml += "\t\ttarget \(neighbor)\n"
                    
                    for (attribute, value) in self.edgeAttributes[vertex][neighborIndex] {
                        gml += "\t\t\(attribute) \(value)\n"
                    }
                    
                    gml += "\t]\n"
                }
            }
            
            gml += "]"
            
            return gml
        default:
            return super.toString(useLabels: useLabels,
                                  withFormat: format)
        }
    }
}

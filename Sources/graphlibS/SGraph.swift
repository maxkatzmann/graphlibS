//
//  SGraph.swift
//  graphS
//
//  Created by Maximilian Katzmann on 22.08.17.
//  Copyright © 2018 Maximilian Katzmann. All rights reserved.
//

import Foundation

public enum SGraphOutputFormat: String {
    case edgeList = "edgeList"
    case GML = "GML"
    case DL = "DL"
}

public class SGraph: Sequence {
    
    // MARK: - Properties
    
    /// The edges of the graph.  Array at the ith position contains the indices
    /// of the neighbors of the ith node.
    public var edges: [[Int]] = []
    
    /// Internally each vertex is identified using an index.  This dictionary,
    /// maps the nodes label (e.g. the name of the node in a file) to this index.
    public internal(set) var vertexLabels: [Int: String] = [:]
    
    /// The number of nodes in the graph.
    public var numberOfVertices: Int {
        get {
            return edges.count
        }
    }
    
    
    /// The number of edges in the graph.
    public var numberOfEdges: Int {
        get {
            var edgeSum = 0
            for edges in self.edges {
                edgeSum += edges.count
            }
            
            if !self.directed {
                edgeSum /= 2
            }
            
            return edgeSum
        }
    }
    
    /// A Bool indicating whether the graph is directed or not.
    public let directed: Bool
    
    // MARK: - Initiazlization
    
    /// Default initializer that creates a graph containing the specified
    /// number of isolated vertices.
    ///
    /// - Parameters:
    ///   - numberOfVertices: The number of vertices that the graph should have.
    ///   - directed: Bool indicating whether the graph is directed. The default value is 'false'.
    public init(numberOfVertices: Int = 0, directed: Bool = false) {
        self.directed = directed
        
        for _ in 0..<numberOfVertices {
            edges.append([Int]())
        }
    }
    
    /// Extracts the edge information from a string and adds the corresponding
    /// edgeto the graph. This is a helper method that unifies the behavior of
    /// reading a graph from a file or an edge list string.
    ///
    /// - Parameters:
    ///   - str: A string describing the edge that should be added.
    ///   - indexMap: A map from strings to indices that is used to keep track of which vertices have already been indexed.
    /// - Returns: A Bool value indicating whether the edge was added successfully or not.
    private func addEdge(from str: String,
                         withIndexMap indexMap: inout [String: Int]) -> Bool {
        /**
         *  When the string is empty, we simply ignore it. Additionally,
         *  we ignore string that are actually comments.
         */
        if !str.isEmpty
            && str[str.startIndex] != "#"
            && str[str.startIndex] != "%" {
            
            /**
             *  Each string should contain two components seperated by
             *  whitespaces or tabs.
             */
            let stringComponents = str.components(separatedBy: CharacterSet.whitespaces)
            if stringComponents.count != 2 {
                SLogging.error(message: "There was a string that did not consist of a vertex pair.")
            } else {
                /**
                 *  Get the index for the first vertex
                 */
                let label1 = stringComponents[0]
                var index1 = indexMap[label1]
                if index1 == nil {
                    /**
                     *  If the vertex does not have an index yet, it will get
                     *  the next available index.
                     */
                    index1 = self.edges.count
                    indexMap[label1] = index1!
                    
                    /**
                     *  Make sure we later know which vertex belongs to which
                     *  index and afterwards reserve the neighbor array for
                     */
                    self.vertexLabels[index1!] = label1
                    self.edges.append([])
                }
                
                /**
                 *  Get the index for the second vertex
                 */
                let label2 = stringComponents[1]
                var index2 = indexMap[label2]
                if index2 == nil {
                    /**
                     *  If the vertex does not have an index yet, it will get
                     *  the next available index.
                     */
                    index2 = self.edges.count
                    indexMap[label2] = index2!
                    
                    /**
                     *  Make sure we later know which vertex belongs to which
                     *  index and afterwards reserve the neighbor array for
                     */
                    self.vertexLabels[index2!] = label2
                    self.edges.append([])
                }
                
                self.edges[index1!].append(index2!)
                if !directed {
                    self.edges[index2!].append(index1!)
                }
                
                /**
                 *  A new edge was added successfully.
                 */
                return true
            }
        }
        
        /**
         *  We did not add the edge.
         */
        return false
    }
    
    /// Initializer that generates a graph from an edge list stored in a string.
    /// - Note: When reading an edge list from a file, use the init(filePath:directed:) method for increased performance.
    ///
    /// - Parameters:
    ///   - edgeList: A string containing the edge list representing the graph.
    ///   - directed: Bool indicating whether the graph is directed. The default value is 'false'.
    public init(edgeList: String, directed: Bool = false) {
        self.directed = directed
        
        /**
         *  Auxiliary dictionary to quickly recognize whether a vertex
         *  was assigned an index already.
         */
        var indexMap: [String: Int] = [:]
        var numberOfEdges = 0
        
        edgeList.enumerateLines {
            (line: String, stop: inout Bool) in
            
            if self.addEdge(from: line, withIndexMap: &indexMap) {
                numberOfEdges += 1
            }
            
            /**
             *  We don't stop until we reached the end of the line.
             */
            stop = false
        }
    }
    
    /// Initializer that reads the graph from an adjacency list stored in a file.
    ///
    /// - Parameters:
    ///   - filePath: The path to the file that the graph should be read from.
    ///   - directed: Bool indicating whether the graph should is directed. The default value is 'false'.
    public init(filePath: String, directed: Bool = false) {
        self.directed = directed
        
        if let inputStreamReader = StreamReader(path: filePath) {
            defer {
                inputStreamReader.close()
            }
            
            /**
             *  Auxiliary dictionary to quickly recognize whether a vertex
             *  was assigned an index already.
             */
            var indexMap: [String: Int] = [:]
            var numberOfEdges = 0
            
            /**
             *  Iterate the lines of the file.
             */
            while let line = inputStreamReader.nextLine() {
                
                if self.addEdge(from: line, withIndexMap: &indexMap) {
                    numberOfEdges += 1
                }
            }
        }
    }
    
    // MARK: - Sequence Protocol
    
    
    /// This allows us to iterate the vertices of the graph as
    /// ````
    /// for vertex in graph {
    ///     ...
    /// }
    /// ````
    public func makeIterator() -> CountableRange<Int>.Iterator {
        return (0..<self.numberOfVertices).makeIterator()
    }
    
    // MARK: - Vertices and Edges
    
    /// Add a vertex to the graph.
    ///
    /// - Complexity: O(1)
    /// - Returns: The index of the newly added vertex
    @discardableResult
    public func addVertex() -> Int {
        self.edges.append([Int]())
        return self.edges.count - 1
    }
    
    /// Removes the vertex from the graph.
    ///
    /// - Complexity: O(numberOfNodes + numberOfEdges).
    /// - Parameter v: The index of the vertex to be removed
    public func removeVertex(_ v: Int) {
        
        /**
         *  Removing the vertex and its neighbors.
         */
        self.edges.remove(at: v)
        self.vertexLabels.removeValue(forKey: v)
        
        /**
         *  Since removing a vertex decreases all the indices of the vertices
         *  with a larger index, we have to rename all these vertices, which
         *  can be neighbors of any vertex. This means, we have to iterate all
         *  vertices and check whether they have an neighbor with a larger index.
         *  Since we have to do this anyway, we can remove references to the
         *  deleted vertex in the meantime.
         */
        for u in self {
            
            var vIndex = -1
            for (index, w) in self.edges[u].enumerated() {
                
                /**
                 *  If v is a neighbor of u, v is removed after iterating the
                 *  neighbors
                 */
                if w == v {
                    vIndex = index
                } else {
                    
                    /**
                     *  Removing v decreases the indices of all vertices with a larger index than v.
                     */
                    if w > v {
                        self.edges[u][index] -= 1
                    }
                }
            }
            
            if vIndex >= 0 {
                self.edges[u].remove(at: vIndex)
            }
            
            /**
             *  Since the indices of all vertices with index larger than v changed,
             *  we need to update the vertexLabels to reflect that change.
             */
            if u > v {
                self.vertexLabels[u - 1] = self.vertexLabels[u]
            }
        }
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
    public func addEdge(from v: Int, to u: Int) -> Bool {
        guard !self.adjacent(u: u, v: v) else {
            return false
        }
        
        self.edges[u].append(v)
        
        /**
         *  If the graph is undirected we also add the edge in the other direction.
         *
         *  Also if we u = v, we just added a self loop.
         *  We don't want to add it again.
         */
        if !self.directed && u != v {
            self.edges[v].append(u)
        }
        
        return true
    }
    
    
    /// Removes the edge from u to v.
    ///
    /// - Complexity: Same as adjacency check.
    /// - Parameters:
    ///   - u: The source vertex of the edge to be deleted.
    ///   - v: The target vertex of the edge to be deleted.
    /// - Returns: A Boolean value indicating whether the removal was successful. The operation may fail if the edge doesn't exist in the first place.
    @discardableResult
    public func removeEdge(from u: Int, to v: Int) -> Bool {
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

            } else {
                SLogging.error(message: "Tried to remove an edge that apparently doesn't exist.")
                removedSuccessful = false
            }
        }
        
        return removedSuccessful
    }
    
    // MARK: - Adjacency
    
    /// Determines whether to vertices are connected by an edge, or not.
    ///
    /// - Complexity: If the graph is directed: O(deg(u)). If the graph is undirected: O(min(deg(u), deg(v)).
    /// - Parameters:
    ///   - u: The index of the first vertex.
    ///   - v: The index of the second vertex.
    /// - Returns: A Bool indicating whether the two vertices are connected by an edge.
    public func adjacent(u: Int, v: Int) -> Bool {
        
        if (self.directed) {
            return self.edges[u].contains(v)
        } else {
            if (self.edges[u].count < self.edges[v].count) {
                return self.edges[u].contains(v)
            } else {
                return self.edges[v].contains(u)
            }
        }
    }
    
    
    /// The degree of v in the receiver. That is the number of outgoing edges of v.
    ///
    /// - Complexity: O(1)
    /// - Parameter v: The degree of v.
    public func degree(of v: Int) -> Int {
        return self.edges[v].count
    }
    
    
    /// The maximum degree of the receiver.
    /// - Complexity: O(|vertices|)
    /// - Returns: The maximum degree of the receiver.
    public func maximumDegree() -> Int {
        var maximumDegree = 0
        for vertex in 0..<self.numberOfVertices {
            if degree(of: vertex) > maximumDegree {
                maximumDegree = degree(of: vertex)
            }
        }
        
        return maximumDegree
    }
    
    
    /// The average degree of the receiver.
    ///
    /// - Complexity: O(|vertices|)
    /// - Returns: The average degree of the receiver.
    public func averageDegree() -> Double {
        var degreeSum = 0
        for vertex in 0..<self.numberOfVertices {
            degreeSum += self.degree(of: vertex)
        }
        
        return Double(degreeSum) / Double(self.numberOfVertices)
    }
    
    
    /// Returns the neighbors of a vertex. This is just a wrapper for accessing
    /// the edges array.
    ///
    /// - Parameter v: The vertex whose neighbors are to be obtained.
    /// - Returns: The neighbors of that vertex.
    public func neighborsOf(_ v: Int) -> [Int] {
        return self.edges[v]
    }
    
    // MARK: - Properties
    
    /// Estimated the power-law exponent of the degree distribution of the receiver.
    /// If beta is the power-law coefficient of a graph then the fraction P(k)
    /// of nodes in the network that have degree k is is approximately k^(-beta).
    ///
    /// - Complexity: O(numberOfNodes)
    /// - Returns: A Double representing the estimated power-law exponent of the degree distribution of the receiver.
    public func estimatedPowerLawExponent() -> Double {
        var exponent = 0.0
        
        var degreeDistribution = [Int]()
        var minDegree = Int.max
        
        for vertex in self {
            let degree = self.degree(of: vertex)
            degreeDistribution.append(degree)
            
            if degree < minDegree {
                minDegree = degree
            }
        }
        
        let degreeThreshold = Swift.max(minDegree, 7)
        
        var nodesWithDegreeAtLeastThreshold = 0
        
        for degree in degreeDistribution {
            if degree >= degreeThreshold {
                exponent += log(Double(degree) / (Double(degreeThreshold) - 0.5));
                nodesWithDegreeAtLeastThreshold += 1
            }
        }
        
        return 1.0 + Double(nodesWithDegreeAtLeastThreshold) / exponent;
    }
    
    
    /// Determines the diameter of an undirected graph, which is the longest shortest
    /// path in the graph.
    ///
    /// - Note: Not yet implemented for directed graphs.
    /// - Complexity: O({BFS}) = O(numberOfVertices + numberOfEdges)
    /// - Returns: The diameter of the graph, or -1 if the graph is directed, or Int.max if the graph is not connected, or Int.min if the graph is empty.
    public func diameter() -> Int {
        
        /**
         *  The case for a directed graph is not implemented yet.
         */
        guard !self.directed else {
            return -1
        }
        
        /**
         *  If the graph is empty, the diaemter is -infinity. The diameter is
         *  the maximum length of all shortest paths. If the graph is empty,
         *  this is the maximum over an empty set, which is -infinity.
         */
        guard self.numberOfVertices > 0 else {
            return Int.min
        }
        
        /**
         *  We start at a any vertex v and determine the distance to all other
         *  vertices, using a breadth first search.
         */
        let startVertex = 0
        
        /**
         *  We later need the vertex that is farthest from the start vertex.
         */
        var farthestVertex = startVertex
        var farthestDistance = 0
        
        var distanceToVertex = [Int](repeating: -1,
                                     count: self.numberOfVertices)
        
        distanceToVertex[startVertex] = 0
        
        SAlgorithms.breadthFirstSearch(in: self, startingAt: startVertex) {
            (vertex, parent) -> (Bool) in
            
            distanceToVertex[vertex] = distanceToVertex[parent] + 1
            
            if distanceToVertex[vertex] > farthestDistance {
                farthestVertex = vertex
                farthestDistance = distanceToVertex[vertex]
            }
            
            return true
        }
        
        /**
         *  If we have not seen all vertices in the graph, it consists of several
         *  components and the diameter is thus infinite.
         */
        if let minimumDistance = distanceToVertex.min(), minimumDistance < 0 {
            return Int.max
        }
        
        /**
         *  Find the largest distance to any other vertex, from the
         *  farthestVertex. This is the diameter.
         */
        var distanceToFarthest = [Int](repeating: -1, count: self.numberOfVertices)
        distanceToFarthest[farthestVertex] = 0
        var maximumDistance = 0
        SAlgorithms.breadthFirstSearch(in: self, startingAt: farthestVertex) {
            (vertex, parent) -> (Bool) in
            
            distanceToFarthest[vertex] = distanceToFarthest[parent] + 1
            
            if distanceToFarthest[vertex] > maximumDistance {
                maximumDistance = distanceToFarthest[vertex]
            }
            
            return true
        }
        
        /**
         *  The diameter is the largest distance a vertex is from the farthest
         *  vertex.
         */
        return maximumDistance
    }
    
    // MARK: - Subgraph
    
    /// Obtain the subgraph of the receiver induced by the vertices in the passed set.
    ///
    /// - Complexity: O(|vertices| * max_degree)
    /// - Parameter vertices: The vertex set that forms the induced subgraph.
    /// - Returns: A tuple containing the induced subgraph and a dictionary that maps the vertices in the receiver to their counterparts in the induced subgraph.
    public func subgraph(containing vertices: [Int]) -> (SGraph, [Int: Int]) {
        
        /**
         *  Our subgraph will contain as many vertices as we get passed.
         */
        let subgraph = SGraph(numberOfVertices: vertices.count,
                              directed: self.directed)
        
        /**
         *  Prepare an indicator array that denotes which vertices are part of
         *  the subgraph, as that will save time later.
         */
        var isInComponent = [Bool](repeating: false,
                                   count: self.numberOfVertices)
        
        for vertex in vertices {
            isInComponent[vertex] = true
        }
        
        /**
         *  The vertices in the new graph are indexed from 0 to |vertices| - 1.
         *  Therefore, we create a map that can later be used to identify the
         *  vertices in the subgraph.
         */
        var vertexMap = [Int: Int]()
        for (index, vertex) in vertices.enumerated() {
            vertexMap[vertex] = index
        }
        
        /**
         *  Now we have to build the subgraph by adding the edges from the
         *  original subgraph, where both end points are also in the passed
         *  vertex set.
         */
        for (v_orig, v) in vertexMap {
            /**
             *  Now we map the remaining orignal neighbors to their
             *  indices in the subgraph.
             */
            var neighborsInSubgraph = [Int]()
            for neighborInOriginalGraph in self.edges[v_orig] {
                
                /**
                 *  Check whether this neighbor is also in the subgraph
                 */
                if isInComponent[neighborInOriginalGraph] {
                    /**
                     *  If the force unwrapping fails here, the vertex map is corrupted
                     *  which cannot happen.
                     */
                    neighborsInSubgraph.append(vertexMap[neighborInOriginalGraph]!)
                }
            }
            
            /**
             *  Now, we assign the neighbors of the vertex in the subgraph.
             */
            subgraph.edges[v] = neighborsInSubgraph
            
            /**
             *  Finally we copy the labels of the original graph to the labels
             *  of the subgraph.
             *
             *  v is the vertex in the current graph. v_orig is its counterpart
             *  in the original graph. Therefore, the label of v_orig in the
             *  original graph now becomes the label of v in the subgraph.
             */
            if let vertexLabel = self.vertexLabels[v_orig] {
                subgraph.vertexLabels[v] = vertexLabel
            }
        }
        
        return (subgraph, vertexMap)
    }
    
    // MARK: - Connected Components
    
    /// Determines the vertex set representing the connected component that
    /// contains the passed vertex v.
    ///
    /// - Complexity: O(numberOfVertices + numberOfEdges)
    /// - Parameter v: The vertex contained in the component to obtain.
    /// - Returns: An array containing the vertices of the connected component that contains v.
    public func verticesInConnectedComponent(containing v: Int) -> [Int] {
        
        /**
         *  We collect the vertices that belong to this component.
         *  The start vertex belongs to it in any case.
         */
        var verticesInComponent = [v]
        
        SAlgorithms.breadthFirstSearch(in: self,
                                       startingAt: v,
                                       performingTaskOnSeenVertex: {
                                        
                                        (u: Int, _: Int) -> (Bool) in
                                        
                                        /**
                                         *  Every vertex we encounter in this BFS
                                         *  belongs to our component.
                                         */
                                        verticesInComponent.append(u)
                                        
                                        /**
                                         *  We always want to continue exploring
                                         */
                                        return true
        })
        
        return verticesInComponent
    }
    
    
    /// Determines the vertex set representing the connected component that contains v.
    ///
    /// - Complexity: Complexity of 'verticesInConnectedComponent:' + Complexity of 'subgraph:'
    /// - Parameter v: The vertex whose connected component is to be optained.
    /// - Returns: A tuple containing an SGraph representing the connected component containing v and a dictionary that maps the vertices in the receiver to the vertices in the induced subgraph.
    public func connectedComponent(containing v: Int) -> (SGraph, [Int: Int]) {
        return self.subgraph(containing: self.verticesInConnectedComponent(containing: v))
    }
    
    /// Determines the vertex set representing the largest connected component
    /// in the graph.
    /// - Note: This method is asymptotically not faster than 'verticesInConnectedComponents', it might be faster in practive if one is only interested in the largest component.
    ///
    /// - Complexity: Complexity of 'verticesInConnectedComponents'
    /// - Returns: An array containing the vertices of the largest connected component of the receiver.
    public func verticesInLargestConnectedComponent() -> [Int] {
        
        var largestConnectedComponent = [Int]()
        
        /**
         *  Knowing how many vertices were not seen yet helps in determining
         *  whether its useful to continue searching for larger components.
         */
        var numberOfUnseenVertices = self.numberOfVertices
        
        /**
         *  We store the seen/unseen/processed state of each vertex in this array.
         */
        var vertexStates = [SVertexState](repeating: .unseen,
                                          count: self.numberOfVertices)
        
        /**
         *  We iterate all the vertices of our graph.
         */
        for v in 0..<self.numberOfVertices {
            
            /**
             *  Only if a vertex was not seen yet, we actually process it.
             */
            if vertexStates[v] == .unseen {
                /**
                 *  Get the vertices of the component that contains the start vertex v.
                 */
                // TODO: We can actually save the for-loop after this statement, by using the BFS directly, instead of relying on verticesInConnectedComponent!:
                let verticesInCurrentComponent = self.verticesInConnectedComponent(containing: v)
                
                /**
                 *  All the vertices that are in the current component cannot
                 *  be in another larger component and are therefore marked as
                 *  seen such that they are not processed again.
                 */
                for u in verticesInCurrentComponent {
                    vertexStates[u] = .seen
                    numberOfUnseenVertices -= 1
                }
                
                /**
                 *  If we found a component that is larger than the largest one that
                 *  we found previously, the new one is the new largest component.
                 */
                if verticesInCurrentComponent.count > largestConnectedComponent.count {
                    largestConnectedComponent = verticesInCurrentComponent
                }
                
                /**
                 *  If the largest connected component thus far is larger than the
                 *  the number of unseen vertices, we cannot find a larger component
                 *  among them. Therefore, we can return early.
                 *
                 *  Note that we will always return here eventually, since after
                 *  iterating all components the number of unseen vertices is 0 and
                 *  our largest component will be larger anyway.
                 */
                if largestConnectedComponent.count > numberOfUnseenVertices {
                    return largestConnectedComponent
                }
            }
        }
        
        /**
         *  This statement will usually not be executed since we return earlier
         *  on anyways. An exception might occur for edge cases, for example the
         *  graph being empty.
         */
        return largestConnectedComponent
    }
    
    /// Determines the subgraph of the receiver that represents the largest connected
    /// component.
    ///
    /// - Returns: A tuple containing an SGraph representing the largest component of the receiver, and a dictionary that maps the vertices in the original graph to their counterpart in the induced subgraph.
    public func largestConnectedComponent() -> (SGraph, [Int: Int]) {
        return self.subgraph(containing: self.verticesInLargestConnectedComponent())
    }
    
    /// Determines the vertex sets that represent the connected components of
    /// the graph.
    ///
    /// - Complexity: O(numberOfVertices + numberOfEdges).
    /// - Returns: An array containing arrays, each representing the connected components of the receiver, sorted by the size of the components in descending order.
    public func verticesInConnectedComponents() -> [[Int]] {
        
        var verticesInComponents = [[Int]]()
        
        /**
         *  In order to obtain the connected components of a graph we perform
         *  multiple breadth first searches each starting at a vertex that was
         *  not yet visited by a previous breadth first search.
         *
         *  Knowing how many vertices were not seen yet helps in determining
         *  whether its useful to continue searching for larger components.
         */
        var numberOfUnseenVertices = self.numberOfVertices
        
        /**
         *  We store the seen/unseen/processed state of each vertex in this array.
         */
        var vertexStates = [SVertexState](repeating: .unseen,
                                          count: self.numberOfVertices)
        
        /**
         *  We iterate all the vertices of our graph.
         */
        for v in 0..<self.numberOfVertices {
            
            /**
             *  Only if a vertex was not seen yet, we actually process it.
             */
            if vertexStates[v] == .unseen {
                /**
                 *  Get the vertices of the component that contains the start vertex v.
                 */
                let verticesInCurrentComponent = self.verticesInConnectedComponent(containing: v)
                
                for u in verticesInCurrentComponent {
                    vertexStates[u] = .seen
                    numberOfUnseenVertices -= 1
                }
                
                /**
                 *  Now we simply add the vertices in the current component to
                 *  the array containing the vertex sets of the vertices.
                 */
                verticesInComponents.append(verticesInCurrentComponent)
            }
        }
        
        /**
         *  Finally, we sort the components by size.
         */
        verticesInComponents.sort {
            (component1: [Int], component2: [Int]) -> Bool in
            return component1.count > component2.count
        }
        
        return verticesInComponents
    }
    
    /// Determines all connected components of the receiver.
    ///
    /// - Complexity: Complexits of 'verticesInConnectedComponents' + Complexity of 'subgraph'. (The latter is amortized in O(numberOfVertices * max_degree))
    /// - Returns: An array of tuples, each containing a subgraph representing a connected component of the receiver as well as a dictionary that maps the vertices in the receiver to their counterparts in the induced subgraph. (sorted by component size).
    public func connectedComponents() -> [(SGraph, [Int: Int])] {
        
        var components: [(SGraph, [Int: Int])] = []
        
        /**
         *  At first we obtain all vertex sets that represent a connected component
         *  of the graph.
         */
        let verticesInConnectedComponents = self.verticesInConnectedComponents()
        
        /**
         *  Now we iterate the vertex sets representing the components and
         *  form their induced subgraphs.
         */
        for componentVertexSet in verticesInConnectedComponents {
            /**
             *  Now we add the subgraph induced by the vertices in the current
             *  component into our array of components.
             */
            components.append(self.subgraph(containing: componentVertexSet))
        }
        
        return components
    }
    
    // MARK: - Contraction
    
    
    /// Contracts a graph using the vertex assignments in the passed contractions
    /// array.  That is, the integers in the contractions array go from 0 to
    /// <number of vertices in contracted graph> and the integer at the ith position
    /// of the contractions array determines the vertex that the ith vertex is
    /// contracted into.
    ///
    /// - Note: If the numbers in the contractions array are not consecutive, the resulting graph will have isolated nodes.
    ///
    /// - Complexity: O(m * <complexity of adding an edge>)
    /// - Parameter contractions: An array where the ith entry contains the index of the vertex (in the resulting, contracted graph) that vertex i is contracted into.
    /// - Returns: An SGraph representing the contracted graph.
    public func graphByApplyingContractions(_ contractions: [Int]) -> SGraph? {
        
        /**
         *  Determine the number of nodes in the contracted graph.
         */
        if let largestContractedVertexID = contractions.max() {
            
            /**
             *  Construct the graph with the contracted nodes.
             */
            let contractedGraph = SGraph(numberOfVertices: largestContractedVertexID + 1,
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
                }
            }
            
            return contractedGraph
            
        } else {
            return nil
        }
    }
    
    // MARK: - Writing
    
    /// Creates a string containing the adjacency list of the graph. Each line represents one edge, vertices are seperated by tabs (\t).
    ///
    /// - Complexity: O(numberOfEdges)
    /// - Parameter useLabels:  Determines whether the vertex indices or the labels of the vertices should be used when printing the graph. (Default false, printing the indices.)
    /// - Returns: A string containing the adjacency list of the graph.
    public func toString(useLabels: Bool = false,
                         withFormat format: SGraphOutputFormat = .edgeList) -> String {
        
        var result = ""
        
        switch format {
        case .GML:
            result = "graph [\n"
            
            result += "\tdirected \(self.directed ? 1 : 0)\n"
            
            for vertex in self {
                result += "\tnode [\n"
                
                result += "\t\tid \(vertex)\n"
                
                if useLabels,
                    let vertexLabel = self.vertexLabels[vertex] {
                    result += "\t\tlabel \"\(vertexLabel)\"\n"
                }
                
                result += "\t]\n"
            }
            
            for vertex in self {
                for neighbor in self.edges[vertex] {
                    result += "\tedge [\n"
                    
                    result += "\t\tsource \(vertex)\n"
                    result += "\t\ttarget \(neighbor)\n"
                    
                    result += "\t]\n"
                }
            }
            
            result += "]"
            
            return result
        case .DL:
            result = "DL n=\(self.numberOfVertices)\n"
            result += "format = edgelist1\n"
            result += "labels embedded:\n"
            result += "data:\n"
            
            /**
             *  From now on the DL format is the same as a simple edge list
             *  therefore we can simply fall through to creating the normal edge
             *  list.
             */
            fallthrough
        default:
            
            if self.directed {
                for u in self {
                    for v in self.edges[u] {
                        if useLabels,
                            let u = self.vertexLabels[u],
                            let v = self.vertexLabels[v] {
                            result += "\(u)\t\(v)\n"
                        } else {
                            result += "\(u)\t\(v)\n"
                        }
                    }
                }
            } else {
                for u in self {
                    for v in self.edges[u] {
                        if u <= v {
                            if useLabels,
                                let u = self.vertexLabels[u],
                                let v = self.vertexLabels[v] {
                                result += "\(u)\t\(v)\n"
                            } else {
                                result += "\(u)\t\(v)\n"
                            }
                        }
                    }
                }
            }
            
            return result
        }
    }
    
    
    /// Creates a string that represents the vertex labels dictionary, i.e.
    /// the map of the indices to the labels of the vertices.
    /// By default each line has the form: index\tlabel
    /// If the inverted flag is set, each line has the form: label\tindex
    ///
    /// - Parameter inverted: If inverted the map from the labels to the indices will be printed instead. (Default is false.)
    /// - Complexity: O(numberOfVertices)
    /// - Returns: A string representing the index -> label map.
    public func vertexLabelsToString(inverted: Bool = false) -> String {
        var vertexLabelString = ""
        for (vertex, label) in self.vertexLabels {
            if inverted {
                vertexLabelString += "\(label)\t\(vertex)\n"
            } else {
                vertexLabelString += "\(vertex)\t\(label)\n"
            }
        }
        
        return vertexLabelString
    }
}

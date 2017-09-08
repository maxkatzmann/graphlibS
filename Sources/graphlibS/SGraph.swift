//
//  SGraph.swift
//  graphS
//
//  Created by Maximilian Katzmann on 22.08.17.
//  Copyright © 2017 Maximilian Katzmann. All rights reserved.
//

import Foundation

public class SGraph {
    public var edges: [[Int]] = []
    public private(set) var vertexLabels: [Int: String] = [:]
    public var numberOfVertices: Int {
        get {
            return edges.count
        }
    }
    
    public let directed: Bool
    
    //MARK: - Initiazlization
    
    /// Default initializer.
    ///
    /// - Complexity: O(numberOfVertices)
    /// - Parameter directed: Bool indicating whether the graph is directed.
    public init(numberOfVertices: Int = 0, directed: Bool = false) {
        self.directed = directed
        
        for _ in 0..<numberOfVertices {
            edges.append([Int]())
        }
    }
    
    /// Initializer that reads the graph from an adjacency list stored in a file.
    ///
    /// - Parameters:
    ///   - filePath: The path to the file that the graph should be read from.
    ///   - directed: Bool indicating whether the graph should be treated as directed or not.
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
            var indexForVertexLabel: [String: Int] = [:]
            var numberOfEdges = 0
            
            /**
             *  Iterate the lines of the file.
             */
            while let line = inputStreamReader.nextLine() {
                /**
                 *  Skip lines that are actually comments.
                 */
                if line.characters[line.startIndex] == "#" ||
                    line.characters[line.startIndex] == "%" {
                    continue
                }
                
                /**
                 *  Each line should contain two strings seperated by
                 *  whitespaces or tabs.
                 */
                let lineComponents = line.components(separatedBy: CharacterSet.whitespaces)
                if lineComponents.count != 2 {
                    SLogging.error(message: "There was a line that did not consist of a vertex pair.")
                } else {
                    /**
                     *  Get the index for the first vertex
                     */
                    let label1 = lineComponents[0]
                    var index1 = indexForVertexLabel[label1]
                    if index1 == nil {
                        /**
                         *  If the vertex does not have an index yet, it will get
                         *  the next available index.
                         */
                        index1 = edges.count
                        indexForVertexLabel[label1] = index1!
                        
                        /**
                         *  Make sure we later know which vertex belongs to which
                         *  index and afterwards reserve the neighbor array for
                         */
                        vertexLabels[index1!] = label1
                        edges.append([])
                    }
                    
                    /**
                     *  Get the index for the second vertex
                     */
                    let label2 = lineComponents[1]
                    var index2 = indexForVertexLabel[label2]
                    if index2 == nil {
                        /**
                         *  If the vertex does not have an index yet, it will get
                         *  the next available index.
                         */
                        index2 = edges.count
                        indexForVertexLabel[label2] = index2!
                        
                        /**
                         *  Make sure we later know which vertex belongs to which
                         *  index and afterwards reserve the neighbor array for
                         */
                        vertexLabels[index2!] = label2
                        edges.append([])
                    }
                    
                    edges[index1!].append(index2!)
                    if !directed {
                        edges[index2!].append(index1!)
                    }
                    numberOfEdges += 1
                }
            }
        }
    }
    
    //MARK: - Vertices and Edges
    
    
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
    /// - Complexity: O(numberOfEdges).
    /// - Parameter v: The index of the vertex to be removed
    public func removeVertex(v: Int) {
        
        /**
         *  Removing the vertex and its neighbors.
         */
        self.edges.remove(at: v)
        
        /**
         *  Since removing a vertex decreases all the indices of the vertices
         *  with a larger index, we have to rename all these vertices, which
         *  can be neighbors of any vertex. This means, we have to iterate all
         *  vertices and check whether they have an index with a larger vertex.
         *  Since we have to do this anyway, we can remove references to the
         *  deleted vertex in the meantime.
         */
        for u in 0..<self.edges.count {
            
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
         */
        if !self.directed {
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
        
        if let vIndexInU = self.edges[u].index(of: v),
            let uIndexInV = self.edges[v].index(of: u) {
            self.edges[u].remove(at: vIndexInU)
            self.edges[v].remove(at: uIndexInV)
            return true
        } else {
            SLogging.error(message: "Tried to remove an edge that apparently doesn't exist.")
            return false
        }
    }
    
    //MARK: - Adjacency
    
    /// Determines whether to vertices are connected by an edge, or not.
    ///
    /// - Complexity: If the graph is directed: O(deg(u)). If the graph is undirected: O(max(deg(u), deg(v)).
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
    
    //MARK: - Subgraph
    
    /// Obtain the subgraph of the receiver induced by the vertices in the passed set.
    ///
    /// - Complexity: O(|vertices| * max_degree)
    /// - Parameter vertices: The vertex set that forms the induced subgraph.
    /// - Returns: A tuple containing the induced subgraph and a dictionary that maps the vertices in the receiver to their counterparts in the induced subgraph.
    public func subgraph(containing vertices: Set<Int>) -> (SGraph, [Int: Int]) {
        
        /**
         *  Our subgraph will contain as many vertices as we get passed.
         */
        let subgraph = SGraph(numberOfVertices: vertices.count,
                              directed: self.directed)
        
        /**
         *  The vertices in the new graph are indexed from 0 to |vertices| - 1.
         *  Therefore, we create a map that can later be used to identify the
         *  vertices in the subgraph.
         */
        let indexedVertices = Array(vertices)
        var vertexMap = [Int: Int]()
        for (index, vertex) in indexedVertices.enumerated() {
            vertexMap[vertex] = index
        }
        
        /**
         *  Now we have to build the subgraph by adding the edges from the
         *  original subgraph, where both end points are also in the passed
         *  vertex set.
         */
        for (v_orig, v) in vertexMap {
            /**
             *  Take the neighbors of v_orig in the orignal graph and and reduce
             *  this set to only contain the vertices in the subgraph.
             */
            let reducedNeighborsOfOriginalGraph = Set(self.edges[v_orig]).intersection(vertices)
            
            /**
             *  Now we map the remaining orignal neighbors to their
             *  indices in the subgraph.
             */
            var neighborsInSubgraph = [Int]()
            for neighborInOriginalGraph in reducedNeighborsOfOriginalGraph {
                
                /**
                 *  If the force unwrapping fails here, the vertex map is corrupted
                 *  which cannot happen.
                 */
                neighborsInSubgraph.append(vertexMap[neighborInOriginalGraph]!)
            }
            
            /**
             *  Finally, we assign the neighbors of the vertex in the subgraph.
             */
            subgraph.edges[v] = neighborsInSubgraph
        }
        
        return (subgraph, vertexMap)
    }
    
    //MARK: - Connected Components
    
    /// Determines the vertex set representing the connected component that
    /// contains the passed vertex v.
    ///
    /// - Complexity: O(numberOfVertices + numberOfEdges)
    /// - Parameter v: The vertex contained in the component to obtain.
    /// - Returns: A vertex set representing the connected component that contains v.
    public func verticesInConnectedComponent(containing v: Int) -> Set<Int> {
        /**
         *  We collect the vertices that belong to this component.
         *  The start vertex belongs to it in any case.
         */
        var verticesInComponent: Set<Int> = [v]
        
        SAlgorithms.breadthFirstSearch(in: self,
                                       startingAt: v,
                                       performingTaskOnSeenVertex: {
                                        
                                        (u: Int, _: Int) -> (Bool) in
                                        
                                        /**
                                         *  Every vertex we encounter in this BFS
                                         *  belongs to our component.
                                         */
                                        verticesInComponent.insert(u)
                                        
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
    /// - Returns: A vertex set containing the vertices of the largest connected component of the receiver.
    public func verticesInLargestConnectedComponent() -> Set<Int> {
        var largestConnectedComponent = Set<Int>()
        
        /**
         *  In order to obtain the connected components of a graph we perform
         *  multiple breadth first searches each starting at a vertex that was
         *  not yet visited by a previous breadth first search.
         *
         *  This is repeated until there cannot be any larger connected
         *  component than the largest one we currently have.
         */
        var unseenVertices = Set(0..<self.numberOfVertices)
        
        while let v = unseenVertices.first {
            
            /**
             *  Get the vertices of the component that contains the start vertex v.
             */
            let verticesInCurrentComponent = self.verticesInConnectedComponent(containing: v)
            
            /**
             *  These vertices are no longer unseen.
             */
            unseenVertices.subtract(verticesInCurrentComponent)
            
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
            if largestConnectedComponent.count > unseenVertices.count {
                return largestConnectedComponent
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
    /// - Complexity: O(numberOfVertices + numberOfEdges). Additionally for each component Set subtractions have to be performed.
    /// - Returns: An array containing sets representing the connected components of the receiver, sorted by the size of the components in descending order.
    public func verticesInConnectedComponents() -> [Set<Int>] {
        
        var verticesInComponents = [Set<Int>]()
        
        /**
         *  In order to obtain the connected components of a graph we perform
         *  multiple breadth first searches each starting at a vertex that was
         *  not yet visited by a previous breadth first search.
         */
        var unseenVertices = Set(0..<self.numberOfVertices)
        
        /**
         *  As long as there is at least one unseen vertex in the graph, we take
         *  that vertex and perform a breadth first search starting at it.
         *
         *  All vertices we encounter during this BFS will form one component.
         */
        while let v = unseenVertices.first {
            
            /**
             *  Get the vertices of the component that contains the start vertex v.
             */
            let verticesInCurrentComponent = self.verticesInConnectedComponent(containing: v)
            
            /**
             *  These vertices are no longer unseen.
             */
            unseenVertices.subtract(verticesInCurrentComponent)
            
            /**
             *  Now we simply add the vertices in the current component to
             *  the array containing the vertex sets of the vertices.
             */
            verticesInComponents.append(verticesInCurrentComponent)
        }
        
        verticesInComponents.sort {
            (component1: Set<Int>, component2: Set<Int>) -> Bool in
            return component1.count > component2.count
        }
        
        return verticesInComponents
    }
    
    /// Determines all connected components of the receiver.
    ///
    /// - Complexity: Complexits of 'verticesInConnectedComponents' + Complexity of 'subgraph'. (The latter is amortized in O(numberOfVertice * max_degree))
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
    
    //MARK: - Writing
    
    /// Creates a string containing the adjacency list of the graph. Each line represents one edge, vertices are seperated by tabs (\t).
    ///
    /// - Complexity: O(numberOfEdges)
    /// - Returns: A string containing the adjacency list of the graph.
    public func toString() -> String {
        var adjacencyList = ""
        if self.directed {
            for (u, neighbors) in self.edges.enumerated() {
                for v in neighbors {
                    adjacencyList.append("\(u)\t\(v)\n")
                }
            }
        } else {
            for (u, neighbors) in self.edges.enumerated() {
                for v in neighbors {
                    if u < v {
                        adjacencyList.append("\(u)\t\(v)\n")
                    }
                }
            }
        }
        
        return adjacencyList
    }
}

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
    /// - Complexity: O(numberOfNodes)
    /// - Parameter directed: Bool indicating whether the graph is directed.
    public init(numberOfNodes: Int = 0, directed: Bool = false) {
        self.directed = directed
        
        for _ in 0..<numberOfNodes {
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
    
    //MARK: - Nodes and Edges
    
    
    /// Add a vertex to the graph.
    ///
    /// - Complexity: O(1)
    /// - Returns: The index of the newly added vertex
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

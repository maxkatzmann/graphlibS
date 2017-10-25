//
//  SAlgorithms.swift
//  graphS
//
//  Created by Maximilian Katzmann on 23.08.17.
//  Copyright © 2017 Maximilian Katzmann. All rights reserved.
//

import Foundation

public enum SVertexState: Int {
    case unseen = -1
    case seen = 0
    case processed = 1
}

public class SAlgorithms {
    
    //MARK: - Search
    
    /// Performs a Breadth First Search in the graph starting at a given vertex
    /// and executes a task for each vertex found.
    ///
    /// - Complexity: O((numberOfNodes + numberOfEdges) * Complexity of 'task')
    /// - Parameters:
    ///   - graph: The graph in which the BFS is to be perfomed.
    ///   - vertex: The vertex where the BFS should start.
    ///   - task: A closure that gets called for each (vertex, parent) that is found during the BFS. The closure returns a boolean value indicating whether this node should be further explored or not.
    public static func breadthFirstSearch(in graph: SGraph, startingAt v: Int, performingTaskOnSeenVertex task: (Int, Int) -> (Bool)) {
        
        /**
         *  The priority queue will hold all vertices that we have encountered
         *  but not explored, yet.
         */
        var vertexStates = [SVertexState](repeating: .unseen,
                                          count: graph.numberOfVertices)
        
        /**
         *  v is the first vertex in our search and we dont't want to process it
         *  again.
         */
        var priorityQueue = [v]
        vertexStates[v] = .seen
        
        while !priorityQueue.isEmpty {
            /**
             *  Get the vertex to explore next.
             */
            let u = priorityQueue.removeFirst()
            
            /**
             *  Explore neighbors of u.
             */
            for neighbor in graph.edges[u] {
                
                /**
                 *  Only process neighbors that have not been seen yet
                 */
                if vertexStates[neighbor] == .unseen {
                    vertexStates[neighbor] = .seen
                    
                    /**
                     *  We're about to add the neighbor to the priority queue in
                     *  order to be processed later. Beforehand we pass it to the
                     *  task (along with its parent 'u' in the BFS tree) which
                     *  processes the vertex and returns 'true' if the vertex should
                     *  be processed. If the task returns 'false' we do not process
                     *  the vertex.
                     */
                    if task(neighbor, u) {
                        
                        /**
                         *  We can now add the newly seen neighbor to the priority
                         *  queue such that it can be explored later.
                         */
                        priorityQueue.append(neighbor)
                    }
                }
            }
            
            /**
             *  The vertex is now processed.
             */
            vertexStates[u] = .processed
        }
    }
    
    //MARK: - Clustering
    
    /// Determines the local clustering coefficients for all vertices in the graph
    /// and returns them in an array. The local clustering coefficient of vertex
    /// i is stored at position i in the array.
    ///
    /// - Complexity: O(numberOfNodes * max_degree^2)
    /// - Parameter graph: The graph whose local clustering coefficiens are to be determined
    /// - Returns: An array of Double values representing the local clustering coefficients of the vertices in the graph.
    public static func localClusteringCoefficientDistribution(of graph: SGraph) -> [Double] {
        var localClusteringCoefficients = [Double](repeating: 0.0,
                                                   count: graph.numberOfVertices)
        
        /**
         *  Create an array that will help us with small precomputations,
         *  allowing us to save some time with "adjacency" queries.
         */
        var isNeighbor = [Bool](repeating: false,
                                count: graph.numberOfVertices)
        
        /**
         *  Iterate all vertices in the graph in order to determine their local clustering coefficients.
         */
        for v in 0..<graph.numberOfVertices {
            let numberOfNeighbors = graph.edges[v].count
            
            if numberOfNeighbors < 2 {
                localClusteringCoefficients[v] = 0.0
            } else {
                /**
                 *  Every neighbor could be adjacent to every other neighbor.
                 */
                let possibleEdgesAmongNeighbors = numberOfNeighbors * (numberOfNeighbors - 1)
                
                /**
                 *  Now we count how many of the neighbors of v are actually adjacent.
                 *  Depending on whether the graph is directed or not, we will count
                 *  in different ways.
                 */
                var actualEdgesAmongNeighbors = 0
                
                /**
                 *  We now mark all the neighbors of v in our "isNeighbor" array
                 *  Afterwards when iterating the neighbors of our neighbors
                 *  we don't do adjacency checks, but rather check whether
                 *  they are marked in this array.
                 */
                for u in graph.edges[v] {
                    isNeighbor[u] = true
                }
                
                /**
                 *  In the following we count all the edges that are actually in
                 *  the neighborhood of the vertex. This takes deg(v)^2 to iterate
                 *  all possible neighbor pairs. Additionally a factor of max(deg(N(v)))
                 *  is added by the adjacency check, leading to O(max_degree^3)
                 */
                for u1 in graph.edges[v] {                  // u1 is a neighbor of v
                    for u2 in graph.edges[u1] {             // u2 is a neighbor of u1
                        if isNeighbor[u2] {                 // if u2 is also a neighbor of v...
                            actualEdgesAmongNeighbors += 1  // ... then we have one more edge amongst our neighbors.
                        }
                    }
                }
                
                let localClusteringCoefficient = Double(actualEdgesAmongNeighbors) / Double(possibleEdgesAmongNeighbors)
                
                localClusteringCoefficients[v] = localClusteringCoefficient
                
                /**
                 *  Finally, we reset our "isNeighbor" array, such that when
                 *  processing the next vertex we don't old neighbors marked.
                 */
                for u in graph.edges[v] {
                    isNeighbor[u] = false
                }
            }
        }
        
        return localClusteringCoefficients
    }
}

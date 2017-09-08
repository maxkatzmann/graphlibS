//
//  SAlgorithms.swift
//  graphS
//
//  Created by Maximilian Katzmann on 23.08.17.
//  Copyright © 2017 Maximilian Katzmann. All rights reserved.
//

import Foundation

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
        var priorityQueue = [v]
        
        /**
         *  To make sure we don't explore a vertex twice, we keep track of the
         *  vertices that we have already seen.
         */
        var seenVertices: Set = [v]
        
        while !priorityQueue.isEmpty {
            
            /**
             *  Get the vertex to explore next.
             */
            let u = priorityQueue.removeFirst()
            
            /**
             *  We will only explore neighbors of the current vertex if
             *  we have not seen them yet.
             */
            var neighborsToExplore = Set(graph.edges[u])
            neighborsToExplore.subtract(seenVertices)
            
            for neighbor in neighborsToExplore {
                
                /**
                 *  We have just seen a new vertex.
                 */
                seenVertices.insert(neighbor)
                
                /**
                 *  We're about to add to the priority queue in order to be
                 *  explored later. Beforehand we pass it to the task (along
                 *  with its parent 'u' in the BFS tree) which processes the vertex
                 *  and returns 'true' if the vertex should be explored. If the
                 *  task returns 'false' we do not explore the vertex.
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
    }
    
    //MARK: - Clustering
    
    /// Determines the local clustering coefficients for all vertices in the graph
    /// and returns them in an array. The local clustering coefficient of vertex
    /// i is stored at position i in the array.
    ///
    /// - Complexity: O(numberOfNodes * max_degree^3)
    /// - Parameter graph: The graph whose local clustering coefficiens are to be determined
    /// - Returns: An array of Double values representing the local clustering coefficients of the vertices in the graph.
    public static func localClusteringCoefficientDistribution(of graph: SGraph) -> [Double] {
        var localClusteringCoefficients = [Double](repeating: 0.0,
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
                 *  In the following we count all the edges that are actually in
                 *  the neighborhood of the vertex. This takes deg(v)^2 to iterate
                 *  all possible neighbor pairs. Additionally a factor of max(deg(N(v)))
                 *  is added by the adjacency check, leading to O(max_degree^3)
                 */
                
                /**
                 *  If the graph is directed, we count all possible edges, which
                 *  means between two vertices may be two edges.
                 */
                if graph.directed {
                    for u1 in graph.edges[v] {
                        for u2 in graph.edges[v] {
                            if graph.adjacent(u: u1, v: u2) {
                                actualEdgesAmongNeighbors += 1
                            }
                        }
                    }
                } else {
                    /**
                     *  If the graph is not directed, there is only one edge between
                     *  two vertices, which makes counting a little easier.
                     */
                    for index1 in 0..<numberOfNeighbors - 1 {
                        for index2 in (index1 + 1)..<numberOfNeighbors {
                            if graph.adjacent(u: graph.edges[v][index1], v: graph.edges[v][index2]) {
                                actualEdgesAmongNeighbors += 1
                            }
                        }
                    }
                }
                
                var localClusteringCoefficient = Double(actualEdgesAmongNeighbors) / Double(possibleEdgesAmongNeighbors)
                
                if !graph.directed {
                    localClusteringCoefficient *= 2.0
                }
                
                if localClusteringCoefficient != localClusteringCoefficient {
                    SLogging.error(message: "NaN!")
                }
                
                localClusteringCoefficients[v] = localClusteringCoefficient
            }
        }
        
        return localClusteringCoefficients
    }
}

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
    
    /// Performs a Depth First Search in the graph starting at a given vertex
    /// and executes a task for each vertex found.
    ///
    /// - Complexity: O((numberOfNodes + numberOfEdges) * Complexity of 'task')
    /// - Parameters:
    ///   - graph: The graph in which the DFS is to be perfomed.
    ///   - vertex: The vertex where the DFS should start.
    ///   - task: A closure that gets called for each (vertex, parent) that is found during the DFS. The closure returns a boolean value indicating whether this node should be further explored or not.
    public static func depthFirstSearch(in graph: SGraph, startingAt v: Int, performingTaskOnSeenVertex task: (Int, Int) -> (Bool)) {
        
        /**
         *  The priority queue will hold all vertices that we have encountered
         *  but not explored, yet.
         */
        var vertexStates = [SVertexState](repeating: .unseen,
                                          count: graph.numberOfVertices)
        
        /**
         *  We keep track of which vertex is the parent in the DFS tree using
         *  this array.
         */
        var parentOf = [Int](repeating: -1,
                             count: graph.numberOfVertices)
        
        /**
         *  v itself will not be processed later on.
         */
        vertexStates[v] = .processed
        
        /**
         *  We start with a neighbor of v.
         */
        var priorityStack = [Int]()
        
        /**
         *  Add the neighbors of v to the priority stack and remember that
         *  v is their parent in the DFS tree.
         */
        for neighbor in graph.edges[v] {
            priorityStack.append(neighbor)
            parentOf[neighbor] = v
        }
        
        while !priorityStack.isEmpty {
            /**
             *  Get the vertex to explore next.
             */
            let u = priorityStack.removeLast()
            if vertexStates[u] == .unseen {
                vertexStates[u] = .seen
                
                /**
                 *  We're about to add the neighbor to the priority stack in
                 *  order to be processed later. Beforehand we pass it to the
                 *  task (along with its parent 'u' in the BFS tree) which
                 *  processes the vertex and returns 'true' if the vertex should
                 *  be processed. If the task returns 'false' we do not process
                 *  the vertex.
                 */
                if task(u, parentOf[u]) {
                    
                    /**
                     *  We can now add the newly seen neighbors to the priority
                     *  stack such that they can be explored later.
                     */
                    for neighbor in graph.edges[u] {
                        if vertexStates[neighbor] == .unseen {
                            
                            /**
                             *  Add the neighbor to the stack since we want
                             *  to process it later.
                             */
                            priorityStack.append(neighbor)
                            
                            /**
                             *  Remember that u was the parent of the neighbor.
                             */
                            parentOf[neighbor] = u
                        }
                    }
                }
                
                /**
                 *  The vertex is now processed.
                 */
                vertexStates[u] = .processed
            }
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
        var isNeighborOfV = [Bool](repeating: false,
                                count: graph.numberOfVertices)
        
        /**
         *  Iterate all vertices in the graph in order to determine their local clustering coefficients.
         */
        for v in graph {
            
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
                    isNeighborOfV[u] = true
                }
                
                /**
                 *  In the following we count all the edges that are actually in
                 *  the neighborhood of the vertex. This takes deg(v)^2 to iterate
                 *  all possible neighbor pairs. Additionally a factor of max(deg(N(v)))
                 *  is added by the adjacency check, leading to O(max_degree^3)
                 */
                for u1 in graph.edges[v] {                  // u1 is a neighbor of v
                    for u2 in graph.edges[u1] {             // u2 is a neighbor of u1
                        if isNeighborOfV[u2] {              // if u2 is also a neighbor of v...
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
                    isNeighborOfV[u] = false
                }
            }
        }
        
        return localClusteringCoefficients
    }
    
    //MARK: - Community Detection
    
    /// Determines the communities in the graph using the Louvain algorithm.
    ///
    /// - Complexity: Heuristic approach, no concrete complexity.
    /// - Parameter graph: An undirected(!) graph whose nodes are to be sorted into communities.
    /// - Parameter passThreshold: Determines after how many passes the algorithm should stop. The default value is Int.max so the algorithm stops when the modularity was not improved in the last pass.
    /// - Returns: A tuple containing an array where the ith position denotes the community of vertex i and a Double representing the achieved modularity. The communites are numbered consecutively starting at 0 and are sorted by decreasing size of the community.
    public static func louvainCommunities(of graph: SAttributedGraph,
                                          stoppingAfterPass passThreshold: Int = Int.max) -> ([Int], Double)? {
        
        /**
         *  Make sure the input is an undirected graph.
         */
        guard !graph.directed else {
            print(SLogging.error(message: "This implementation of the Louvain Algorithm only works with undirected graphs."))
            return nil
        }
        
        /**
         *  Determine the weight of each vertex, which is the sum of its
         *  incident edges.
         */
        var weightOfVertex = Array<Double>(repeating: 0.0,
                                           count: graph.numberOfVertices)
        
        var totalWeight = 0.0
        
        for vertex in graph {
            for neighbor in graph.edges[vertex] {
                
                if let edgeWeight = graph.edgeAttributeValue(forEdgeFrom: vertex,
                                                             to: neighbor,
                                                             withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                    weightOfVertex[vertex] += edgeWeight
                    totalWeight += edgeWeight
                }
            }
        }
        
        /// Computes the modularity of a partitioning of a graph.
        ///
        /// - Parameters:
        ///   - communityOfVertex: An array representing the partition. The ith number denotes the community of vertex i.
        ///   - graph: The SAttributedGraph that the partition belongs to.
        ///   - totalWeight: The total weight of all vertices in the graph.
        ///   - weightOfVertex: An array where the ith number denotes the weight of vertex i.
        /// - Returns: A Double representing the modularity of the partition.
        func modularityOfPartition(_ communityOfVertex: [Int],
                                   inGraph graph: SAttributedGraph,
                                   withVertexWeights weightOfVertex: [Double],
                                   andTotalWeight totalWeight: Double) -> Double{
            var modularity = 0.0
            
            for vertex in graph {
                for neighbor in graph.edges[vertex] {
                    
                    if communityOfVertex[vertex] == communityOfVertex[neighbor] {
                        if let edgeWeight = graph.edgeAttributeValue(forEdgeFrom: vertex,
                                                                     to: neighbor,
                                                                     withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                            modularity += edgeWeight - ((weightOfVertex[vertex] * weightOfVertex[neighbor]) / totalWeight)
                        }
                    }
                }
            }
            
            modularity /= totalWeight
            
            return modularity
        }
        
        
        /// Performs one pass of the louvain algorithm that determines the communities
        /// in the given graph.
        ///
        /// - Parameters:
        ///   - graph: The graph in which the communities are to be detected.
        ///   - weightOfVertex: An array where the ith number denots the weight of vertex i.
        ///   - totalWeight: The total weight of all vertices in the graph.
        /// - Returns: A tuple where the first entry contains an array where the ith number denotes the community of index i (community numbers are starting at 0 and are consecutive, the communities are sorted by size starting at the largest) and the second value is the modularity of the partition.
        func louvainOnePass(inGraph graph: SAttributedGraph,
                            withVertexWeights weightOfVertex: [Double],
                            andTotalWeight totalWeight: Double) -> ([Int], Double) {
            
            /// Determines the gain in modularity, by moving a vertex from one community
            /// to another.
            ///
            /// - Parameters:
            ///   - vertex: The vertex to be moved.
            ///   - newCommunity: The community that the vertex should move to.
            ///   - graph: The graph that the vertex and the communities belong to.
            ///   - communityOfVertex: An array where the ith number denotes the community of vertex i.
            ///   - weightOfCommunity: An array where the ith number denotes the weight of community i.
            ///   - weightOfVertex: An array where the ith number denotes the weight of vertex i.
            ///   - totalWeight: The total weight of all vertices.
            /// - Returns: The gein in modularity that would be obtained by moving the vertex into the new community.
            func modularityGainWhenMovingVertex(vertex: Int,
                                                toCommunity newCommunity: Int,
                                                inGraph graph: SAttributedGraph,
                                                withPartition communityOfVertex: [Int],
                                                communityWeights weightOfCommunity: [Double],
                                                vertexWeights weightOfVertex: [Double],
                                                andTotalWeight totalWeight: Double) -> Double {
                
                /**
                 *  If the community of the vertex would not change, we don't have
                 *   any gain.
                 */
                guard newCommunity != communityOfVertex[vertex] else {
                    return 0.0
                }
                
                /**
                 *  The community that the vertex is currently in.
                 */
                let oldCommunity = communityOfVertex[vertex]
                
                /**
                 *  The gain in modularity is obtained by first isolating the veretx
                 *  and then comparing the gain in moving to the old community,
                 *  with the gain of moving into the new community.
                 */
                
                /**
                 *  First we determine the weight that the vertex has into its old / new
                 *  community.
                 */
                var weightIntoOldCommunity = 0.0
                var weightIntoNewCommunity = 0.0
                
                for neighbor in graph.neighborsOf(vertex) {
                    
                    /**
                     *  If the neighbor is in the old community, we add the corresponding
                     *  edge weight to the weight that goes into the old community.
                     *
                     *  Note that self-loops are allowed and we're currently assuming
                     *  that our vertex is isolated, which means that the edge to
                     *  itself does not count as an edge into the old community.
                     */
                    if communityOfVertex[neighbor] == oldCommunity
                        && neighbor != vertex {
                        if let edgeWeight = graph.edgeAttributeValue(forEdgeFrom: vertex,
                                                                     to: neighbor,
                                                                     withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                            weightIntoOldCommunity += edgeWeight
                        }
                        
                        /**
                         *  If the neighbor is in the new community, we add the corresponding
                         *  edge weight to the weight that goes into the new community.
                         */
                    } else if communityOfVertex[neighbor] == newCommunity {
                        if let edgeWeight = graph.edgeAttributeValue(forEdgeFrom: vertex,
                                                                     to: neighbor,
                                                                     withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                            weightIntoNewCommunity += edgeWeight
                        }
                    }
                }
                
                /**
                 *  Now we determine what the 'isolated' vertex would gain by moving
                 *  into the old community.
                 *
                 *  This is simulated by removing the vertex' weight from the
                 *  weight of its community.
                 */
                let gainIntoOldCommunity =
                    2.0 / (totalWeight * totalWeight)
                        * ((totalWeight * weightIntoOldCommunity)
                            - (weightOfVertex[vertex] * (weightOfCommunity[oldCommunity] - weightOfVertex[vertex])))
                
                /**
                 *  Then we determine what the 'isolated' vertex would gain by moving
                 *  into the new community.
                 */
                let gainIntoNewCommunity =
                    2.0 / (totalWeight * totalWeight)
                        * ((totalWeight * weightIntoNewCommunity)
                            - (weightOfVertex[vertex] * weightOfCommunity[newCommunity]))
                
                return gainIntoNewCommunity - gainIntoOldCommunity
            }
            
            /// Moves a vertex from one community to another and updates the weights
            /// of the communities.
            ///
            /// - Parameters:
            ///   - vertex: The vertex to be moved
            ///   - oldCommunity: The community that the vertex is currently in.
            ///   - newCommunity: The community that the vertex moves to.
            ///   - communityOfVertex: The array assigning the community to each node.
            ///   - weightOfCommunity: The array assigning the weight to each community.
            func moveVertex(vertex: Int,
                            fromCommunity oldCommunity: Int,
                            toCommunity newCommunity: Int,
                            inPartition communityOfVertex: inout [Int],
                            withWeights weightOfCommunity: inout [Double]) {
                
                /**
                 *  Assign the vertex to the new community.
                 */
                communityOfVertex[vertex] = newCommunity
                
                /**
                 *  Remove the vertex' weight from the old community.
                 */
                weightOfCommunity[oldCommunity] -= weightOfVertex[vertex]
                
                /**
                 *  Add the vertex' weight to the new community.
                 */
                weightOfCommunity[newCommunity] += weightOfVertex[vertex]
            }
            
            /**
             *  This array assigns a community to each vertex.
             */
            var communityOfVertex = Array<Int>(repeating: 0,
                                               count: graph.numberOfVertices)
            
            /**
             *  Initially all vertices are in their own community.
             */
            for vertex in graph {
                communityOfVertex[vertex] = vertex
            }
            
            /**
             *  Since each vertex is its own community the weight of a
             *  community is simply the weight of the vertex.
             */
            var weightOfCommunity = weightOfVertex
            
            /**
             *  At the beginning the maximum modularity that we now of is the
             *  initial modularity.
             */
            var maximumModularity = modularityOfPartition(communityOfVertex,
                                                          inGraph: graph,
                                                          withVertexWeights: weightOfVertex,
                                                          andTotalWeight: totalWeight)
            
            /**
             *  In each iteration we check whether the current modularity is
             *  larger than the maximum that we have seen until know. We stop
             *  the process when in an iteration the current modularity is not
             *  larger than the maximum one.
             */
            var currentModularity = maximumModularity
            var modularityImprovedInPreviousIteration = true
            
            /**
             *  As long as we improved the modularity in the previous iteration,
             *  we try again.
             */
            while modularityImprovedInPreviousIteration {
                
                /**
                 *  Iterate all vertices and check whether they would fit better
                 *  into a neighboring community.
                 */
                for vertex in graph {
                    
                    /**
                     *  We determine for which neighbor community the gain when
                     *  moving there is the largest.
                     */
                    var maximumModularityGain = 0.0
                    var communityWithMaximumModularityGain = -1
                    
                    for neighbor in graph.neighborsOf(vertex) {
                        
                        /**
                         *  We would only move to a neighboring community, if
                         *  we're not already in it.
                         */
                        if communityOfVertex[vertex] != communityOfVertex[neighbor] {
                            let gain = modularityGainWhenMovingVertex(vertex: vertex,
                                                                      toCommunity: communityOfVertex[neighbor],
                                                                      inGraph: graph,
                                                                      withPartition: communityOfVertex,
                                                                      communityWeights: weightOfCommunity,
                                                                      vertexWeights: weightOfVertex,
                                                                      andTotalWeight: totalWeight)
                            
                            /**
                             *  If the gain is better than what we already have,
                             *  we have a new maximum gain.
                             */
                            if gain > maximumModularityGain {
                                maximumModularityGain = gain
                                communityWithMaximumModularityGain = communityOfVertex[neighbor]
                            }
                        }
                    }
                    
                    /**
                     *  Now we move the vertex to the community with the maximum
                     *  modularity gain, but only if this gain is strictly positive!
                     */
                    if maximumModularityGain > 0.0 {
                        
                        moveVertex(vertex: vertex,
                                   fromCommunity: communityOfVertex[vertex],
                                   toCommunity: communityWithMaximumModularityGain,
                                   inPartition: &communityOfVertex,
                                   withWeights: &weightOfCommunity)
                        
                        currentModularity += maximumModularityGain
                    }
                }
                
                /**
                 *  When we're done iterating, we check whether the modularity
                 *  has improved. If it has, we perform another iteration.
                 */
                if currentModularity > maximumModularity {
                    maximumModularity = currentModularity
                    modularityImprovedInPreviousIteration = true
                } else {
                    modularityImprovedInPreviousIteration = false
                }
            }
            
            /**
             *  The modularity has not improved in the last iteration. This means
             *  that the current partition is a local maximum and we can return it.
             *
             *  First we make sure that the community numbers start at 0 and
             *  are consecutive.
             */
            
            /**
             *  This dictionary assigns all vertices to their community.
             *  Afterwards we will enumerate the entries in this dictionary, to
             *  obtain a consecutive community numbering.
             */
            var verticesInCommunity = [Int: [Int]]()
            
            for vertex in graph {
                if let verticesInCurrentCommunity = verticesInCommunity[communityOfVertex[vertex]] {
                    verticesInCommunity[communityOfVertex[vertex]] = verticesInCurrentCommunity + [vertex]
                } else {
                    verticesInCommunity[communityOfVertex[vertex]] = [vertex]
                }
            }
            
            let communities = Array(verticesInCommunity.values)
            let sortedCommunities = communities.sorted {
                (community1, community2) -> Bool in
                return community1.count > community2.count
            }
            
            /**
             *  Now we enumerate the communities and reassign the consecutive
             *  community numbers to the vertices.
             */
            var communityNumber = 0
            for community in sortedCommunities {
                for vertex in community {
                    communityOfVertex[vertex] = communityNumber
                }
                
                communityNumber += 1
            }
            
            return (communityOfVertex, maximumModularity)
        }
        
        /**
         *  We repeatadly perform passes of the louvain algorithm until the
         *  modularity is no longer increased (or the number of passes exceeds
         *  the pass threshold).
         */
        
        /**
         *  After each pass, we contract the graph to the resulting communities.
         */
        var currentGraph = graph
        
        /**
         *  This array assigns the community to each vertex.
         */
        var communityOfVertex = Array<Int>(repeating: 0,
                                           count: graph.numberOfVertices)
        
        var maximumModularity = -Double.greatestFiniteMagnitude
        
        /**
         *  Keeping track whether the modularity improved in the previous pass.
         */
        var modularityImprovedInPreviousPass = true
        
        /**
         *  We keep track of how many passes we did.
         */
        var numberOfPasses = 0
        
        /**
         *  We iterate as long as there was a modularity improvement in the previous pass,
         *  or as long as the number of passes has not exceeded the defined passThreshold.
         */
        while modularityImprovedInPreviousPass && numberOfPasses <= passThreshold {
            
            /**
             *  We're now doing another pass.
             */
            numberOfPasses += 1
            
            /**
             *  Apply one pass of the louvain algorithm.
             */
            let (newCommunityOfVertex, newModularity) = louvainOnePass(inGraph: currentGraph,
                                                                       withVertexWeights: weightOfVertex,
                                                                       andTotalWeight: totalWeight)
            
            /**
             *  Check whether the modularity has impvroved.
             */
            if newModularity > maximumModularity {
                
                /**
                 *  If the modularity was improved, we perform another pass, after
                 *  contracting the communities.
                 *
                 *  We first check whether the graph can be contracted successfully,
                 *  before setting modularityImprovedInPreviousPass to true.
                 */
                maximumModularity = newModularity
                
                /**
                 *  The newCommunityOfVertex array now corresponds to a potentially
                 *  contracted graph. Therefore, we update the total communityOfVertex
                 *  array by looking up which vertex is in each contracted vertex.
                 */
                for contractedVertex in currentGraph {
                    
                    /**
                     *  The new community which is the community of the contracted
                     *  vertex.
                     */
                    let communityOfContractedVertex = newCommunityOfVertex[contractedVertex]
                    
                    /**
                     *  Get the vertices that are contained in this potentially contracted vertex.
                     */
                    if let containedVertices = currentGraph.vertexAttributes[contractedVertex][SVertexAttribute.containedVertices.rawValue] as? [Int] {
                        
                        /**
                         *  Assign the new community to all the contained vertices.
                         */
                        for vertex in containedVertices {
                            communityOfVertex[vertex] = communityOfContractedVertex
                        }
                    } else {
                        /**
                         *  If the contractedVertex does not contain any vertices, it is
                         *  a vertex from the original graph and therefore its community
                         *  is the new community.
                         */
                        communityOfVertex[contractedVertex] = communityOfContractedVertex
                    }
                }
                
                if let contractedGraph = currentGraph.graphByApplyingContractions(newCommunityOfVertex, actionForContractedEdge: {
                    (contractedGraph, u, v) in
                    
                    /**
                     *  If the edge between u and v had a weight, we add it to
                     *  the weight of the edge between their corresponding
                     *  contracted nodes.
                     *
                     *  Since the graph is undirected, we have to ensure that
                     *  we don't add edge-weights multiple times. Therefore,
                     *  we only add an edge if u is smaller than v. Which will
                     *  be true only once.
                     */
                    if u <= v {
                        if let edgeWeight = graph.edgeAttributeValue(forEdgeFrom: u,
                                                                     to: v,
                                                                     withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                            
                            let contractedU = communityOfVertex[u]
                            let contractedV = communityOfVertex[v]
                            
                            var newEdgeWeight = edgeWeight
                            
                            /**
                             *  Self-loops are counted twice
                             */
                            if contractedU == contractedV {
                                newEdgeWeight *= 2.0
                            }
                            
                            /**
                             *  The weight of the edge in the contracted graph is the
                             *  sum of the weights of the edges between vertices that
                             *  are contained in the contracted vertices.
                             */
                            if let contractedWeight = contractedGraph.edgeAttributeValue(forEdgeFrom: contractedU,
                                                                                         to: contractedV,
                                                                                         withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                                newEdgeWeight += contractedWeight
                            }
                            
                            contractedGraph.setEdgeAttributeValue(forEdgeFrom: contractedU,to: contractedV,
                                                                  attributeName: SEdgeAttribute.weight.rawValue,
                                                                  value: newEdgeWeight)
                        }
                    }
                }) {
                    /**
                     *  Only when the contraction was successful, do we allow
                     *  another pass, as else we would repeat the same pass as
                     *  before.
                     */
                    modularityImprovedInPreviousPass = true
                    
                    /**
                     *  The contracted graph will be used for the next pass.
                     */
                    currentGraph = contractedGraph
                    
                    /**
                     *  Also the weights of the vertices now correspond to the
                     *  contracted graph and need to be updated, as well as
                     *  the total weight of the graph. (Actually the total weight
                     *  of the graph should not have changed when all the contractions
                     *  were done correctly.
                     */
                    totalWeight = 0.0
                    weightOfVertex = Array<Double>(repeating: 0.0,
                                                   count: currentGraph.numberOfVertices)
                    
                    for vertex in currentGraph {
                        for neighbor in currentGraph.edges[vertex] {
                            if let edgeWeight = currentGraph.edgeAttributeValue(forEdgeFrom: vertex,
                                                                                to: neighbor,
                                                                                withAttributeName: SEdgeAttribute.weight.rawValue) as? Double {
                                weightOfVertex[vertex] += edgeWeight
                                totalWeight += edgeWeight
                            }
                        }
                    }
                    
                    
                } else {
                    modularityImprovedInPreviousPass = false
                }
            } else {
                modularityImprovedInPreviousPass = false
            }
        }
        
        /**
         *  At this point the last pass did bring any modularity improvements.
         *  Therefore, we return the
         */
        return (communityOfVertex, maximumModularity)
    }
}

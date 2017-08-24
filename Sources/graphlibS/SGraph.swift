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
    
    public func adjacent(u: Int, v: Int) -> Bool {
        guard u != v else {
            return false
        }
        
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
}

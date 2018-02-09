# graphlibS
[![GitHub tag](https://img.shields.io/badge/Version-0.0.34-brightgreen.svg)](https://github.com/maxkatzmann/graphlibS/releases/tag/0.0.34)

This will (hopefully) become a high performance graph library written in Swift.
Totally work in progress at the moment. I don't follow a certain schedule
regarding implementations. Therefore, features will be added whenever I need them
for a task I'm currently working on.

In order to avoid performance decreases safety checks are ommitted. This means,
deleting a vertex that is not actually in the graph will lead to a crash, etc.

---

## Current Graph Features:
**Initialization**
* Read a (directed or undirected) graph from a file
* Create a graph programmatically
* Assign attributes to vertices and edges

**Manipulation**
* add vertices / edges
* delete vertices / edges

**Adjacency**
* check whether two vertices are connected
* get the degree of a vertex
* get the maximum degree of a graph
* get the average degree of a graph

**Subgraph**
* get the induced subgraph of a graph containing specified vertices

**Connected Components**
* get the vertex set representing the connected component containing a vertex
* get the vertex set representing the largest connected component of a graph
* get the vertex sets representing all connected components of a graph
* get a subgraph representing the connected component containing a vertex 
* get a subgraph representing the largest connected component of a graph
* get the subgraphs representing all connected components of a graph

**Contraction**
* obtain a graph by contracting groups of vertices to single vertices

**Output**
* print the adjacency list of a graph

---

## Current Algorithms
* Breadth First Search starting at a specified vertex.
* Depth First Search starting at a specified vertex.
* Determining the local clustering coefficients of the vertices in the graph.
* Louvain algorithm for community detection.

---

## Documentation
The code itself should be well documented. I hope to add some usage examples
here soon.

---

## Known Issues
 * Mutli-edges are not supported
 * Self-loops should be supported but are not tested.
 * Most graph manipulations (like getting subgraphs) don't keep track
   of the attributes in attributed graphs.

---
## License
GPL-3.0


























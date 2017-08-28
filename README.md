# graphlibS
[![GitHub tag](https://img.shields.io/github/tag/expressjs/express.svg)](https://github.com/maxkatzmann/graphlibS/)

This will (hopefully) become a high performance graph library written in Swift.
Totally work in progress at the moment. I don't follow a certain schedule
regaring implementations. Therefore, features will be added whenever I need them
for a task I'm currently working on.

In order to avoid performance decreases I omit safety checks. This means,
deleting a vertex that is not actually in the graph will lead to a crash.

What's currently working:
* Reading a (directed or undirected) graph from a file
* Creating and editing a graph programmatically
* Printing the adjacency list of a graph
* Determining the local clustering coefficients of the vertices in the graph

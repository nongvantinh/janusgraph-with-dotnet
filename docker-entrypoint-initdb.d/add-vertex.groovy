g = traversal().withRemote('conf/remote-graph.properties')
g.addV('person').property('name', 'Alice').iterate()
g.addV('person').property('name', 'Bob').iterate()

var LiteGraph = require("./litem.js").LiteGraph;

var graph = new LiteGraph.LGraph();

var node_time = LiteGraph.createNode("basic/time");
graph.add(node_time);

var node_console = LiteGraph.createNode("basic/console");
node_console.mode = LiteGraph.ALWAYS;
graph.add(node_console);

node_time.connect( 0, node_console, 1 );

graph.start()
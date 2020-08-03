var start_path = LiteGraph.createNode("Crime/Start Path");
var end_path = LiteGraph.createNode("Crime/End Path");
var crimebase = LiteGraph.createNode("Crime/Crime Base");
var multiplier =  LiteGraph.createNode("Connectors/Extender");

start_path.pos = [300,300];
end_path.pos = [900,100];
crimebase.pos = [100,200];
multiplier.pos = [600,200];

graph.add(start_path);
graph.add(end_path);
graph.add(crimebase);
graph.add(multiplier);

crimebase.connect(0, start_path, 0 );
start_path.connect(0, multiplier, 0 );
multiplier.connect(0, end_path, 0);
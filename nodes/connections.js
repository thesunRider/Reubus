var start_path = LiteGraph.createNode("Crime/Start Path");
var end_path = LiteGraph.createNode("Crime/End Path");
var crimebase = LiteGraph.createNode("Crime/Crime Base");
var multiplier =  LiteGraph.createNode("Connectors/Extender");
var crimeid =  LiteGraph.createNode("Crime/CrimeID");

start_path.pos = [500,300];
end_path.pos = [900,100];
crimebase.pos = [300,200];
multiplier.pos = [700,200];
crimeid.pos = [50,200];

graph.add(start_path);
graph.add(end_path);
graph.add(crimebase);
graph.add(multiplier);
graph.add(crimeid);

crimeid.connect(0,crimebase,1);
crimebase.connect(0, start_path, 0 );
start_path.connect(0, multiplier, 0 );
multiplier.connect(0, end_path, 0);
function end_path()
{
	this.addInput("Input1");
}

end_path.title = "End Path";
LiteGraph.registerNodeType("Crime/End Path",end_path)

function Crime_Base()
{
  this.addInput("Evidence Box");
  this.addInput("Link CrimeID");
  this.addOutput("Start");
  this.properties = { precision: 1 };
}

//name to show
Crime_Base.title = "Crime Base";

//register in the system
LiteGraph.registerNodeType("Crime/Crime Base", Crime_Base );


function node0()
{
 return 0;
}

function node1(Input1)
{
return Input1;
}

function node2(Input1,Input2)
{
return Input1;
}

function node3(Input1,Input2,Input3)
{
return Input1;
}

function node4(Input1,Input2,Input3,Input4)
{
return Input1;
}

function node5(Input1,Input2,Input3,Input4,Input5)
{
return Input1;
}

function node6(Input1,Input2,Input3,Input4,Input5,Input6)
{
return Input1;
}

function node7(Input1,Input2,Input3,Input4,Input5,Input6,Input7)
{
return Input1;
}

function node8(Input1,Input2,Input3,Input4,Input5,Input6,Input7,Input8)
{
return Input1;
}

function node9(Input1,Input2,Input3,Input4,Input5,Input6,Input7,Input8,Input9)
{
return Input1;
}

function node10(Input1,Input2,Input3,Input4,Input5,Input6,Input7,Input8,Input9,Input10)
{
return Input1;
}

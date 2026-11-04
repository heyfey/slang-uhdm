// § progLocalDeclNets444
interface ifc;
int x;
task automatic t();
  int loc;
  loc = x;
endtask
initial t();
endinterface

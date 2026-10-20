// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
  logic [7:0] in2;
endinterface
module top;
  int cycle = 1;
  ifc dif();
  assign dif.in = cycle;
  assign dif.in2 = cycle;
endmodule

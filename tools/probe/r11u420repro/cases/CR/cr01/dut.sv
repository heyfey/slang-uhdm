// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  int cycle = 0;
  ifc dif();
  assign dif.in = cycle;
endmodule

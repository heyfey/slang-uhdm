// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif [2] ();
  int c = 4;
  assign dif[0].in = c;
endmodule

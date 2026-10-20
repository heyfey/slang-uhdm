// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  int c;
  assign dif.in = c;
endmodule

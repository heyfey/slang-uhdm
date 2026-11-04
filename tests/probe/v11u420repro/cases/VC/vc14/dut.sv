// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
  int c = 5;
endinterface
module top;
  ifc dif();
  int c = 2;
  assign dif.in = c;
endmodule

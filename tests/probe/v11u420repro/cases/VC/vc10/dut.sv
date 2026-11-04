// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  parameter P = 3;
  ifc dif();
  int c = P;
  assign dif.in = c;
endmodule

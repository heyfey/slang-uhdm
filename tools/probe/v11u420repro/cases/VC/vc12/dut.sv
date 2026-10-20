// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc d1();
  ifc d2();
  int c = 6;
  assign d1.in = c;
  assign d2.in = c + 1;
endmodule

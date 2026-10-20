// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  int cycle = 0;
  assign dif.in = cycle;
  always #1 cycle = cycle + 1;
endmodule

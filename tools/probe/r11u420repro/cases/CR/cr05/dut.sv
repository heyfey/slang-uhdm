// § contAssignVarInitRhsShared420
interface ifc(input clk);
  logic [7:0] in;
endinterface
module top;
  int cycle = 0;
  logic clk;
  ifc dif(clk);
  assign dif.in = cycle;
  always @(posedge clk) cycle <= cycle + 1;
endmodule

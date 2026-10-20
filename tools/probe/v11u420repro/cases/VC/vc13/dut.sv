// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top(input logic clk);
  ifc dif();
  int c = 1;
  always_ff @(posedge clk) c <= c + 1;
  assign dif.in = c;
endmodule

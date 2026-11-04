// § uninstIfaceForeachParamOwnTs304
interface ifc(input logic clk);
  parameter int P[3] = '{1,2,3};
  int acc;
  always @(posedge clk) foreach (P[i]) acc += P[i];
endinterface
module top; endmodule

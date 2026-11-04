// § ifaceDefArrNetDimSym436
interface ifc #(int N = 2) (input clk);
  logic w [N];
  always @(posedge clk) w[0] <= 1'b0;
endinterface
module top(input clk);
  ifc i(clk);
endmodule

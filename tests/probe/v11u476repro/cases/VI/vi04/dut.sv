// § ifaceUdpShapedNoRefMod476
interface a_if #(parameter W = 2, X = 1, Y = 0)(input clk, rst);
  logic [W-1:0] A;
endinterface
module top;
  logic clk, rst;
  a_if #(4, 5, 6) u(clk, rst);
endmodule

// § ifaceUdpShapedNoRefMod476
interface a_if #(parameter W = 2)(input clk, rst);
  logic [W-1:0] A;
endinterface
module top;
  logic clk;
  logic rst;
  a_if #(4) u(clk, rst);
endmodule

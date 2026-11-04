// § ifaceUdpShapedNoRefMod476
interface a_if #(parameter W = 2)(input clk, rst);
  logic [W-1:0] A;
endinterface
module top #(parameter P = 3);
  logic clk, rst;
  a_if #(P) u(clk, rst);
endmodule

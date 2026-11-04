// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, input rst, input en);
  logic [31:0] A;
endinterface
module top;
  logic clk, rst, en;
  a_if u(clk, rst, en);
endmodule

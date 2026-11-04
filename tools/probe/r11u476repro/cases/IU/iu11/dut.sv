// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
endinterface
module top;
  logic clk;
  logic rst;
  a_if u(clk & rst, rst);
endmodule

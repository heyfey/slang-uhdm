// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
endinterface
module top;
  logic clk;
  logic rst;
  a_if u1(clk, rst), u2(rst, clk);
endmodule

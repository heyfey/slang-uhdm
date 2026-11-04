// § ifaceUdpShapedNoRefMod476
interface a_if(clk, rst);
  input clk;
  input rst;
  logic [31:0] A;
endinterface
module top;
  logic clk, rst;
  a_if u(clk, rst);
endmodule

// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, input rst);
endinterface
module top;
  logic clk;
  logic rst;
  a_if u(clk, rst);
endmodule

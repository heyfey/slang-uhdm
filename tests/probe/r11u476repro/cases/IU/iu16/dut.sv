// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
endinterface
module sub(a_if p);
endmodule
module top;
  logic clk;
  logic rst;
  a_if u(clk, rst);
  sub s(u);
endmodule

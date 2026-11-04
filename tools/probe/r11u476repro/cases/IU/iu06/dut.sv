// § ifaceUdpShapedNoRefMod476
interface a_if(input clk);
  logic [31:0] A;
endinterface
module top;
  logic clk;
  a_if u(clk);
endmodule

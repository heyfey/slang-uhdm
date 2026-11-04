// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, output logic q);
  assign q = clk;
endinterface
module top(input logic clk, output logic q);
  a_if u(clk, q);
endmodule

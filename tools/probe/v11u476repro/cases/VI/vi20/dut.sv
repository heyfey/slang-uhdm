// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, output logic q);
  always @(posedge clk) q <= ~q;
endinterface
module top;
  logic clk;
  wire q;
  a_if u(clk, q);
  logic r;
  always @(posedge clk) r <= q;
endmodule

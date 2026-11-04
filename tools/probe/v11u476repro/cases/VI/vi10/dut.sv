// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
  modport mp(input clk, output A);
endinterface
module sub(a_if.mp p);
  always @(posedge p.clk) p.A <= 1;
endmodule
module top;
  logic clk, rst;
  a_if u(clk, rst);
  sub s(.p(u.mp));
endmodule

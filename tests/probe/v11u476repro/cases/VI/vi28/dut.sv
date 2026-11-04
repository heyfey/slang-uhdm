// § ifaceUdpShapedLowConnDecl476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module sub(a_if p);
  logic q;
  always @(posedge p.clk) q <= p.rst;
endmodule
module top;
  logic clk, rst;
  a_if u(clk, rst);
  sub s(u);
endmodule

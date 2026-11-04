// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
interface b_if(input clk, rst);
  a_if inner(clk, rst);
endinterface
module top;
  logic clk, rst;
  b_if u(clk, rst);
endmodule

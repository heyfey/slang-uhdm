// § ifaceUdpShapedLowConnDecl476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module dut(input clk, rst);
endmodule
module top;
  logic clk, rst;
  dut d1(clk, rst);
  dut d2(clk, rst);
  bind dut a_if bi(clk, rst);
endmodule

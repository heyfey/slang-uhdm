// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module top;
  logic clk, rst;
  module inner;
    a_if u(clk, rst);
  endmodule
  inner i();
endmodule

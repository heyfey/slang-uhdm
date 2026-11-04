// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module top;
  logic [1:0] v;
  logic rst;
  a_if u(v[0], rst);
endmodule

// § ifaceUdpShapedLowConnDecl476
interface a_if(input logic [3:0] clk, input rst);
  logic [31:0] A;
endinterface
module top;
  logic [7:0] w;
  logic rst;
  a_if u(w[3:0], rst);
endmodule

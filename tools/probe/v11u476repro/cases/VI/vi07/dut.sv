// § ifaceUdpShapedLowConnDecl476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module top;
  logic [1:0] c;
  logic rst;
  for (genvar i = 0; i < 2; i++) begin : g
    a_if u(c[i], rst);
  end
endmodule

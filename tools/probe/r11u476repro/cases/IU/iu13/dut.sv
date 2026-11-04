// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
endinterface
module top;
  logic clk;
  logic rst;
  generate if (1) begin : g
    a_if u(clk, rst);
  end endgenerate
endmodule

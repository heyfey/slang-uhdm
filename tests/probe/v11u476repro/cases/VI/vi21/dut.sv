// § ifaceUdpShapedNoRefMod476
interface a_if(input clk, rst);
  logic [31:0] A;
  always @(posedge clk) if (rst) A <= 0; else A <= A + 1;
endinterface
module top;
  logic clk, rst;
  if (1) begin : g
    if (1) begin : h
      a_if u(clk, rst);
    end
  end
endmodule

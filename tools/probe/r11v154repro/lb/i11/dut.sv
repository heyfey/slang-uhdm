// § lvPathBaseAtFirstMember154
interface tif; logic [7:0] wdtxx; logic [7:0] q; endinterface
module m(tif bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) begin
    bs.wdtxx[3:0] <= x;
    bs.q[7:4] <= bs.wdtxx[3:0];
  end
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule

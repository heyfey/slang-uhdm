// § lvPathBaseAtFirstMember154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs [2], input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs[1].wdtxx[3:0] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b [2] (); m u(b, clk, x); endmodule

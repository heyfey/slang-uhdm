// § macroIfaceRangeSelBaseTok256 (a nonblocking write in an always_ff, macro body)
`define wr(FIF, LSB) \
  always_ff @(posedge clk) FIF.read_data[LSB+:4] <= x;
interface bif; logic [7:0] read_data; endinterface
module m(input logic clk, bif bi); logic [3:0] x;
  `wr(bi, 4)
endmodule
module top; logic clk; bif b(); m u(.clk(clk), .bi(b)); endmodule

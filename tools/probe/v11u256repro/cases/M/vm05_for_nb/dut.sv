// § macroIfaceRangeSelBaseTok256 (a nonblocking write in a procedural for loop)
`define wr(FIF, I) \
  FIF.read_data[I*2+:2] <= x[I*2+:2];
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(input logic clk, bif bit_field_if); logic [7:0] x;
  always_ff @(posedge clk) for (int i = 0; i < 4; i++) begin `wr(bit_field_if, i) end
endmodule
module top(input logic clk); bif b(); m u(.clk(clk), .bit_field_if(b)); endmodule

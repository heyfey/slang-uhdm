// § macroIfaceRangeSelBaseTok256 (an increment of the selected path in a macro)
`define bump(FIF) \
  FIF.read_data[3:0]++;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(input logic clk, bif bit_field_if);
  always @(posedge clk) begin `bump(bit_field_if) end
endmodule
module top(input logic clk); bif b(); m u(.clk(clk), .bit_field_if(b)); endmodule

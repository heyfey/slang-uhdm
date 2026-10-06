// § lvStreamBaseKeepsActual258 (a non-blocking streaming target in an always_ff)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(input logic clk, bif bit_field_if); logic [3:0] x;
  always_ff @(posedge clk) {>>{bit_field_if.read_data[3:0]}} <= x;
endmodule
module top(input logic clk); bif b(); m u(.clk(clk), .bit_field_if(b)); endmodule

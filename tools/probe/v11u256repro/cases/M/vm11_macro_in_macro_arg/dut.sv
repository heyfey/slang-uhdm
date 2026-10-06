// § macroIfaceRangeSelBaseTok256 (the whole target passed through two macro levels as an argument)
`define inner(T) assign T = x;
`define outer(FIF, LSB) `inner(FIF.read_data[LSB+:4])
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `outer(bit_field_if, 4)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

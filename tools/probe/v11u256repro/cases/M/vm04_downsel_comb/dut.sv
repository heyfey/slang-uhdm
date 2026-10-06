// § macroIfaceRangeSelBaseTok256 (a down select with parameter bounds in an always_comb)
`define wr(FIF, MSB, W) \
  always_comb FIF.read_data[MSB-:W] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m #(parameter int M = 7, parameter int W = 4)(bif bit_field_if); logic [3:0] x;
  `wr(bit_field_if, M, W)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

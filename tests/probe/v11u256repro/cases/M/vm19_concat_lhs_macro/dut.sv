// § macroIfaceRangeSelBaseTok256 (a concatenation target in a macro body, no stream: the law moves it to golden)
`define wr(FIF) \
  always_comb {FIF.read_data[3:0], y} = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [4:0] x; logic y;
  `wr(bit_field_if)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

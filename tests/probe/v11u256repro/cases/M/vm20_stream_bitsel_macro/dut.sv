// § macroIfaceRangeSelBaseTok256 (a bit-select streaming target in a macro body: the bit-select arm, § macroIfacePathTokSpans183, residue)
`define wr(FIF) \
  always_comb {>>{FIF.read_data[3]}} = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic x;
  `wr(bit_field_if)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

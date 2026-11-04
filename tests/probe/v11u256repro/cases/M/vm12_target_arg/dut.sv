// § macroIfaceRangeSelBaseTok256 (the whole selected target a macro argument)
`define conn(T) \
  assign T = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if.read_data[2+:4])
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

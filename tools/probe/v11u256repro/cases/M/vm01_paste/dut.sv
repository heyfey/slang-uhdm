// § macroIfaceRangeSelBaseTok256 (a pasted member token in the macro body)
`define conn(FIF, N, LSB) \
  assign FIF.N``_data[LSB+:4] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if, read, 0)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

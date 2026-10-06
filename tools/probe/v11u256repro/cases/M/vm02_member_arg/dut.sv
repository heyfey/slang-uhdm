// § macroIfaceRangeSelBaseTok256 (the member name an argument, the base in the body)
`define conn(MEM) \
  assign bit_field_if.MEM[2+:4] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(read_data)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

// § macroIfaceRangeSelBaseTok256 (a plain part select in a macro body, CRLF line ends)
`define conn(FIF, MSB, LSB) \
  assign FIF.read_data[MSB:LSB] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if, 5, 2)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

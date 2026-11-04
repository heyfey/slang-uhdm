// § macroIfaceRangeSelBaseTok256 (spaces and a line continuation inside the path)
`define conn(FIF, LSB) \
  assign FIF . read_data \
     [ LSB +: 4 ] = x;
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  `conn(bit_field_if, 1)
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

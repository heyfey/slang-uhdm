// § macroIfaceRangeSelBaseTok256 (the same select outside a macro (control))
interface bif; logic [7:0] read_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  assign bit_field_if.read_data[0+:4] = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

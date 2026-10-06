// § macroIfaceRangeSelBaseTok256 (a streaming target outside a macro: residue, pristine wrong, golden keeps the actual span)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  always_comb {>>{bit_field_if.read_data[3:0]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

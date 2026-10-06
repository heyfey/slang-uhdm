// § lvStreamBaseKeepsActual258 (a bit-select streaming target outside a macro)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic x;
  always_comb {>>{bit_field_if.read_data[3]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

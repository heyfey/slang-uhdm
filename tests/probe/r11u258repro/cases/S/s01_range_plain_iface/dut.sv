// § lvStreamBaseKeepsActual258 (a range-select streaming target outside a macro (v11u256 M/vm17))
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  always_comb {>>{bit_field_if.read_data[3:0]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

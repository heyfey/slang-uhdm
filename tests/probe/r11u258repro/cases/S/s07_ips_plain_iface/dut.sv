// § lvStreamBaseKeepsActual258 (an indexed part select streaming target outside a macro)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [1:0] x; int k;
  always_comb begin k = 2; {>>{bit_field_if.read_data[k+:2]}} = x; end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

// § lvStreamBaseKeepsActual258 (a variable-base indexed part select target in a loop)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic [1:0] x;
  always_comb for (int i = 0; i < 4; i += 2) {>>{bit_field_if.read_data[i+:2]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

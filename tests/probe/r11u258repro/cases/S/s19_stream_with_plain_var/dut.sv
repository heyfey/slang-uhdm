// § lvStreamBaseKeepsActual258 (a streaming target mixing a plain variable and an interface path)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [7:0] x; logic [3:0] y;
  always_comb {>>{y, bit_field_if.read_data[3:0]}} = x;
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

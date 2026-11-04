// § lvStreamBaseKeepsActual258 (a streaming SOURCE on the right side (a control))
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  always_comb x = {>>{bit_field_if.read_data[3:0]}};
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

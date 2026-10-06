// § lvStreamBaseKeepsActual258 (a two-level select on a packed two-dimensional interface member)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bit_field_if); logic [3:0] x; logic [1:0] z;
  always_comb {>>{bit_field_if.d[1][3:0], bit_field_if.d[0][1]}} = {x, z[0]};
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

// § lvStreamBaseKeepsActual258 (an ordinary lvalue select on the same path right after a streaming target in one block: the inLhs restore)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  always_comb begin {>>{bit_field_if.read_data[3:0]}} = x; bit_field_if.wr_data[3:0] = x; bit_field_if.wr_data[7] = x[0]; end
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule

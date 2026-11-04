// § lvStreamBaseKeepsActual258 (an interface path streaming target three instances down)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if); logic [3:0] x;
  always_comb {>>{bit_field_if.read_data[3:0]}} = x;
endmodule
module mid(bif bi); m u(.bit_field_if(bi)); endmodule
module top; bif b(); mid a(.bi(b)); endmodule

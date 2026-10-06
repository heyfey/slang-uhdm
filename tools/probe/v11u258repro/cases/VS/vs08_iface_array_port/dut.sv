// § lvStreamBaseKeepsActual258 (an element of an interface-port array as the path base)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif bp [2]); logic [3:0] x;
  always_comb {>>{bp[1].read_data[3:0]}} = x;
endmodule
module top; bif b [2] (); m u(.bp(b)); endmodule

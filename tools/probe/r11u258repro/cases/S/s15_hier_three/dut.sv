// § lvStreamBaseKeepsActual258 (a three-level interface path streaming target)
interface bif; logic [7:0] read_data; endinterface
interface outer; bif inner(); endinterface
module m(outer o); logic [3:0] x;
  always_comb {>>{o.inner.read_data[3:0]}} = x;
endmodule
module top; outer oo(); m u(.o(oo)); endmodule

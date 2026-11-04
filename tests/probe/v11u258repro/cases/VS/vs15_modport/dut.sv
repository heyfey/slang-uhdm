// § lvStreamBaseKeepsActual258 (a modport port path as a streaming target)
interface bif; logic [7:0] read_data; modport mp(output read_data); endinterface
module m(bif.mp p); logic [3:0] x;
  always_comb {>>{p.read_data[3:0]}} = x;
endmodule
module top; bif b(); m u(.p(b)); endmodule

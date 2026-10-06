// § lvStreamBaseKeepsActual258 (a streaming target fed by a streaming source over another interface path)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
module m(bif a, bif b);
  always_comb {>>{a.read_data[3:0]}} = {<<{b.wr_data[3:0]}};
endmodule
module top; bif x(); bif y(); m u(.a(x), .b(y)); endmodule

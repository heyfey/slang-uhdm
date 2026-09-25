// § lvIdxPathIsRead154
interface tif; logic [1:0] sel; logic [7:0] wdt; endinterface
module mem(tif bus, output logic [7:0] q [4]);
  always_comb begin
    for (int k = 0; k < 4; k++) q[k] = '0;
    q[bus.sel] = bus.wdt;
  end
endmodule
module top(output logic [7:0] q [4]); tif b(); mem u(b, q); endmodule

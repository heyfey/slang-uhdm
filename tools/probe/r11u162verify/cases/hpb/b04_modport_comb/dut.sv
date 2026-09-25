// § hpPartSelBoundNamesBySelect154
interface tif; logic [15:0] wdt; modport rd(input wdt); endinterface
module m #(parameter int LO = 2, parameter int HI = 9) (tif.rd bus, output logic [7:0] o);
  always_comb begin
    o = bus.wdt[HI-1:LO];
  end
endmodule
module top(output logic [7:0] o); tif b(); m u(.bus(b.rd), .o(o)); endmodule

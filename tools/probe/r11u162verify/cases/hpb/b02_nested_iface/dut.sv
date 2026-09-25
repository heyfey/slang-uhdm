// § hpPartSelBoundNamesBySelect154
interface inner; logic [7:0] wdt; endinterface
interface outer; inner sub(); endinterface
module top(output logic [3:0] o);
  localparam int GW = 4;
  outer ob();
  assign o = ob.sub.wdt[GW-1:0];
endmodule

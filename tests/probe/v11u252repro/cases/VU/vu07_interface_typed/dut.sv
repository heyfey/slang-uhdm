// § dupImportSameValueKeeps252
package p;
parameter int W = 5;
parameter int D = W - 1;
endpackage
import p::*;
interface bus_if;
  logic [W-1:0] d;
  modport m(output d);
endinterface
module sub(bus_if.m b);
  assign b.d = D;
endmodule
module top(output logic [W-1:0] o);
  bus_if b();
  sub s(b);
  assign o = b.d;
endmodule

// § caPsSelFullVerbatim192 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 3;
endpackage
interface bus_if;
  logic [31:0] d;
  modport rd (input d);
endinterface
module leaf (input logic [3:0] a, output logic [3:0] o);
  assign o = a;
endmodule
module mid import p::*; (bus_if.rd b, output logic [3:0] o1);
  leaf l1 (.a(b.d[W:0]), .o(o1));
endmodule
module top (input logic [31:0] x, output logic [3:0] o1);
  bus_if bi ();
  assign bi.d = x;
  mid m (.b(bi.rd), .o1(o1));
endmodule

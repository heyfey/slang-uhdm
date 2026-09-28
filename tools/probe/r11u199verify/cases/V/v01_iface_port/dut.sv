// § caPsSelFullVerbatim192 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 3;
endpackage
interface bus_if;
  logic [31:0] d;
endinterface
module leaf (input logic [3:0] a, output logic [3:0] o);
  assign o = a;
endmodule
module mid import p::*; (bus_if b, output logic [3:0] o1, output logic [3:0] o2);
  leaf l1 (.a(b.d[W:0]), .o(o1));
  leaf l2 (.a({b.d[W:1], 1'b0}), .o(o2));
endmodule
module top (input logic [31:0] x, output logic [3:0] o1, output logic [3:0] o2);
  bus_if bi ();
  assign bi.d = x;
  mid m (.b(bi), .o1(o1), .o2(o2));
endmodule

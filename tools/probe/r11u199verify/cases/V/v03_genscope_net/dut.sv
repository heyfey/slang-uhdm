// § caPsSelFullVerbatim192 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 3;
endpackage
module leaf (input logic [3:0] a, output logic [3:0] o);
  assign o = a;
endmodule
module mid import p::*; (input logic [31:0] x, output logic [3:0] o1 [2], output logic [3:0] o2);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [31:0] t = x >> i;
    leaf l (.a(t[W:0]), .o(o1[i]));
  end
  leaf l2 (.a(g[1].t[W:0]), .o(o2));
endmodule
module top (input logic [31:0] x, output logic [3:0] o1 [2], output logic [3:0] o2);
  mid m (.*);
endmodule

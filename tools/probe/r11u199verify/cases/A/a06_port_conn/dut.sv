// § psBoundPaOwnerName192 § caPsSelFullVerbatim192
package p;
  parameter int unsigned W = 3;
endpackage
module leaf (input logic [3:0] a, input logic [3:0] b, output logic [3:0] o);
  assign o = a ^ b;
endmodule
module mid import p::*; (input logic [31:0] x, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  leaf l1 (x[W:0], x[W+4:4], o1);
  leaf l2 (.a(x[W:0]), .b(~x[W:0]), .o(o2));
  leaf l3 (.a(x[31:31-W]), .b({x[W:1], 1'b1}), .o(o3));
endmodule
module top (input logic [31:0] x, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [3:0] o4, output logic [3:0] o5, output logic [3:0] o6);
  mid m1 (.x(x), .o1(o1), .o2(o2), .o3(o3));
  mid m2 (.x(~x), .o1(o4), .o2(o5), .o3(o6));
endmodule

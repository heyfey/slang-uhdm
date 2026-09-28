// § caPsSelFullVerbatim192 § psBoundPaOwnerName192
package p;
  parameter int unsigned W = 3;
endpackage
module leaf (input logic [3:0] a, input logic [3:0] b, output logic [3:0] o);
  assign o = a & b;
endmodule
module mid import p::*; (input logic [31:0] x, input logic [31:0] y, output logic [3:0] o1, output logic [3:0] o2);
  leaf la (.a(x[W:0]), .b(y[W+4:4]), .o(o1));
  leaf lb (.a(y[W:0]), .b(x[W+8:8]), .o(o2));
endmodule
module top (input logic [31:0] x, input logic [31:0] y, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [3:0] o4);
  mid ma (.x(x), .y(y), .o1(o1), .o2(o2));
  mid mb (.x(y), .y(x), .o1(o3), .o2(o4));
endmodule

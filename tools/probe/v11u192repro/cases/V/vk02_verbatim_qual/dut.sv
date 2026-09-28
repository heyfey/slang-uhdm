// § caPsSelFullVerbatim192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule
module sub (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  leaf u4 (.a(x[p::W:0]), .b(y));
  leaf u5 (.a(x[p::W-1:0]), .b(z));
endmodule
module top (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  sub m (.*);
endmodule

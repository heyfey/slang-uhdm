// § caPsSelFullVerbatim192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf (input logic [31:0] a, output logic [31:0] b);
  assign b = a;
endmodule
module sub import p::*; (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  leaf u4 (.a(x[W:0]), .b(y));
  for (genvar i = 0; i < 1; i++) begin : g
    leaf u5 (.a({x[31:W], 1'b0}), .b(z));
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
  sub m (.*);
endmodule

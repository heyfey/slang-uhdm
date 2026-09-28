// § caPsSelFullVerbatim192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module leaf (input logic [5:0] a, output logic [5:0] b);
  assign b = a;
endmodule
module mid import p::*; (input logic [31:0] x, output logic [5:0] y1, output logic [5:0] y2, output logic [5:0] y3, output logic [5:0] y4);
  leaf u1 (.a(x[S:0]), .b(y1));
  leaf u2 (.a({1'b0, x[S:0]}), .b(y2));
  for (genvar g = 0; g < 1; g++) begin : gb
    leaf u3 (.a(x[S:0]), .b(y3));
  end
  leaf u4 (.a(x[S-1:0]), .b(y4));
endmodule
module top (input logic [31:0] x, output logic [5:0] y1, output logic [5:0] y2, output logic [5:0] y3, output logic [5:0] y4);
  mid m (.*);
endmodule

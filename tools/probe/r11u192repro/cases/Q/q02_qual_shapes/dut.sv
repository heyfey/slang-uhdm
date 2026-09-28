// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
  typedef enum logic [2:0] {E0, E4 = 4} e_t;
endpackage
module leaf (input logic [5:0] a, output logic [5:0] b);
  assign b = a;
endmodule
module sub (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4,
  output logic [31:0] y5, output logic [5:0] y6, output logic [31:0] y7, output logic [31:0] y8);
  typedef struct packed { logic [15:0] f; logic [15:0] g; } s_t;
  s_t sv;
  assign sv = x;
  assign y1 = x[p::S-1+0:0];
  assign y2 = x[p::S+:2];
  assign y3 = sv.f[p::S:0];
  assign y4[p::S:0] = x[4:0];
  assign y5 = x[p::E4:0];
  leaf u (.a(x[p::S:0]), .b(y6));
  assign y7 = {1'b0, x[p::S:0]};
  assign y8 = x[(p::S):0];
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4,
  output logic [31:0] y5, output logic [5:0] y6, output logic [31:0] y7, output logic [31:0] y8);
  sub s (.*);
endmodule

// § initHierCaLhsBareName225 — fresh: ANSI header parameters and ports of the substituted width (package struct type)
package p;
  typedef struct packed { int x; } info_t;
endpackage
module top import p::*; #(parameter info_t Info = info_t'(12), localparam int N = Info.x)
  (input logic [N-1:0] i, output logic [N-1:0] q, output logic [N-1:0] r);
  assign q = i;
  assign r = '1;
endmodule

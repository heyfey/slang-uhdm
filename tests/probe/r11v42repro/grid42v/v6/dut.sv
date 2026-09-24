// v11u42 arm v6 — three INSTANCES of one module, plus a non-package local face.
package pv6;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

module leaf #(parameter int unsigned P = 3) (input logic [19:0] w20, output logic [3:0] lo);
  pv6::s_t v;
  localparam int unsigned L = P + 1;
  assign v = w20;
  assign lo[0] = v.m[pv6::LP-1];    // c01 pkg param, three instances
  assign lo[1] = v.m[P-1];          // c02 module parameter, three instances
  assign lo[2] = v.m[L-1];          // c03 derived module localparam
  assign lo[3] = v.m[pv6::LP-P];    // c04 pkg leaf mixed with module param
endmodule

module v6 (input logic [19:0] w20, output logic [63:0] o);
  leaf #(.P(3)) i0 (.w20(w20), .lo(o[3:0]));
  leaf #(.P(5)) i1 (.w20(w20), .lo(o[7:4]));
  leaf #(.P(7)) i2 (.w20(w20), .lo(o[11:8]));
endmodule

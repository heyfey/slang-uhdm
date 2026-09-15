// v11u42 arm v2 — SPELLING / TRIVIA / MACRO faces of the same index.
`define IDXM pv2::LP-1
`define LPM  pv2::LP
package pv2;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

module v2 (input logic [19:0] w20, output logic [63:0] o);
  pv2::s_t v;
  assign v = w20;
  assign o[0] = v.m[pv2::LP-1];          // c01 no spaces
  assign o[1] = v.m[ pv2::LP - 1 ];      // c02 spaces inside the brackets
  assign o[2] = v.m[pv2::LP /*x*/ - 1];  // c03 block comment inside
  assign o[3] = v.m[`IDXM];              // c04 WHOLE index from a macro
  assign o[4] = v.m[`LPM-1];             // c05 macro leaf, source operator
  assign o[5] = v.m[(pv2::LP)-1];        // c06 parenthesised leaf
  assign o[6] = v.m[((pv2::LP-1))];      // c07 doubly parenthesised
  assign o[7] = v.m[pv2::LP
                    - 1];                // c08 index split over two lines
endmodule

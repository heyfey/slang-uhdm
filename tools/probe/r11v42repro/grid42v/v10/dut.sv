// v11u42 arm v10 — the LEXICAL proxy's limit: a package body that INCLUDES the
// function that reads the package's own parameter (the UVM packaging style).
package pi10;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
  `include "body.svh"
endpackage

module v10 (input logic [19:0] w20, output logic [63:0] o);
  pi10::s_t v;
  assign v = w20;
  assign o[0] = pi10::f_inc(v);
  assign o[1] = v.m[pi10::LP-1];   // c02 module-level control
endmodule

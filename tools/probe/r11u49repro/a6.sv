// r11u49 arm a6 — the UNPACKED struct param IMPORTED into a module (isImported
// face) and read there, plus a wildcard-imported unqualified read.
package p;
  typedef struct { int unsigned A; int unsigned B; } ub_t;
  localparam ub_t UI = '{A:1, B:2};
endpackage
module a6 import p::*; (output logic [31:0] o);
  localparam ub_t UL = UI;      // module param defaulted from the package one
  assign o = UI.B + UL.A;
endmodule

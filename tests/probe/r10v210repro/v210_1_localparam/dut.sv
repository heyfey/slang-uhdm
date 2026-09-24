// verifier arm 1 — LOCALPARAM forms in a package, and a parameter that
// defaults to a localparam.  The pass's grid tested `parameter` only.
package v1pkg;
  localparam       L_LIT   = 5;
  localparam int   L_TLIT  = 6;
  localparam       L_EXPR  = L_LIT + 1;
  localparam       L_REF   = L_LIT;
  parameter        L_PFROML = L_LIT;
  parameter        L_PFROMLE= L_EXPR;
  localparam       L_REFREF = L_REF;
endpackage
module v1mod;
  import v1pkg::*;
endmodule

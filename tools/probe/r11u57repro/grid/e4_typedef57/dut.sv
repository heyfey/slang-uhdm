// r11u57 — THE W3 CELL AS A CONTROL, AND IT IS THE OPPOSITE POLARITY HERE.
// A module-local typedef whose target is a PACKAGE-SCOPED name: golden KEEPS
// its `$bits` in the DEFINITION listing and FOLDS it in the ELABORATED one
// (r11u53 §3.3, r11v53 R3).  This pass writes the ELABORATED half, so the
// gate must NOT resurrect the call here — a typedef alias is not a type
// parameter's alias and `typeParamAliasType53` must keep saying so with the
// call buried inside an operation exactly as it does for a whole Rhs.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut (output logic o);
  typedef pk::req_t   loc_t;                 // package-scoped target: W3
  typedef logic [9:0] bi_t;                  // built-in target: folds in both
  localparam int L1 = (1 << $bits(loc_t));   // golden DEF-KEEP / ELAB-FOLD
  localparam int L2 = (1 << $bits(bi_t));    // golden fold / fold
  localparam int L3 = (1 << $bits(pk::req_t)); // CONTROL fold / fold
  assign o = ^{L1[0], L2[0], L3[0]};
endmodule

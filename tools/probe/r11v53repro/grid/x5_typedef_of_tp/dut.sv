// v11u53 BREAK-5: a TYPEDEF OF A TYPE PARAMETER.  `alias_t` IS in Surelog's
// data-type map, so getTypespec resolves it — but to a typespec whose base is
// the parameter.  slang resolves `alias_t` to the TYPEDEF's alias, whose
// declaring symbol is a TypeAlias, not a TypeParameter, so the predicate says
// FOLD.  Does golden?
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
module dut #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  typedef TP alias_t;
  localparam int WA = $bits(alias_t);    // typedef OF the type parameter
  localparam int WD = $bits(TP);         // the law's own cell, for contrast
  localparam int C  = $bits(pk::req_t);  // CONTROL
  assign o = ^{WA[0], WD[0], C[0]};
endmodule

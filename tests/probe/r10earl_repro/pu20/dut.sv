// pu20.sv — PASS 20 witness: § genProcParamFold's TF-CALL-ARGUMENT exception
// is too broad.  pt20.sv measured, in the ELAB view of one gen-scope process:
//     o1 = arr[IDX];                 index FOLDS
//     o3 = pk[IDX];                  index FOLDS
//     o2 = idf(arr[IDX]);            LOCAL call arg   -> ref_obj kept
//     o4 = idf(pk[IDX]);             LOCAL call arg   -> ref_obj kept
//     o5 = pt20_pkg::pf(pk[IDX]);    PACKAGE call arg -> index FOLDS
//     o6 = pt20_pkg::pf(arr[IDX]);   PACKAGE call arg -> index FOLDS
// so the r10scr14 reading ("Surelog's reduce does not descend into call
// actuals") holds only for a MODULE-LOCAL callee.  This file separates the two
// candidate discriminators — the callee's HOME (a package) and the WRITTEN
// QUALIFIER — the way pass 18's § defGenQualPkgCallBinds18 had to.
package pu20_pkg;
  function automatic logic [7:0] pf(input logic [7:0] x);
    return x;
  endfunction
  function automatic int pi(input int x);
    return x;
  endfunction
endpackage

module pu20
  import pu20_pkg::*;
#(
    parameter int W = 8,
    parameter int IDX = 3
) (
    input  logic [W-1:0] a,
    output logic [W-1:0] o1,
    output logic [W-1:0] o2,
    output logic [W-1:0] o3,
    output logic [W-1:0] o4
);

  logic [IDX*2+1:0][W-1:0] pk;
  always_comb pk[0] = a;

  if (W == 8) begin : gi
    always_comb begin : p_if
      o1 = pu20_pkg::pf(pk[IDX]);        // Q1 QUALIFIED package call arg
      o2 = pf(pk[IDX]);                  // Q2 WILDCARD-imported, unqualified
      o3 = pu20_pkg::pf(IDX[W-1:0]);     // Q3 param is the arg itself (select)
      o4 = pu20_pkg::pi(IDX);            // Q4 param is the WHOLE arg
    end
  end

endmodule

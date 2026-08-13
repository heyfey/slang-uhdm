// r10earl39 VERIFIER arm — SEPARATE R2's confound.
// a1_argts only had: m2 = pkg fn, whole RHS (golden ts=1)
//                    R2 = module-local fn, operation-nested (golden ts=0)
// Two axes moved at once. These four cells cross them independently.
package pkr2;
  function automatic logic [7:0] pf(logic [7:0] a); return a ^ 8'ha; endfunction
endpackage

module v1_r2sep (input logic [7:0] i0, output logic [7:0] o0);
  localparam logic [7:0] KK = 8'h5a;
  logic [7:0] a1, a2, a3, a4;

  function automatic logic [7:0] mlf(logic [7:0] a); return ~a; endfunction

  // CELL A: pkg fn, WHOLE RHS      (= a1_argts m2)
  assign a1 = pkr2::pf(i0);
  // CELL B: pkg fn, OPERATION-NESTED
  assign a2 = pkr2::pf(i0) ^ KK;
  // CELL C: module-local fn, WHOLE RHS
  assign a3 = mlf(i0);
  // CELL D: module-local fn, OPERATION-NESTED  (= a1_argts R2)
  assign a4 = mlf(i0) ^ KK;

  assign o0 = a1 ^ a2 ^ a3 ^ a4;
endmodule

module v1_r2sep_top;
  logic [7:0] x, y;
  v1_r2sep u (.i0(x), .o0(y));
endmodule

// wf24.sv — pass-24 residue: the frontier after law B.  bis24 stops at
// ibex_cs_registers.sv:965:56, the ts of a folded PART-SELECT BOUND in a
// gen-scope cont_assign:
//     if (MHPMCounterNum < 29) begin : g_mcountinhibit_reduced
//       assign unused_mhphcounter_we = mhpmcounter_we[31:MHPMCounterNum+3];
// where `parameter int unsigned MHPMCounterNum = 10` is OVERRIDDEN.  Golden's
// int_typespec has vpiSigned=0; ours says 1, because § genCaOwnSymFirst stamps
// VpiSigned(true) on every TYPED param's clone.  This measures the three
// declared-type spellings side by side (the neighbouring § itsR arm four
// hundred lines down already keys on the param's own signedness, so the two
// arms disagree — one of them is wrong).
module if24 #(
  parameter int unsigned P_U = 10,   // unsigned -> golden vpiSigned 0?
  parameter int          P_S = 10,   // signed   -> golden vpiSigned 1?
  parameter              P_N = 10    // untyped  -> ts spans the whole decl
) (
  input  logic [31:0] w,
  output logic [3:0]  a, b, c
);
  if (P_U < 29) begin : g_r
    assign a = w[31:P_U+18];
    assign b = w[31:P_S+18];
    assign c = w[31:P_N+18];
  end
endmodule

module wf24 (
  input  logic [31:0] w,
  output logic [3:0]  a, b, c
);
  if24 #(.P_U(5), .P_S(5), .P_N(5)) u_c (.w(w), .a(a), .b(b), .c(c));
endmodule

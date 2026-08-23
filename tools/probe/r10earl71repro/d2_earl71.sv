// r10earl71 arm d2 — MEASUREMENT ONLY.  The DIRECT-bound axis against the
// operator axis, in a gen-for home and a module-body home, over the six
// symbol origins.  One leaf port per cell.
package pd_earl71;
  parameter  int PPR = 16;
  localparam int PLP = 16;
  parameter  int PQ  = 1;
  typedef enum logic [31:0] { PE0 = 32'd16 } pe_t;
endpackage

module lf72 (
  input [31:0] q0, input [31:0] q1, input [31:0] q2, input [31:0] q3,
  input [31:0] q4, input [31:0] q5, input [31:0] q6, input [31:0] q7,
  input [31:0] q8, input [31:0] q9, input [31:0] qa, input [31:0] qb);
endmodule

module m2_earl71 import pd_earl71::*; (
  input [31:0] sig, output logic [31:0] o0);
  parameter  int MPR = 16;
  localparam int MLP = 16;

  // ---- module-body home, PPR (package parameter)
  lf72 i_mod_PPR (
    .q0(sig[31:PPR]), .q1(sig[PPR:0]), .q2(sig[PPR-1:0]), .q3(sig[PPR+1:0]),
    .q4(sig[PPR^1:0]), .q5(sig[+PPR:0]), .q6(sig[PPR*1:0]), .q7(sig[PPR&31:0]),
    .q8(sig[31:PPR-1]), .q9(sig[(PPR-1):0]), .qa(sig[31:PPR+0]), .qb(sig[PPR/1:0])
  );

  // ---- gen-for home, one leaf per origin
  for (genvar g0 = 0; g0 < 2; g0++) begin: gf_PPR
    lf72 i_gen (
      .q0(sig[31:PPR]), .q1(sig[PPR:0]), .q2(sig[PPR-1:0]), .q3(sig[PPR+1:0]),
      .q4(sig[PPR^1:0]), .q5(sig[+PPR:0]), .q6(sig[PPR*1:0]), .q7(sig[PPR&31:0]),
      .q8(sig[31:PPR-1]), .q9(sig[(PPR-1):0]), .qa(sig[31:PPR+0]), .qb(sig[PPR/1:0])
    );
  end
  for (genvar g1 = 0; g1 < 2; g1++) begin: gf_PLP
    lf72 i_gen (
      .q0(sig[31:PLP]), .q1(sig[PLP:0]), .q2(sig[PLP-1:0]), .q3(sig[PLP+1:0]),
      .q4(sig[PLP^1:0]), .q5(sig[+PLP:0]), .q6(sig[PLP*1:0]), .q7(sig[PLP&31:0]),
      .q8(sig[31:PLP-1]), .q9(sig[(PLP-1):0]), .qa(sig[31:PLP+0]), .qb(sig[PLP/1:0])
    );
  end
  for (genvar g2 = 0; g2 < 2; g2++) begin: gf_PE0
    lf72 i_gen (
      .q0(sig[31:PE0]), .q1(sig[PE0:0]), .q2(sig[PE0-1:0]), .q3(sig[PE0+1:0]),
      .q4(sig[PE0^1:0]), .q5(sig[+PE0:0]), .q6(sig[PE0*1:0]), .q7(sig[PE0&31:0]),
      .q8(sig[31:PE0-1]), .q9(sig[(PE0-1):0]), .qa(sig[31:PE0+0]), .qb(sig[PE0/1:0])
    );
  end
  for (genvar g3 = 0; g3 < 2; g3++) begin: gf_MPR
    lf72 i_gen (
      .q0(sig[31:MPR]), .q1(sig[MPR:0]), .q2(sig[MPR-1:0]), .q3(sig[MPR+1:0]),
      .q4(sig[MPR^1:0]), .q5(sig[+MPR:0]), .q6(sig[MPR*1:0]), .q7(sig[MPR&31:0]),
      .q8(sig[31:MPR-1]), .q9(sig[(MPR-1):0]), .qa(sig[31:MPR+0]), .qb(sig[MPR/1:0])
    );
  end
  for (genvar g4 = 0; g4 < 2; g4++) begin: gf_MLP
    lf72 i_gen (
      .q0(sig[31:MLP]), .q1(sig[MLP:0]), .q2(sig[MLP-1:0]), .q3(sig[MLP+1:0]),
      .q4(sig[MLP^1:0]), .q5(sig[+MLP:0]), .q6(sig[MLP*1:0]), .q7(sig[MLP&31:0]),
      .q8(sig[31:MLP-1]), .q9(sig[(MLP-1):0]), .qa(sig[31:MLP+0]), .qb(sig[MLP/1:0])
    );
  end
  for (genvar g5 = 0; g5 < 2; g5++) begin: gf_GLP
    localparam int GLP = 16;
    lf72 i_gen (
      .q0(sig[31:GLP]), .q1(sig[GLP:0]), .q2(sig[GLP-1:0]), .q3(sig[GLP+1:0]),
      .q4(sig[GLP^1:0]), .q5(sig[+GLP:0]), .q6(sig[GLP*1:0]), .q7(sig[GLP&31:0]),
      .q8(sig[31:GLP-1]), .q9(sig[(GLP-1):0]), .qa(sig[31:GLP+0]), .qb(sig[GLP/1:0])
    );
  end
  // ---- NESTED gen: outer block localparam read in the INNER block
  for (genvar g6 = 0; g6 < 2; g6++) begin: gf_OUT
    localparam int OLP = 16;
    for (genvar g7 = 0; g7 < 2; g7++) begin: gf_IN
      localparam int ILP = 16;
      lf72 i_gen (
        .q0(sig[31:OLP]), .q1(sig[OLP:0]), .q2(sig[OLP-1:0]), .q3(sig[31:ILP]),
        .q4(sig[ILP-1:0]), .q5(sig[31:PPR]), .q6(sig[PPR-1:0]), .q7(sig[31:MPR]),
        .q8(sig[31:g7]), .q9(sig[g7:0]), .qa(sig[31:PQ]), .qb(sig[PQ:0])
      );
    end
  end
  // ---- gen-IF home
  if (1) begin: gi_A
    lf72 i_gen (
      .q0(sig[31:PPR]), .q1(sig[PPR:0]), .q2(sig[PPR-1:0]), .q3(sig[31:MPR]),
      .q4(sig[MPR-1:0]), .q5(sig[31:PE0]), .q6(sig[PE0-1:0]), .q7(sig[31:PQ]),
      .q8(sig[31:PLP]), .q9(sig[PLP-1:0]), .qa(sig[31:MLP]), .qb(sig[MLP-1:0])
    );
  end
  assign o0 = sig;
endmodule

module top_earl72 (input [31:0] sig, output logic [31:0] o0);
  m2_earl71 i_m2 (.sig(sig), .o0(o0));
endmodule

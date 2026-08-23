// r10v71 arm v1 — MEASUREMENT ONLY.  Every select SHAPE that can carry a
// package-parameter bound, in a gen-for home and a module-body home.
package pk_v71;
  parameter  int P  = 16;
  parameter  int Q  = 4;
  parameter  int W  = 8;
  localparam int LP = 12;
endpackage

module lfv71 (
  input [63:0] a0, input [63:0] a1, input [63:0] a2, input [63:0] a3,
  input [63:0] a4, input [63:0] a5, input [63:0] a6, input [63:0] a7,
  input [63:0] a8, input [63:0] a9, input [63:0] aa, input [63:0] ab,
  input [63:0] ac, input [63:0] ad, input [63:0] ae, input [63:0] af);
endmodule

module m1_v71 import pk_v71::*; (input [63:0] sig, input [63:0] sg2,
                                 output logic [63:0] o0);
  logic [63:0] arr2 [0:3];
  // module-body home
  lfv71 i_mod (
    .a0(sig[P-1:Q]),        // part_select, both bounds from pkg params
    .a1(sig[P:0]),
    .a2(sig[63:P]),
    .a3(sig[P:Q]),          // both bounds pkg params
    .a4(sig[P +: 4]),
    .a5(sig[P -: 4]),
    .a6(sig[0 +: W]),
    .a7(sig[P]),            // bit select
    .a8({sig[P-1:Q], sg2[P:0]}),          // concat of two part-selects
    .a9({4{sig[P-1:Q]}}),                 // replication of a part-select
    .aa({sig[P], sg2[Q]}),                // concat of bit selects
    .ab(arr2[1][P-1:Q]),                  // nested: array elem then part sel
    .ac(sig[P-1:Q] & sg2[P-1:Q]),         // operand of an operation
    .ad(sig[LP:0]),                       // pkg LOCALPARAM bound
    .ae(sig[63:LP]),
    .af(sig[P+Q-1:Q])                     // compound bound expression
  );
  // gen-for home
  for (genvar g = 0; g < 2; g++) begin: gfv
    lfv71 i_gen (
      .a0(sig[P-1:Q]),
      .a1(sig[P:0]),
      .a2(sig[63:P]),
      .a3(sig[P:Q]),
      .a4(sig[P +: 4]),
      .a5(sig[P -: 4]),
      .a6(sig[0 +: W]),
      .a7(sig[P]),
      .a8({sig[P-1:Q], sg2[P:0]}),
      .a9({4{sig[P-1:Q]}}),
      .aa({sig[P], sg2[Q]}),
      .ab(arr2[1][P-1:Q]),
      .ac(sig[P-1:Q] & sg2[P-1:Q]),
      .ad(sig[LP:0]),
      .ae(sig[63:LP]),
      .af(sig[P+Q-1:Q])
    );
  end
  assign o0 = sig;
endmodule

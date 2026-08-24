// r10v83 arm 2 — THE CONTEXT MATRIX, independent of r10earl83's g1.
// One SIZE cast with a PARAMETER width (the corpus shape, `W83'(0)`) placed in
// every context the verifier brief names.  MEASUREMENT ONLY.
module snk2_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule
module snkp2_83 #(parameter int K = 1) (input logic [63:0] a, output logic [63:0] y);
  assign y = a + K;
endmodule
interface if2_83; logic [63:0] q; endinterface

function automatic logic [63:0] uf2_83(input logic [63:0] q); return q ^ 64'h33; endfunction

module v2_ctx83;
  localparam int W83 = 12;
  logic [63:0] c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,ca,cb,cc,cd,ce;
  logic [63:0] wide;
  logic [1:0]  sel;

  // K01 ELAB port High_conn, BARE actual                      -- FOLD
  snk2_83 k01 (.a(W83'(0)),                    .y(c0));
  // K02 ELAB port High_conn, cast is an OPERATION OPERAND
  snk2_83 k02 (.a(W83'(0) | 64'h10),           .y(c1));
  // K03 ELAB port High_conn, cast is a USER CALL ARGUMENT     -- fence (b)
  snk2_83 k03 (.a(uf2_83(W83'(0))),            .y(c2));
  // K04 ELAB port High_conn, cast is a SYSTEM CALL ARGUMENT
  snk2_83 k04 (.a($unsigned(W83'(0))),         .y(c3));
  // K05 ELAB port High_conn, cast is a PART-SELECT BOUND      -- fence (c)
  snk2_83 k05 (.a({48'd0, wide[W83'(19):W83'(4)]}), .y(c4));
  // K06 ELAB port High_conn, cast is a BIT-SELECT INDEX
  snk2_83 k06 (.a({63'd0, wide[W83'(3)]}),     .y(c5));
  // K07 cont_assign Rhs                                       -- must stay
  assign c6 = W83'(0);
  // K08 cont_assign Rhs, nested                               -- must stay
  assign c7 = W83'(0) | 64'h20;
  // K09 always_comb statement                                 -- must stay
  always_comb c8 = W83'(0);
  // K10 CASE ITEM in a body always                            -- must stay
  always_comb begin
    case (sel)
      2'd0:    c9 = W83'(0);
      2'd1:    c9 = W83'(1);
      default: c9 = 64'd0;
    endcase
  end
  // K11 INSTANCE PARAMETER ACTUAL                             -- must stay
  snkp2_83 #(.K(W83'(4))) k11 (.a(ca), .y(cb));
  // K12 param init                                            -- must stay
  localparam int Q83 = W83'(7);
  // K13 GEN-SCOPE port High_conn                              -- FOLD?
  for (genvar gi = 0; gi < 2; gi++) begin : gb2
    snk2_83 k13 (.a(W83'(0)), .y(cc));
  end
  // K14 declaration RANGE BOUND                               -- must stay
  logic [W83'(7):0] nar;
  // K15 an INTERFACE instance in the design
  if2_83 k15 ();

  assign cd = {56'd0, nar};
  assign ce = c0^c1^c2^c3^c4^c5^c6^c7^c8^c9^cb^cc^cd^64'(Q83)^k15.q;
  assign wide = ce;
endmodule

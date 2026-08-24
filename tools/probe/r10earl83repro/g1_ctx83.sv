// r10earl83 arm 1 — THE CONTEXT MATRIX.  One and the same written cast,
// `integer'(0)`, placed in every context a written cast can occupy, so that
// GOLDEN says which contexts reduce it and which keep it.  MEASUREMENT ONLY.
module ch83 (input logic [63:0] a, input logic [63:0] b, output logic [63:0] y);
  assign y = a ^ b;
endmodule

module chp83 #(parameter int W = 1) (input logic [63:0] a, output logic [63:0] y);
  assign y = a + W;
endmodule

module gsub83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

function automatic logic [63:0] vf83(input logic [63:0] q);
  return q ^ 64'h5a;
endfunction

module g1_ctx83;
  localparam int P = 5;
  logic [63:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, w9;
  logic [63:0] wa, wb, wc, wd, we, wf;
  logic [63:0] big;
  logic [63:0] r0, r1;

  // C1  ELAB port High_conn, the cast is the WHOLE actual
  ch83 u_hc  (.a(integer'(0)),         .b(64'd1), .y(w0));
  // C2  ELAB port High_conn, the cast is an OPERATION OPERAND
  ch83 u_hco (.a(integer'(0) + 64'd2), .b(64'd1), .y(w1));
  // C3  ELAB port High_conn, the cast is a CONCAT operand
  ch83 u_hcc (.a({32'd0, integer'(0)}), .b(64'd1), .y(w2));
  // C4  ELAB port High_conn, the cast is a BIT-SELECT INDEX
  ch83 u_hci (.a({63'd0, big[integer'(3)]}), .b(64'd1), .y(w3));
  // C5  ELAB port High_conn, the cast is an INDEXED-PART-SELECT base
  ch83 u_hcp (.a({48'd0, big[integer'(4) +: 16]}), .b(64'd1), .y(w4));
  // C6  ELAB port High_conn, the cast is a USER CALL ARGUMENT
  ch83 u_hca (.a(vf83(integer'(0))),   .b(64'd1), .y(w5));
  // C7  ELAB port High_conn, the cast is a SYSTEM CALL ARGUMENT
  ch83 u_hcs (.a({58'd0, 6'($clog2(integer'(16)))}), .b(64'd1), .y(w6));
  // C8  ELAB port High_conn, the cast is a TERNARY arm
  ch83 u_hct (.a(P > 0 ? integer'(0) : integer'(1)), .b(64'd1), .y(w7));
  // C9  ELAB port High_conn, a PART-SELECT BOUND (compilePartSelectRange is
  //     hardcoded Reduce::No — the § genScopeConnPsDirectBoundKeepsRef71 fence)
  ch83 u_hcb (.a({48'd0, big[integer'(19):integer'(4)]}), .b(64'd1), .y(wa));

  // C10 cont_assign Rhs
  assign w8 = integer'(0);
  // C11 cont_assign Rhs, nested in an operation
  assign w9 = integer'(0) + 64'd2;
  // C12 procedural body statement
  always_comb r0 = integer'(0);
  // C13 procedural body statement, nested
  always_comb r1 = integer'(0) + 64'd2;
  // C14 INSTANCE PARAMETER ACTUAL
  chp83 #(.W(integer'(4))) u_pa (.a(wb), .y(wc));
  // C15 param init in the module body
  localparam int Q = integer'(7);
  // C16 a GEN-SCOPE port High_conn
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    gsub83 u_g (.a(integer'(0)), .y(wd));
  end
  // C17 a declaration RANGE BOUND
  logic [integer'(7):0] narrow;

  assign we = {56'd0, narrow};
  assign wf = w0 ^ w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7 ^ w8 ^ w9 ^ wa ^ wc ^ wd ^ we ^ 64'(Q) ^ r0 ^ r1;
  assign big = wf;
endmodule

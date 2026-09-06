// r10earl105 g2 — the READ POSITIONS of a BARE module-parameter reference
// inside an ELABORATED LOOP-GENERATE cont_assign, TOP module.
// PB carries a NON-decimal encoding (BIN) so "golden copies the param_assign
// Rhs verbatim" and "we mint a UINT decimal" are distinguishable.
module g2_pos105 (
  input  logic [7:0]  sig,
  input  logic [15:0] vec,
  output logic [63:0] z
);
  localparam logic [7:0] PB = 8'b1010_0101;   // BIN  — copy-vs-mint visible
  localparam int         PD = 5;              // decimal — the control
  localparam logic [7:0] PR = {8{1'b1}};      // BIN from a replication fold

  for (genvar i = 0; i < 2; i++) begin : gen_l
    logic [63:0] k1, k2, k3, k4, k5, k6, k7, k8, k9, ka, kb, kc;
    // k1 — a PLAIN CONCAT OPERAND under a $bits cast (the head's own shape)
    assign k1 = $bits(k1)'({PB, 1'b1, 1'b1, 1'b1});
    // k2 — the LONE Rhs
    assign k2 = PB;
    // k3 — a BINARY operand beside a signal (nothing folds)
    assign k3 = PB ^ sig;
    // k4 — a REPLICATION COUNT
    assign k4 = {PD{1'b1}} ^ sig;
    // k5 — a BIT-SELECT INDEX on a signal
    assign k5 = vec[PD];
    // k6 — an INDEXED-PART-SELECT base
    assign k6 = vec[PD +: 2];
    // k7 — a part-select BOUND written as an operation
    assign k7 = vec[PD+1 : PD];
    // k8 — a SYSTEM-CALL argument
    assign k8 = $clog2(PB) ^ sig;
    // k9 — a TERNARY condition
    assign k9 = PB[0] ? sig : 8'b0;
    // ka — a concat operand beside a SIGNAL (no whole-Rhs fold available)
    assign ka = {PB, sig};
    // kb — the replication-FOLDED parameter as a plain concat operand
    assign kb = $bits(kb)'({PR, 1'b1});
    // kc — a UNARY operand
    assign kc = (|PB) ^ sig[0];
  end
  assign z = 64'b0;
endmodule

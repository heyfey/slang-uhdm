// pv20.sv — PASS 20 witness: § genProcParamFold on an ASSIGNMENT-LHS select
// index.  With § genProcParamFoldQualCallArg20 landed, work@prim_prince's head
// moves to prim_prince.sv:150:20 —
//     data_state[NumRoundsHalf+k+1] = prim_cipher_pkg::sbox4_64bit(...)
// inside `gen_bwd_pass`'s NESTED `gen_bwd_d64` always_comb, where golden KEEPS
// `ref_obj NumRoundsHalf` and we fold it to 5, while the SAME parameter one
// gen block earlier (:116:67, a NON-nested if-generate process) folds on both
// sides.  Rows V1-V5 (round 1) measured LHS-vs-RHS and bare-vs-operation
// indices EQUAL on both sides in a flat gen scope, so the remaining candidate
// is the NESTED gen block inside a for-generate.
module pv20 #(
    parameter int W = 8,
    parameter int IDX = 3
) (
    input  logic [W-1:0] a,
    output logic [W-1:0] o1,
    output logic [W-1:0] o2,
    output logic [W-1:0] o3
);

  logic [IDX*8+7:0][W-1:0] pk;
  logic [IDX*8+7:0][W-1:0] qk;
  logic [IDX*8+7:0][W-1:0] rk;

  if (W == 8) begin : gi
    always_comb begin : p_if
      pk[IDX]     = a;            // V1 LHS index, BARE param
      pk[IDX+1]   = a;            // V2 LHS index, param in an OPERATION
      o1          = pk[IDX+2];    // V3 RHS index, param in an OPERATION
    end
  end

  for (genvar g = 0; g < 2; g++) begin : gf
    always_comb begin : p_for
      qk[IDX+g]   = a;            // V5 LHS index, param + GENVAR, flat
    end
  end

  // V6/V7 — the exact prim_prince gen_bwd_pass shape: a for-generate whose
  // body declares a local, holds a cont_assign, and NESTS an if-generate whose
  // always_comb writes `rk[IDX+g]`.
  for (genvar g = 0; g < 2; g++) begin : gn
    logic [W-1:0] bwd;
    assign bwd = qk[IDX+g];
    if (W == 8) begin : gn_w
      always_comb begin : p_nest
        rk[IDX+g]  = bwd;         // V6 LHS index, param + genvar, NESTED
      end
    end
  end

  // V8 — nesting WITHOUT a loop: an if-generate inside an if-generate.
  logic [IDX*8+7:0][W-1:0] sk;
  if (W == 8) begin : ga
    if (IDX == 3) begin : ga_b
      always_comb begin : p_aa
        sk[IDX] = a;              // V8 LHS index, bare param, if-in-if
      end
    end
  end

  assign o2 = rk[0] ^ sk[0];
  assign o3 = pk[0];

endmodule

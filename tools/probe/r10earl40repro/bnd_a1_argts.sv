// r10earl39 — THE WITNESS AND ITS AXES.
//
// ONE question: when does golden hang a `ref_typespec` naming the CALLEE'S
// FORMAL typespec on a call ACTUAL, and when does it leave the actual bare?
//
// The Earlgrey head is `prim_prince`: an `always_comb` written inside a
// GENERATE BRANCH (`if (DataWidth == 64) begin : gen_fwd_d64`) whose body
// calls `prim_cipher_pkg::prince_mult_prime_64bit(data_state_round)`.  Golden's
// DEF-view (`uhdmallModules`) actual is BARE; ours carried the formal's
// typespec.  The already-implemented rule bares a MODULE-level process
// (`!inProcessEmit`) and an ELAB gen-scope process (`!inGenScopeProc`); the
// DEF-view generate-BRANCH process emitter is a third emitter and was never
// covered.
//
// The axes crossed below:
//   CALL SITE      module-level process / gen-for gen-scope process /
//                  gen-IF-branch process / gen-ELSE-branch process /
//                  gen-CASE-item process / nested (gen-for > gen-if) process /
//                  module-level cont-assign / gen-branch cont-assign /
//                  function body / localparam initializer
//   PROCESS KIND   always_comb / always_ff / always_latch / always @* / initial
//   ACTUAL KIND    plain var ref / gen-block-LOCAL var ref / bit-select /
//                  part-select / constant / operation / nested call / param ref
//   FORMAL TYPE    vector (`logic [7:0]`) / predefined int (`int`) / typedef
//   TARGET SCOPE   module var / gen-block-local var / function local / formal
//
// The DEF view (allModules) is the one under test; the ELAB view (topModules)
// is the control that must not move.
package pk39;
  function automatic logic [7:0] fv39(logic [7:0] a);
    return a ^ 8'ha;
  endfunction
  function automatic logic [7:0] fv2_39(logic [7:0] a, logic [7:0] b);
    return a ^ b;
  endfunction
  function automatic int fi39(int a);
    return a + 1;
  endfunction
  typedef logic [7:0] byte39_t;
  function automatic byte39_t ft39(byte39_t a);
    return ~a;
  endfunction
endpackage

module a1_argts #(
    parameter int W39 = 8,
    parameter int MODE39 = 1
) (
    input  logic [7:0] in39,
    input  logic       clk39,
    output logic [7:0] out39
);

  localparam logic [7:0] K39 = 8'h5a;

  logic [7:0] mv39;          // module-level var
  logic [7:0] mv2_39;
  logic [7:0] mvarr39 [0:3];
  logic [15:0] wide39;

  // ---------------------------------------------------------------- CELL m1
  // MODULE-LEVEL process. Already bare on both sides (!inProcessEmit).
  always_comb begin : p_m1
    mv39 = pk39::fv39(in39);
  end

  // ---------------------------------------------------------------- CELL m2
  // MODULE-LEVEL cont-assign. Golden STAMPS here (the control that must not
  // move): a cont-assign is not a procedural context.
  assign mv2_39 = pk39::fv39(in39);

  // ---------------------------------------------------------------- CELL m3
  // MODULE-LEVEL process, BIT-SELECT actual.
  always_comb begin : p_m3
    wide39[7:0] = pk39::fv39(mvarr39[1]);
  end

  // ---------------------------------------------------------------- CELL g1
  // GEN-FOR gen-scope process. Bare on both sides already (!inGenScopeProc) —
  // Scr1SvTests' scr1_memory_tb_axi is the corpus measurement.
  for (genvar i39 = 0; i39 < 2; i39++) begin : gen_g1
    logic [7:0] gl39;        // gen-block LOCAL
    always_comb begin : p_g1
      gl39 = pk39::fv39(in39);
    end
  end

  // ---------------------------------------------------------------- CELL g2
  // GEN-IF BRANCH process — THE HEAD. `always_comb` inside `if (...) begin`.
  // Actual is a GEN-BLOCK-LOCAL var (prim_prince's data_state_round).
  if (MODE39 == 1) begin : gen_g2
    logic [7:0] gl2_39;
    always_comb begin : p_g2
      gl2_39 = pk39::fv39(in39);
      gl2_39 = pk39::fv39(gl2_39);          // gen-local actual
      gl2_39 = pk39::fv2_39(gl2_39, in39);  // two actuals
    end
  end
  else begin : gen_g2e
    // GEN-ELSE BRANCH process — the same head on the untaken arm.
    logic [7:0] gl2e_39;
    always_comb begin : p_g2e
      gl2e_39 = pk39::fv39(in39);
    end
  end

  // ---------------------------------------------------------------- CELL g3
  // NESTED: gen-for > gen-if branch process (prim_prince's exact shape).
  for (genvar k39 = 0; k39 < 2; k39++) begin : gen_g3
    logic [7:0] gl3_39;
    if (MODE39 == 1) begin : gen_g3a
      always_comb begin : p_g3a
        gl3_39 = pk39::fv39(in39);
        gl3_39 = pk39::fv39(gl3_39);
      end
    end
    else begin : gen_g3b
      always_comb begin : p_g3b
        gl3_39 = pk39::fv39(in39);
      end
    end
  end

  // ---------------------------------------------------------------- CELL g4
  // GEN-CASE ITEM process.
  case (MODE39)
    1: begin : gen_g4a
      logic [7:0] gl4_39;
      always_comb begin : p_g4a
        gl4_39 = pk39::fv39(in39);
      end
    end
    default: begin : gen_g4b
      logic [7:0] gl4b_39;
      always_comb begin : p_g4b
        gl4b_39 = pk39::fv39(in39);
      end
    end
  endcase

  // ---------------------------------------------------------------- CELL g5
  // GEN-IF branch, EVERY process kind, plus every ACTUAL kind.
  if (MODE39 == 1) begin : gen_g5
    logic [7:0] gl5a_39, gl5b_39, gl5c_39, gl5d_39, gl5e_39;
    logic [7:0] gl5arr_39 [0:3];
    logic [15:0] gl5w_39;
    int gl5i_39;
    pk39::byte39_t gl5t_39;
    always_ff @(posedge clk39) begin : p_g5ff
      gl5a_39 <= pk39::fv39(in39);
    end
    always_latch begin : p_g5lat
      if (clk39) gl5b_39 = pk39::fv39(in39);
    end
    always @* begin : p_g5star
      gl5c_39 = pk39::fv39(in39);
    end
    initial begin : p_g5init
      gl5d_39 = pk39::fv39(8'h11);          // CONSTANT actual
    end
    always_comb begin : p_g5kinds
      gl5e_39 = pk39::fv39(gl5arr_39[2]);   // bit-select actual
      gl5e_39 = pk39::fv39(gl5w_39[7:0]);   // part-select actual
      gl5e_39 = pk39::fv39(in39 ^ K39);     // OPERATION actual
      gl5e_39 = pk39::fv39(pk39::fv39(in39));  // NESTED CALL actual
      gl5e_39 = pk39::fv39(K39);            // PARAM(localparam) actual
      gl5i_39 = pk39::fi39(3);              // PREDEFINED-INT formal
      gl5t_39 = pk39::ft39(gl5t_39);        // TYPEDEF formal
    end
  end

  // ---------------------------------------------------------------- CELL g6
  // GEN-IF branch CONT-ASSIGN (not a process). Golden's own behaviour here is
  // MIXED by actual kind (prim_present) — this cell must not move.
  if (MODE39 == 1) begin : gen_g6
    logic [7:0] gl6_39;
    assign gl6_39 = pk39::fv39(in39);
  end

  // ---------------------------------------------------------------- CELL f1
  // FUNCTION BODY call (module-scope function). Must not move.
  function automatic logic [7:0] mf39(logic [7:0] a);
    logic [7:0] t;
    t = pk39::fv39(a);
    return t;
  endfunction

  // ---------------------------------------------------------------- CELL f2
  // LOCALPARAM INITIALIZER call. Must not move.
  localparam logic [7:0] LP39 = pk39::fv39(8'h22);

  assign out39 = mv39 ^ mv2_39 ^ mf39(in39) ^ LP39 ^ wide39[7:0];

endmodule

// The DEF-only control: a module that is never instantiated still gets an
// allModules listing, and § defOnlyNoArgTs already bares every actual there.
module a1_argts_top;
  logic [7:0] i0, o0;
  logic c0;
  a1_argts #(.W39(8), .MODE39(1)) u1 (.in39(i0), .clk39(c0), .out39(o0));
endmodule

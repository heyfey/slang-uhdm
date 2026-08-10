// pn20.sv — PASS 20 witness for the gen-scope cont_assign RHS BIND rule
// (prim_prince residue (1)).  The current emitter binds a for-generate CA's
// RHS ref only when the symbol is written by a DIRECT member of the same gen
// block (blkWrites).  prim_prince's `data_state_round` is declared in the
// for-generate body but written inside a NESTED if-generate, so it is not in
// blkWrites and our ref comes out unbound where golden binds it.
//
// The cases this file measures, all inside ONE for-generate body:
//   A  gen-local declared, written in a NESTED gen block   -> ?
//   B  gen-local declared, written by a DIRECT process     -> binds today
//   C  gen-local declared, NEVER written                   -> ?
//   E  MODULE-level signal, only READ here                 -> unbound today
module pn20 (
    input  logic [3:0] a,
    output logic [3:0] ya,
    output logic [3:0] yb,
    output logic [3:0] yc,
    output logic [3:0] ye
);

  logic [3:0] mod_readonly;  // E: module-level, driven OUTSIDE the gen block

  assign mod_readonly = ~a;

  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:0] loc_nested;    // A
    if (k == 0) begin : gi
      always_comb loc_nested = a;
    end
    logic [3:0] loc_direct;    // B
    always_comb loc_direct = a;
    logic [3:0] loc_undriven;  // C

    assign ya = loc_nested;
    assign yb = loc_direct;
    assign yc = loc_undriven;
    assign ye = mod_readonly;
  end

endmodule

// pq20.sv — PASS 20 witness for the REACH of § genCaDirectRefBindsGenLocal.
// That law (r10earl8, tk.sv) says an ELAB gen-scope cont_assign binds a
// gen-LOCAL variable ref only when the ref IS the WHOLE Lhs or the WHOLE Rhs,
// and explicitly NOT "inside an operation or a select".  tk row B measured
// `assign vb_sbox = ~vb_xor;` unbound — but that row's vb_xor is ALSO an
// ANCESTOR-scope local (the assign sits in a nested gen_b_w), and tk row D2
// separately proved an ancestor-scope whole-Rhs ref is unbound.  So the
// "inside an operation" clause was never isolated.
//
// Rows here, all in ONE for-generate body (SAME scope unless marked):
//   F  RHS operand of a binary op, same-scope gen-local
//   G  RHS bit-select OF a same-scope gen-local
//   H  RHS index that IS a same-scope gen-local
//   I  RHS concat operand, same-scope gen-local
//   J  RHS operand of a binary op, ANCESTOR-scope gen-local (nested block)
//   K  RHS operand of a binary op, MODULE-level signal
module pq20 (
    input  logic [3:0] a,
    output logic [3:0] y
);

  logic [3:0] mod_readonly;
  logic [3:0] tab [4];
  assign mod_readonly = ~a;

  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:0] loc_nested;
    if (k == 0) begin : gi
      always_comb loc_nested = a;
    end
    logic [3:0] loc_direct;
    always_comb loc_direct = a;
    logic [1:0] loc_idx;
    always_comb loc_idx = a[1:0];

    logic [3:0] f_op;
    assign f_op = loc_nested ^ 4'h5;              // F

    logic       g_sel;
    assign g_sel = loc_direct[2];                 // G

    logic [3:0] h_idx;
    assign h_idx = tab[loc_idx];                  // H

    logic [3:0] i_cat;
    assign i_cat = {loc_direct[1:0], loc_nested[1:0]};  // I

    logic [3:0] k_mod;
    assign k_mod = mod_readonly ^ 4'h5;           // K

    if (k == 0) begin : gj
      logic [3:0] j_anc;
      assign j_anc = loc_direct ^ 4'h5;           // J (ancestor-scope read)
    end

    assign y = f_op ^ h_idx ^ i_cat ^ k_mod ^ {3'b0, g_sel};
  end

endmodule

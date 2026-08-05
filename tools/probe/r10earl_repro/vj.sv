// vj.sv — pass 11.  The func-call-ARGUMENT ref_typespec residue the pass-3
// README ranked (1) and which is now the head of the three aes_sbox_canright*
// AllModules entries: golden's `aes_inverse_gf2p8(data_basis_x)` argument ref
// carries NO ref_typespec, ours does — while vi.sv shows golden DOES carry one
// on a PORT argument (`pick(AVEC, sel_i)`).  One row per argument kind.
module vj (
  input  logic [7:0] p_i,          // A  input port
  output logic [7:0] o_a, o_b, o_c, o_d, o_e
);
  logic [7:0] n_net;               // B  module-internal net
  logic [7:0] v_var;               // C  module-internal var (procedural LHS)
  logic [7:0] arr [2];             // D  internal unpacked array element

  function automatic logic [7:0] thru(input logic [7:0] v);
    thru = v;
  endfunction

  assign n_net = p_i ^ 8'h11;
  always_comb v_var = p_i ^ 8'h22;

  assign o_a = thru(p_i);          // A
  assign o_b = thru(n_net);        // B
  assign o_c = thru(v_var);        // C
  assign o_d = thru(arr[0]);       // D
  assign o_e = thru(p_i ^ n_net);  // E  an operation argument
endmodule

module vjtop;
  logic [7:0] p, a, b, c, d, e;
  vj u (.p_i(p), .o_a(a), .o_b(b), .o_c(c), .o_d(d), .o_e(e));
endmodule

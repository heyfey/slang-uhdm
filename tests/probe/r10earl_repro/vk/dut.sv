// vk.sv — pass 11.  vj proved golden DOES carry a ref_typespec on every
// ordinary func-call argument and vj is cmp-EQUAL, so the aes_sbox_canright
// residue (golden <null> vs our ref_typespec on `aes_inverse_gf2p8(
// data_basis_x)`) is keyed on something else in that file.  Two spellings
// differ from vj and are tested here, separately and together:
//   * the function FORMAL is written WITHOUT a direction keyword
//     (`function automatic logic [7:0] f(logic [7:0] gamma);`)
//   * the actual is one of TWO DECLARATORS in one declaration
//     (`logic [7:0] data_basis_x, data_inverse;`)
module vk (
  input  logic [7:0] p_i,
  output logic [7:0] o_f, o_g, o_h, o_i
);
  logic [7:0] n1;                  // single declarator
  logic [7:0] d1, d2;              // TWO declarators in one declaration

  function automatic logic [7:0] no_dir(logic [7:0] gamma);
    no_dir = gamma;
  endfunction
  function automatic logic [7:0] with_dir(input logic [7:0] gamma);
    with_dir = gamma;
  endfunction

  assign n1 = p_i ^ 8'h11;
  assign d1 = p_i ^ 8'h22;

  assign o_f = no_dir(n1);         // F  no-direction formal, single declarator
  assign o_g = with_dir(d1);       // G  direction formal, two-declarator actual
  assign o_h = no_dir(d1);         // H  both (the aes_sbox_canright spelling)
  assign o_i = no_dir(p_i);        // I  no-direction formal, PORT actual
  assign d2  = 8'h0;
endmodule

module vktop;
  logic [7:0] p, f, g, h, i;
  vk u (.p_i(p), .o_f(f), .o_g(g), .o_h(h), .o_i(i));
endmodule

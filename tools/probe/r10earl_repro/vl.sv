// vl.sv — pass 11.  vj/vk are cmp-EQUAL, so the aes_sbox_canright residue
// (golden <null> vs our ref_typespec on the `aes_inverse_gf2p8(data_basis_x)`
// argument) is not about the argument kind, the formal's direction keyword or
// the two-declarator declaration.  What is left: all three aes_sbox_canright*
// modules are DEF-ONLY entries — instantiated only inside a generate branch
// that is NOT taken (§ uninstDefPortedAdmit, pass 3), so their AllModules
// listing comes from slang's createDefault instance, not from an elaborated
// one.  vl builds exactly that: the same body as vj row B, in a module nobody
// elaborates.
module vlchild (
  input  logic [7:0] p_i,
  output logic [7:0] o_o
);
  logic [7:0] mid, unusedd;

  function automatic logic [7:0] finv(logic [7:0] gamma);
    logic [7:0] delta;
    delta = gamma ^ 8'h5a;
    return delta;
  endfunction

  assign mid = p_i ^ 8'h11;
  assign o_o = finv(mid);
  assign unusedd = 8'h0;
endmodule

// the control: the SAME body in a module that IS elaborated
module vlused (
  input  logic [7:0] p_i,
  output logic [7:0] o_o
);
  logic [7:0] mid, unusedd;

  function automatic logic [7:0] finv(logic [7:0] gamma);
    logic [7:0] delta;
    delta = gamma ^ 8'h5a;
    return delta;
  endfunction

  assign mid = p_i ^ 8'h11;
  assign o_o = finv(mid);
  assign unusedd = 8'h0;
endmodule

module vltop #(
  parameter int Impl = 0
) (
  input  logic [7:0] p_i,
  output logic [7:0] o_o
);
  if (Impl == 1) begin : gen_never
    vlchild u_c (.p_i(p_i), .o_o(o_o));
  end
  else begin : gen_always
    vlused u_u (.p_i(p_i), .o_o(o_o));
  end
endmodule

// b3 — a NAMED element carrying packed dims takes the OTHER element route
// (the packed_array_typespec built with mkP, which folds unconditionally).
// The implementer's "named element" control had no packed dim, so this cell
// was never tested.  It must not move AWAY; if golden keeps it symbolic it is
// a residue, not a regression.
module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  typedef logic [1:0] vec_t;
  // named element, LITERAL packed dim
  typedef vec_t [3:0] nml_t [DEPTH];
  // named element, SYMBOLIC packed dim  -> the mkP route
  typedef vec_t [N-1:0] nms_t [DEPTH];
  // named element, no packed dim (the implementer's control)
  typedef vec_t nmp_t [DEPTH];
  // an inline element beside them (the law's own cell)
  typedef logic [N-1:0] inl_t [DEPTH];

  nml_t a_nml; nms_t a_nms; nmp_t a_nmp; inl_t a_inl;
  assign o = a_nml[0][0][0] ^ a_nms[0][0][0] ^ a_nmp[0][0] ^ a_inl[0][0];
endmodule

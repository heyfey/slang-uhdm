// r10earl77 -- the NEGATIVE control for § pkgScopedPortAnyDirVar77: BODY
// declarations of a scoped package typedef in every keyword form, plus an
// INTERFACE and a PROGRAM with the same port shape.  The law is PORT-BACKED
// only; nothing in this arm may move.  MEASUREMENT ONLY.
package r77;
  typedef logic [7:0] v8_t;
endpackage

interface ifr77 (
  input  r77::v8_t if_in,
  output r77::v8_t if_out
);
  r77::v8_t   if_body_plain;
  wire  r77::v8_t if_body_wire;
  var   r77::v8_t if_body_var;
endinterface

module body77 (
  input  r77::v8_t b_in,
  output r77::v8_t b_out
);
  r77::v8_t       b_plain;
  wire r77::v8_t  b_wire;
  var  r77::v8_t  b_var;
  logic [7:0]     b_logic;
  assign b_wire = b_in;
  assign b_out  = b_wire;
endmodule

program prg77 (
  input  r77::v8_t p_in,
  output r77::v8_t p_out
);
  r77::v8_t p_body;
endprogram

module topr77;
  logic [7:0] a, b, c, d;
  body77 u_b (.b_in(a), .b_out(b));
  ifr77  u_if (.if_in(c), .if_out(d));
endmodule

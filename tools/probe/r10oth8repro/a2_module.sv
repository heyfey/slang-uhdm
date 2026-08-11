// r10oth8 arm a2 — the MODULE-SCOPE SIBLING of a1, cell for cell, same names.
// This is the arm that decides whether the already-implemented module-scope
// rule (`src/TypeEmit.cpp`, grep `Signedness rides the ARRAY here, not the
// element (measured)`) is ACTUALLY CORRECT against golden, or whether it is a
// second latent defect.  `rand` has no meaning outside a class, so the a02
// cell is the same declaration as a01 here and both are listed for symmetry.
module a2_top;
  byte              a01_dyn_byte[];
  byte              a02_dyn_byte_norand[];
  byte unsigned     a03_dyn_byteu[];
  bit               a04_dyn_bit[];
  logic             a05_dyn_logic[];
  int               a06_dyn_int[];
  shortint          a07_dyn_shortint[];
  longint           a08_dyn_longint[];
  integer           a09_dyn_integer[];
  byte              a10_q_byte[$];
  byte              a11_as_byte[string];
  byte              a12_fix_byte[4];
  byte signed       a13_dyn_bytes[];
  int unsigned      a14_dyn_intu[];
  bit [7:0]         a15_dyn_vec[];
  bit signed [7:0]  a16_dyn_vecs[];
  byte              a17_fix_dyn[4][];
  byte              a18_dyn_fix[][4];
  int               a19_q_int[$];
  int               a20_as_int[string];
  string            a21_dyn_string[];
  real              a22_dyn_real[];
endmodule

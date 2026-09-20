// g3 - LAW C: the INTERFACE def road.  It calls netTypeFor WITHOUT the def-view
// flag, so a NET KEYWORD wins over the typedef there; the module def road has
// answered the typedef since pass 64 / r10v225.  ifx is INSTANTIATED, ifu is
// the UNINSTANTIATED twin (r10v225 R1 -- golden stamps nothing there).
interface ifx ();
  typedef logic [1:0] v_t;
  typedef reg  [1:0]  r_t;
  typedef v_t [1:0]   w_t;
  v_t   n0;
  wire  v_t n1;
  wand  v_t n2;
  wor   v_t n3;
  tri   v_t n4;
  wire  v_t n5 [2];
  wand  v_t n6 [2];
  wire  r_t n7;
  wire  w_t n8;
  wire  logic [1:0] n9;
  wand  logic [1:0] n10;
endinterface
interface ifu ();
  typedef logic [1:0] uv_t;
  typedef uv_t [1:0]  uw_t;
  uv_t  q0;
  wire  uv_t q1;
  wand  uv_t q2;
  wire  uv_t q3 [2];
  wire  uw_t q4;
  wire  logic [1:0] q5;
endinterface
module dut (output logic [1:0] o);
  ifx u0 ();
  assign o = u0.n0 | u0.n1 | u0.n2 | u0.n3 | u0.n4 | u0.n5[0] | u0.n6[0] |
             u0.n7 | u0.n8[0] | u0.n9 | u0.n10;
endmodule

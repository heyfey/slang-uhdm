// v1 - NET KEYWORDS other than wire, under an unpacked-array typedef and under
// a declarator unpacked dim.  The law fires BEFORE netTypeFor's netKind switch.
module dut #(parameter int unsigned N = 2, parameter int unsigned D = 4)
  (output logic [N-1:0] o);
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;
  typedef reg   [N-1:0] r_t [D];

  wand  v_t nd [2];      // wand + packed typedef + declarator dim
  wor   v_t nr [2];      // wor  + packed typedef + declarator dim
  tri   v_t nt [2];      // tri  + packed typedef + declarator dim
  wand  a_t wda;         // wand + unpacked-array typedef
  wor   a_t wra;         // wor  + unpacked-array typedef
  tri   a_t tra;         // tri  + unpacked-array typedef
  wire  r_t wrr;         // wire + REG-element unpacked-array typedef
  wand  v_t ndp;         // wand + packed typedef, NO dim (control)
  wand  [N-1:0] wnp [D]; // wand + declarator dim, NO typedef (control)

  assign o = nd[0] | nr[0] | nt[0] | wda[0] | wra[0] | tra[0] | wrr[0] |
             ndp | wnp[0];
endmodule

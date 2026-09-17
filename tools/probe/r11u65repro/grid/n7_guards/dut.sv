// r11u65 n7 — THE GUARD CELLS the law must NOT move: a TYPE PARAMETER (§
// namedTypeLeafNoNetType32 says NO net type in every cell, `T x` and `T x [1:0]`
// alike), an ENUM or STRUCT leaf, and a SCOPED package name carrying a
// DECLARATION unpacked dimension.  Plus the two shapes that have no cell yet:
// an explicit NET KEYWORD in front of an unpacked-array typedef, and an alias
// of an alias.
package pk7;
  typedef logic [1:0] pv_t;
  typedef logic [1:0] pa_t [4];
  typedef struct packed { logic [1:0] f; } ps_t;
endpackage

module sub #(
    parameter type T  = logic [1:0],
    parameter type TA = logic [1:0]
) (output logic [1:0] o);
  T  t1;          // type parameter, no dim
  T  t2 [2];      // type parameter + DECLARATION unpacked dim
  TA t3;          // type parameter bound to an UNPACKED-ARRAY typedef
  assign o = t1 | t2[0] | t3[0];
endmodule

module dut (output logic [1:0] o);
  typedef logic [1:0] a_t [4];
  typedef logic [1:0] v_t;
  typedef v_t         v2_t;          // alias OF an alias
  typedef enum logic [1:0] { E0, E1 } en_t;
  typedef struct packed { logic [1:0] f; } sp_t;

  pk7::pv_t  sd  [4];     // SCOPED packed typedef + declaration dim
  pk7::pa_t  sq  [2];     // SCOPED unpacked typedef + declaration dim
  pk7::ps_t  ss  [2];     // SCOPED struct typedef + declaration dim
  en_t       ed  [4];     // local ENUM typedef + declaration dim
  sp_t       sdl [4];     // local STRUCT typedef + declaration dim
  v2_t       ch  [2];     // alias-of-alias + declaration dim
  wire a_t   wa;          // explicit NET KEYWORD + unpacked-array typedef
  wire v_t   wv [2];      // explicit NET KEYWORD + packed typedef + decl dim

  logic [1:0] so1, so2;
  sub #(.T(logic [1:0]), .TA(a_t)) u1 (.o(so1));
  sub #(.T(pk7::pv_t),   .TA(a_t)) u2 (.o(so2));

  assign wa[0] = 2'b0;
  assign wv[0] = 2'b0;
  assign o = sd[0] | sq[0][0] | ss[0].f | {2{ed[0][0]}} | sdl[0].f | ch[0] |
             wa[0] | wv[0] | so1 | so2;
endmodule

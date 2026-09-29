// r11u218 decode (no law written; the face named pkgQualFwdRefSpan218 in the README) — f01_untyped_enum_member: a later package untyped enum constant as a pattern member value, the pattern typed by the later package (FuncStructVal 106)
package ap;
  localparam bp::q_t Q = '{a: 1, n: bp::E_C};
endpackage
package bp;
  typedef enum { E_A, E_B, E_C } u_e;
  typedef enum logic [1:0] { T_A, T_B } t_e;
  typedef struct { int a; u_e n; } q_t;
  typedef struct { int a; t_e n; } r_t;
endpackage
module top(output int o);
  assign o = 1;
endmodule

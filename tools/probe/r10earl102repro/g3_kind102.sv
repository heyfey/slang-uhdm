// r10earl102 g3_kind102 -- DECLARATION KINDS carrying the same `[0:N-1]`
// unpacked dimension in a package, plus the SIZE-form `[N]` control that
// golden is MEASURED to leave symbolic (aes_sbox_canright_pkg.sv:87
// `parameter logic [7:0] A2X [8]`), and a two-dimensional case.
package p3k102;
  parameter int KN = 2;
  typedef logic [7:0] b_t;

  parameter  int   K_PARAM   [0:KN-1] = '{1, 0};              // parameter
  localparam int   K_LOCAL   [0:KN-1] = '{1, 0};              // localparam
  parameter  b_t   K_TYPED   [0:KN-1] = '{8'h1, 8'h0};        // typed parameter
  parameter  int   K_DEFAULT [0:KN-1] = '{default: 7};        // aggregate default
  parameter  int   K_SIZE    [KN]     = '{1, 0};              // SIZE form control
  parameter  int   K_LIT     [0:1]    = '{1, 0};              // literal control
  parameter  int   K_2D      [0:KN-1][0:KN-1] = '{'{1,0},'{0,1}}; // two dims
endpackage

module m3k102
  import p3k102::*;
(
  output int o
);
  assign o = K_PARAM[0] + K_LOCAL[0] + int'(K_TYPED[0]) + K_DEFAULT[0] +
             K_SIZE[0] + K_LIT[0] + K_2D[0][0];
endmodule

module g3_kind102 (output int o);
  m3k102 u (.o(o));
endmodule

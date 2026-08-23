// a2: typed / ranged / signed declarations with the SAME unsized based inits
package a2_pkg;
  parameter int          T_INT   = 'hf000000;
  parameter logic [7:0]  T_LOG   = 'h1a;
  parameter bit signed [15:0] T_BSIG = 'sh1;
  parameter byte         T_BYTE  = 'h7;
  parameter string       T_STR   = "abc";
  parameter signed       T_SIGN  = 'h5;
  parameter unsigned     T_UNS   = 'h5;
  parameter [3:0]        T_RNG   = 'hf;
  parameter integer      T_INTG  = 'b1010;
  localparam int         T_LINT  = 'o17;
endpackage
module a2_top;
  a2_use u1();
endmodule
module a2_use;
  import a2_pkg::*;
  initial $display(T_INT, T_LOG, T_RNG);
endmodule

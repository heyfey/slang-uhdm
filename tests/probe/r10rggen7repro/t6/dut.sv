// r10rggen7 t6: what ConstType does the ELABORATED param_assign Rhs of an
// ENUM-TYPED parameter take when its value is an enum-constant reference?
// Four enum members in two enums: implicit-valued (no initializer) vs
// explicitly sized-binary-valued, each read as a DEFAULT and as an OVERRIDE.
// Rggen: rggen_bit_field PRECEDENCE_ACCESS/SW_READ_ACTION (541 vectors).
package t6_pkg;
  typedef enum logic       { T6_A, T6_B } t6_imp_e;          // implicit 0,1
  typedef enum logic [1:0] { T6_X = 2'b00, T6_Y = 2'b10 } t6_exp_e;
  typedef enum logic [3:0] { T6_P = 4'd3, T6_Q = 4'h5 } t6_dec_e;
endpackage

module t6_child
  import t6_pkg::*;
#(
  parameter t6_imp_e IMP = T6_A,
  parameter t6_exp_e EXP = T6_X,
  parameter t6_dec_e DEC = T6_P,
  parameter bit [3:0] PLAIN = '0
)(
  output logic o
);
  assign o = |{IMP, EXP, DEC, PLAIN};
endmodule

module t6
  import t6_pkg::*;
(
  output logic o_def,
  output logic o_ovr
);
  t6_child u_def (.o(o_def));
  t6_child #(
    .IMP    (T6_B),
    .EXP    (T6_Y),
    .DEC    (T6_Q),
    .PLAIN  (4'b0011)
  ) u_ovr (.o(o_ovr));
endmodule

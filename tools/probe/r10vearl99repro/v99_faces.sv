// r10v99 ADVERSARIAL -- every unbased-literal face inside a cont_assign
// ternary chain: '1 '0 'x 'z x tagged / positional / default: / nested /
// replicated members.
package pf99;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; } p2_t;
  typedef struct packed { logic [2:0] a3; logic [4:0] b5; logic [7:0] c8; } p3_t;
  typedef struct packed { p2_t inner; logic [7:0] c8; } nst_t;
  typedef struct packed { logic [3:0] r0; logic [3:0] r1; logic [3:0] r2; logic [3:0] r3; } rep_t;
endpackage
module v99_faces (input logic s0, input logic s1,
                  output pf99::p2_t f_one, output pf99::p2_t f_zero,
                  output pf99::p2_t f_x,   output pf99::p2_t f_z,
                  output pf99::p3_t f_def, output pf99::p3_t f_mix,
                  output pf99::p2_t f_pos, output pf99::nst_t f_nest,
                  output pf99::rep_t f_rep, output pf99::p2_t f_deep,
                  output pf99::p2_t f_cond, output pf99::p2_t f_arith);
  // tagged, each face, one ternary
  assign f_one  = s0 ? '{ a3 : '1, b5 : '1 } : '{ a3 : 3'd1, b5 : 5'd2 };
  assign f_zero = s0 ? '{ a3 : '0, b5 : '0 } : '{ a3 : 3'd1, b5 : 5'd2 };
  assign f_x    = s0 ? '{ a3 : 'x, b5 : 'x } : '{ a3 : 3'd1, b5 : 5'd2 };
  assign f_z    = s0 ? '{ a3 : 'z, b5 : 'z } : '{ a3 : 3'd1, b5 : 5'd2 };
  // default: fill in an arm
  assign f_def  = s0 ? '{ default : '1 } : '{ default : '0 };
  // mixed named + default in an arm
  assign f_mix  = s0 ? '{ b5 : '1, default : '0 } : '{ a3 : 3'd7, default : '1 };
  // positional members in an arm
  assign f_pos  = s0 ? '{ '1, '0 } : '{ 3'd2, 5'd3 };
  // a nested pattern member in an arm
  assign f_nest = s0 ? '{ inner : '{ a3 : '1, b5 : '0 }, c8 : '1 }
                     : '{ inner : '{ a3 : 3'd1, b5 : 5'd2 }, c8 : 8'h11 };
  // replicated member value in an arm
  assign f_rep  = s0 ? '{ default : '1 } : '{ r0 : 4'h1, r1 : 4'h2, r2 : 4'h3, r3 : 4'h4 };
  // nested ternary chain, three deep
  assign f_deep = s0 ? '{ a3 : 3'd1, b5 : 5'd1 }
                : s1 ? '{ a3 : '1, b5 : '1 }
                : s0 & s1 ? '{ a3 : '0, b5 : '0 }
                : '{ a3 : '1, b5 : '0 };
  // pattern in the CONDITION position must NOT be flattened
  assign f_cond = (pf99::p2_t'('{ a3 : '1, b5 : '0 }) != 8'h00) ? '{ a3 : 3'd1, b5 : 5'd1 }
                                                               : '{ a3 : 3'd2, b5 : 5'd2 };
  // pattern under an arm's ARITHMETIC must NOT be flattened
  assign f_arith = s0 ? (pf99::p2_t'('{ a3 : '1, b5 : '0 }) | 8'h01)
                      : '{ a3 : 3'd1, b5 : 5'd1 };
endmodule

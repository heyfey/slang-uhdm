// r11u64 GRID g1 — MEMBER WIDTH CLASSES x UNSIZED FORMS on the cont_assign
// road (an assignment pattern as the Rhs of a cont_assign onto a struct
// VARIABLE / NET).  Operand[0] of every pattern is deliberately UNVALUABLE (a
// part-select of a port) so that Surelog's expandPatternAssignment adjustOpSize
// walk stamps operand[0] and STOPS — which leaves every other operand carrying
// the width flattenPatternAssignments gave it.  That is the field under test.
package q64;
  typedef struct packed { logic [31:0] XLEN; logic [31:0] TID; } cfg_t;
  function automatic cfg_t bld(); cfg_t c; c.XLEN = 32'd64; c.TID = 32'd3; return c; endfunction
  localparam cfg_t CFG = bld();
  localparam int PW = 5;
  typedef enum logic [3:0] { E_A = 4'd1, E_B = 4'd2 } e_t;
  typedef struct packed { logic [2:0] n; logic [4:0] m; } sub_t;
endpackage

// c01/c02/c03/c04 — a MODULE-PARAMETER bound, every unsized form
module c1 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [V-1:0] w0; logic [V-1:0] w1; logic [V-1:0] wx; logic [V-1:0] wz;
  } t_t;
  t_t v;
  assign v = '{w0: pa[V-1:0], w1: '1, wx: 'x, wz: 'z};
  assign o = 64'(v);
endmodule

// c05/c06/c07/c08 — LITERAL-bound / bare logic / int members (the controls)
module c2 (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [7:0] l0; logic [7:0] l1; logic b; int i;
  } t_t;
  t_t v;
  assign v = '{l0: pa[7:0], l1: '1, b: '0, i: '0};
  assign o = 64'(v);
endmodule

// c09 — THE WITNESS FACE: a bound reached through a PACKAGE struct localparam
module c3 (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [q64::CFG.XLEN-1:0] a; logic [q64::CFG.TID-1:0] t;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], t: '0};
  assign o = 64'(v);
endmodule

// c10/c11 — a MODULE localparam bound and a PACKAGE localparam bound
module c4 (input logic [63:0] pa, output logic [63:0] o);
  localparam int LP = 6;
  typedef struct packed {
    logic [LP-1:0] a; logic [LP-1:0] b; logic [q64::PW-1:0] c;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], b: '0, c: '0};
  assign o = 64'(v);
endmodule

// c12 — a $bits()-bound member
module c5 (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [3:0] a; logic [$bits(q64::sub_t)-1:0] b;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], b: '0};
  assign o = 64'(v);
endmodule

// c14/c16 — a PACKED-ARRAY member and a NESTED-STRUCT member.  (The ENUM cell
// is REMOVED, not scored: slang refuses `e: '0` on an `e_t` member — "no
// implicit conversion from 'bit[0:0]' to 'e_t'", rc=3 — and an arm whose
// compile fails teaches error recovery, not golden.)
module c6 (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [3:0] a; logic [1:0][7:0] pk; q64::sub_t s;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], pk: '0, s: '0};
  assign o = 64'(v);
endmodule

// c15 — a PACKED ARRAY whose OUTER bound is symbolic
module c7 #(parameter int V = 2) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [3:0] a; logic [V-1:0][7:0] pk;
  } t_t;
  t_t v;
  assign v = '{a: pa[3:0], pk: '0};
  assign o = 64'(v);
endmodule

// c17/c18 — a SIZED literal on a symbolic member (untouched) and an
// ARITHMETIC-LITERAL bound (no reference in it at all)
module c8 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [V-1:0] a; logic [V-1:0] s; logic [3+1:0] k;
  } t_t;
  t_t v;
  assign v = '{a: pa[2:0], s: 3'b0, k: '0};
  assign o = 64'(v);
endmodule

// c19 — EVERY operand VALUABLE: the adjustOpSize walk does not stop, so the
// instance-aware Bits() width must land on every operand
module c9 #(parameter int V = 3) (output logic [63:0] o);
  typedef struct packed {
    logic [V-1:0] a; logic [V-1:0] b; logic [7:0] c;
  } t_t;
  t_t v;
  assign v = '{a: 3'd2, b: '0, c: '0};
  assign o = 64'(v);
endmodule

// c20 — a `default:` fill over a symbolic-bound struct
module c10 #(parameter int V = 3) (input logic [63:0] pa, output logic [63:0] o);
  typedef struct packed {
    logic [V-1:0] a; logic [V-1:0] b; logic [7:0] c;
  } t_t;
  t_t v;
  assign v = '{a: pa[2:0], default: '0};
  assign o = 64'(v);
endmodule

module tb;
  logic [63:0] pa;
  logic [63:0] o1, o2, o3, o4, o5, o6, o7, o8, o9, o10;
  c1 #(.V(3)) u1 (.pa(pa), .o(o1));
  c2 u2 (.pa(pa), .o(o2));
  c3 u3 (.pa(pa), .o(o3));
  c4 u4 (.pa(pa), .o(o4));
  c5 u5 (.pa(pa), .o(o5));
  c6 u6 (.pa(pa), .o(o6));
  c7 #(.V(2)) u7 (.pa(pa), .o(o7));
  c8 #(.V(3)) u8 (.pa(pa), .o(o8));
  c9 #(.V(3)) u9 (.o(o9));
  c10 #(.V(3)) u10 (.pa(pa), .o(o10));
endmodule

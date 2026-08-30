// r10earl101 g1_kind101 -- TYPEDEF KINDS as a packed-vector PORT element.
// Axis: logic vector / enum / packed struct / packed array / typedef-of-a-
// typedef, plus a SCALAR (no packed dim) control of each.  The law only ever
// reaches a SCALAR package typedef (LAW S r7 keeps the aggregate kinds on the
// shared qualified object in every position), so the enum / struct / packed-
// array rows are the MUST-NOT-MOVE half of this arm.
package p1k101;
  typedef logic [31:0] vec_t;          // the law's own kind
  typedef logic        bit1_t;         // a scalar logic typedef, no range
  typedef enum logic [1:0] { E0, E1 } enum_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } str_t;
  typedef logic [3:0][7:0] parr_t;     // a packed ARRAY typedef
  typedef vec_t        vec2_t;         // a typedef OF a typedef
endpackage

module m1sub101
  import p1k101::*;
(
  input  vec_t  [7:0] i_vec,           // <- the law's shape
  output vec_t  [7:0] o_vec,
  input  bit1_t [3:0] i_bit1,          // <- the law's shape, no range on the td
  input  enum_t [3:0] i_enum,          // aggregate: must not move
  input  str_t  [3:0] i_str,           // aggregate: must not move
  input  parr_t [3:0] i_parr,          // aggregate: must not move
  input  vec2_t [7:0] i_vec2,          // alias-of-alias: earl96 R1's family
  input  vec_t        i_scalar,        // NO packed dim -- not this shape
  output vec_t        o_scalar
);
  assign o_vec    = i_vec;
  assign o_scalar = i_scalar;
endmodule

module g1_kind101 (input logic clk);
  p1k101::vec_t  [7:0] w_vec;
  p1k101::bit1_t [3:0] w_bit1;
  p1k101::enum_t [3:0] w_enum;
  p1k101::str_t  [3:0] w_str;
  p1k101::parr_t [3:0] w_parr;
  p1k101::vec2_t [7:0] w_vec2;
  p1k101::vec_t        w_scalar;
  p1k101::vec_t  [7:0] w_ovec;
  p1k101::vec_t        w_oscalar;
  m1sub101 u_k (
    .i_vec(w_vec), .o_vec(w_ovec), .i_bit1(w_bit1), .i_enum(w_enum),
    .i_str(w_str), .i_parr(w_parr), .i_vec2(w_vec2),
    .i_scalar(w_scalar), .o_scalar(w_oscalar));
endmodule

// r10earl107 grid arm g3_src107 -- MEASUREMENT ONLY.
// WHERE THE PATTERN COMES FROM, and the member KINDS, at a PORT high_conn.
package pg3_107;
  typedef enum logic [2:0] { E0 = 3'd0, E5 = 3'd5 } e3_t;
  typedef struct packed { logic [3:0] n4; logic [1:0] n2; } inner_t;
  typedef struct packed {
    logic [7:0] m8;
    e3_t        me;
    inner_t     mi;
    logic [3:0] m4;
  } mix_t;
  // named, declaration order
  parameter mix_t M_ORD  = '{ m8:'0, me:E5, mi:'{n4:'1, n2:'0}, m4:'1 };
  // named, SHUFFLED written order
  parameter mix_t M_SHUF = '{ m4:'1, m8:'0, mi:'{n2:'0, n4:'1}, me:E5 };
  // a `default:` fill (on a struct with NO enum member, so the fill types)
  typedef struct packed { logic [7:0] d8; logic [4:0] d5; logic d1; } dflt_t;
  parameter dflt_t M_DEF  = '{ d8:8'hAA, default:'0 };
  // POSITIONAL
  parameter mix_t M_POS  = '{ '0, E5, '{'1,'0}, '1 };
  typedef struct packed { logic [4:0] p5; logic [2:0] p3; } two_t;
  parameter two_t T_LOCAL = '{ p5:'1, p3:'0 };
endpackage

module child3_107 (
  input pg3_107::mix_t a, input pg3_107::mix_t b, input pg3_107::dflt_t c,
  input pg3_107::mix_t d, input pg3_107::two_t e, input pg3_107::two_t f,
  input pg3_107::two_t g
);
  logic u; assign u = ^{a,b,c,d,e,f,g};
endmodule

module g3_src107 (input logic clk, output logic o);
  import pg3_107::*;
  // a MODULE-LOCAL parameter of the same struct type
  localparam pg3_107::two_t T_MOD = '{ p5:'0, p3:'1 };
  child3_107 u_c (
    .a (pg3_107::M_ORD),
    .b (pg3_107::M_SHUF),
    .c (pg3_107::M_DEF),
    .d (pg3_107::M_POS),
    .e (pg3_107::T_LOCAL),   // package param, qualified
    .f (T_LOCAL),            // package param, bare through import
    .g (T_MOD)               // module-local param
  );
  assign o = clk;
endmodule
